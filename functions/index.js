const functions = require('firebase-functions');
const {onCall, HttpsError} = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });

// Import modular services
const { validateTestParams, validateGradingParams } = require('./src/helpers/validation');
const { generateTestPaper } = require('./src/services/testService');
const { gradeTestSubmission } = require('./src/services/gradingService');

// Initialize Firebase Admin
admin.initializeApp();

// -------- User Cleanup (Auth onDelete) --------
// Lazy helper to cleanup user data after account deletion.
async function cleanupUserAccount(uid) {
  const firestore = admin.firestore();
  const bucket = admin.storage().bucket();
  console.log(`[UserCleanup] Starting cleanup for uid=${uid}`);

  // Delete user doc
  try {
    await firestore.collection('users').doc(uid).delete();
    console.log(`[UserCleanup] Deleted users/${uid}`);
  } catch (e) {
    console.error(`[UserCleanup] Failed deleting users/${uid}`, e);
  }

  // Delete test sessions documents
  try {
    const sessionsSnap = await firestore.collection('test_sessions').where('userId', '==', uid).get();
    if (!sessionsSnap.empty) {
      const batch = firestore.batch();
      sessionsSnap.forEach(doc => batch.delete(doc.ref));
      await batch.commit();
      console.log(`[UserCleanup] Deleted ${sessionsSnap.size} test_sessions for uid=${uid}`);
    } else {
      console.log('[UserCleanup] No test_sessions found for user');
    }
  } catch (e) {
    console.error(`[UserCleanup] Failed deleting test_sessions for ${uid}`, e);
  }

  // Storage prefixes to purge (convention based)
  const prefixes = [
    `user_uploads/${uid}/`,
    `profile_images/${uid}/`,
  ];
  for (const prefix of prefixes) {
    try {
      await bucket.deleteFiles({ prefix });
      console.log(`[UserCleanup] Deleted storage prefix ${prefix}`);
    } catch (e) {
      if (e && e.code !== 404) {
        console.error(`[UserCleanup] Failed deleting storage prefix ${prefix}`, e);
      }
    }
  }

  console.log(`[UserCleanup] Completed cleanup for uid=${uid}`);
}

// Auth trigger: cascade deletion of Firestore + Storage after auth account removal.
exports.onUserDeleteCleanup = functions.auth.user().onDelete(async (user) => {
  const uid = user.uid;
  try {
    await cleanupUserAccount(uid);
  } catch (e) {
    console.error(`[UserCleanup] Unexpected error during cleanup for ${uid}`, e);
  }
});

/**
 * Cloud Function to generate a test paper
 * Generates questions based on parameters and blueprints
 */
exports.generateTest = onCall(
  {
    memory: '256MiB',
    timeoutSeconds: 30,
    maxInstances: 100 // Limit concurrent executions to control costs
  },
  async (request) => {
  const context = request;
  const data = request.data;
  try {
    // SECURITY: Require authentication
    if (!context.auth) {
      throw new HttpsError(
        'unauthenticated',
        'You must be logged in to generate tests.'
      );
    }
    
    const userId = context.auth.uid;
    console.log('Test generation request received from user:', userId);
    
    // RATE LIMITING: Check if user is generating tests too quickly
    const userRef = admin.firestore().collection('users').doc(userId);
    const userDoc = await userRef.get();
    
    if (userDoc.exists) {
      const userData = userDoc.data();
      const lastGeneration = userData.lastTestGeneration;
      const now = Date.now();
      
      // Limit to 1 test generation every 3 seconds
      if (lastGeneration && (now - lastGeneration) < 3000) {
        throw new HttpsError(
          'resource-exhausted',
          'Please wait a moment before generating another test.'
        );
      }
      
      // Update last generation timestamp
      await userRef.update({ 
        lastTestGeneration: now,
        totalTestsGenerated: admin.firestore.FieldValue.increment(1)
      });
    }
    
    console.log('Test generation request received:', data);
    
    // Extract parameters from request
    const params = data.data || data;
    
    // Validate required parameters
    validateTestParams(params);
    
    // SECURITY: Validate request size
    const requestedQuestions = params.numQuestions || 50;
    if (requestedQuestions > 100) {
      throw new HttpsError(
        'invalid-argument',
        'Cannot generate more than 100 questions at once.'
      );
    }
    
    // Generate test using modular service
    const testData = await generateTestPaper(params);
    
    // Remove sensitive data before sending to client
    const sanitizedQuestions = testData.questions.map(question => {
      const { correctAnswer, explanation, correctAnswers, ...sanitized } = question;
      
      // IMPORTANT: Explicitly preserve the question ID for review screen mapping
      sanitized.id = question.id;
      
      // IMPORTANT: For drag-and-drop ordering questions, preserve correctOrder 
      // for the review screen to display correct answers
      const format = (question.format || question.questionType || '').toLowerCase();
      if (format.includes('drag') && question.correctOrder) {
        sanitized.correctOrder = question.correctOrder;
      }
      
      // IMPORTANT: For drag-and-drop questions, preserve dragItems for step text mapping
      if (format.includes('drag') && question.dragItems) {
        sanitized.dragItems = question.dragItems;
      }
      
      return sanitized;
    });
    
    console.log(`Successfully generated ${sanitizedQuestions.length} questions`);
    
    return {
      questions: sanitizedQuestions,
      totalQuestions: testData.totalQuestions,
      blueprint: testData.blueprint,
      generatedAt: testData.generatedAt
    };

  } catch (error) {
    console.error('Error in generateTest:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', 'Failed to generate test. Please try again.');
  }
});

/**
 * Cloud Function to grade a test submission
 * Grades answers and returns detailed results with statistics
 */
exports.gradeTest = onCall(
  {
    memory: '256MiB',
    timeoutSeconds: 30,
    maxInstances: 100 // Limit concurrent executions to control costs
  },
  async (request) => {
  const context = request;
  const data = request.data;
  try {
    // SECURITY: Require authentication
    if (!context.auth) {
      throw new HttpsError(
        'unauthenticated',
        'You must be logged in to submit tests for grading.'
      );
    }
    
    const userId = context.auth.uid;
    console.log('🎯 Grading request received from user:', userId);
    
    // Extract parameters from request
    const params = data.data || data;
    const {
      submissions,
      answers,
      subject,
      paper,
      mode,
      totalQuestions,
      durationMinutes,
      sessionDurationSeconds,
      sessionMetadata,
      flags,
    } = params;
    
    // SECURITY: Validate submission size
    const submissionsData = submissions || answers;
    const submissionCount = Object.keys(submissionsData || {}).length;
    
    if (submissionCount > 100) {
      throw new HttpsError(
        'invalid-argument',
        'Cannot grade more than 100 questions at once.'
      );
    }
    
    // Validate answer text length
    for (const [questionId, answer] of Object.entries(submissionsData || {})) {
      if (typeof answer === 'string' && answer.length > 50000) {
        throw new HttpsError(
          'invalid-argument',
          'Answer text is too long. Maximum 50,000 characters per answer.'
        );
      }
    }
    
    // DEBUG: Log received parameters
    console.log('📋 Received parameters:', {
      hasSubmissions: !!submissions || !!answers,
      contextAuthUid: context.auth?.uid,
      subject,
      paper,
      mode,
      totalQuestions,
      durationMinutes,
    });
    
    // Validate parameters
    validateGradingParams({ submissions: submissionsData });
    
    // SECURITY: Use authenticated user's ID (don't trust client-provided userId)
    const finalUserId = context.auth.uid;
    console.log('✅ Final userId for storage:', finalUserId || '⚠️ WARNING: No userId available');
    console.log('   - Received userId param:', userId);
    console.log('   - Context auth uid:', context.auth?.uid);
    console.log('   - Using:', finalUserId);

    const metadata = {
      subject: subject || sessionMetadata?.subject || null,
      paper: paper || sessionMetadata?.paper || sessionMetadata?.selectedPaper || null,
      mode: mode || sessionMetadata?.modeKey || 'Practice',
      totalQuestions: totalQuestions || sessionMetadata?.totalQuestions || (submissionsData ? Object.keys(submissionsData).length : null),
      durationMinutes: durationMinutes ?? sessionMetadata?.configuredDurationMinutes ?? sessionMetadata?.duration ?? null,
      sessionDurationSeconds: sessionDurationSeconds ?? sessionMetadata?.sessionDurationSeconds ?? null,
      flags: flags || {},
      sessionMetadata: sessionMetadata || {},
      submittedAt: params.submittedAt || new Date().toISOString(),
    };
    
    // Grade test using modular service
    const gradingResult = await gradeTestSubmission({
      submissions: submissionsData,
      userId: finalUserId,  // Pass the resolved userId
      metadata,
    });
    
    console.log('✅ Grading completed successfully');
    
    return {
      results: gradingResult.results,
      statistics: gradingResult.statistics,
      gradedAt: gradingResult.gradedAt
    };

  } catch (error) {
    console.error('❌ Error in gradeTest:', error);
    
    if (error instanceof HttpsError) {
      throw error;
    }
    
    throw new HttpsError('internal', 'Failed to grade test. Please try again.');
  }
});