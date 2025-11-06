const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });

// Import modular services
const { validateTestParams, validateGradingParams } = require('./src/helpers/validation');
const { generateTestPaper } = require('./src/services/testService');
const { gradeTestSubmission } = require('./src/services/gradingService');

// Initialize Firebase Admin
admin.initializeApp();

/**
 * Cloud Function to generate a test paper
 * Generates questions based on parameters and blueprints
 */
exports.generateTest = functions
  .runWith({
    memory: '256MB',
    timeoutSeconds: 30,
    maxInstances: 100 // Limit concurrent executions to control costs
  })
  .https.onCall(async (data, context) => {
  try {
    // SECURITY: Require authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
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
        throw new functions.https.HttpsError(
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
      throw new functions.https.HttpsError(
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
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', 'Failed to generate test. Please try again.');
  }
});

/**
 * Cloud Function to grade a test submission
 * Grades answers and returns detailed results with statistics
 */
exports.gradeTest = functions
  .runWith({
    memory: '256MB',
    timeoutSeconds: 30,
    maxInstances: 100 // Limit concurrent executions to control costs
  })
  .https.onCall(async (data, context) => {
  try {
    // SECURITY: Require authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
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
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Cannot grade more than 100 questions at once.'
      );
    }
    
    // Validate answer text length
    for (const [questionId, answer] of Object.entries(submissionsData || {})) {
      if (typeof answer === 'string' && answer.length > 50000) {
        throw new functions.https.HttpsError(
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
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', 'Failed to grade test. Please try again.');
  }
});