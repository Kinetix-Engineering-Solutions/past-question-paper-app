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
exports.generateTest = functions.https.onCall(async (data, context) => {
  try {
    console.log('Test generation request received:', data);
    
    // Extract parameters from request
    const params = data.data || data;
    
    // Validate required parameters
    validateTestParams(params);
    
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
exports.gradeTest = functions.https.onCall(async (data, context) => {
  try {
    console.log('🎯 Grading request received');
    
    // Extract parameters from request
    const params = data.data || data;
    const {
      submissions,
      answers,
      userId,
      subject,
      paper,
      mode,
      totalQuestions,
      durationMinutes,
      sessionDurationSeconds,
      sessionMetadata,
      flags,
    } = params;
    
    // DEBUG: Log received parameters
    console.log('📋 Received parameters:', {
      hasSubmissions: !!submissions || !!answers,
      hasUserId: !!userId,
      contextAuthUid: context.auth?.uid,
      receivedUserId: userId,
      finalUserIdWillBe: userId || (context.auth ? context.auth.uid : null),
      subject,
      paper,
      mode,
      totalQuestions,
      durationMinutes,
    });
    
    // Handle both new format (submissions) and legacy format (answers)
    const submissionsData = submissions || answers;
    
    // Validate parameters
    validateGradingParams({ submissions: submissionsData });
    
    // Get userId from params or context auth (fallback)
    const finalUserId = userId || (context.auth ? context.auth.uid : null);
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