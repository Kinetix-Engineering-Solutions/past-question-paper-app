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
    console.log('Grading request received');
    
    // Extract parameters from request
    const params = data.data || data;
    const { submissions, answers, userId } = params;
    
    // Handle both new format (submissions) and legacy format (answers)
    const submissionsData = submissions || answers;
    
    // Validate parameters
    validateGradingParams({ submissions: submissionsData });
    
    // Grade test using modular service
    const gradingResult = await gradeTestSubmission({
      submissions: submissionsData,
      userId: userId || (context.auth ? context.auth.uid : null)
    });
    
    console.log('Grading completed successfully');
    
    return {
      results: gradingResult.results,
      statistics: gradingResult.statistics,
      gradedAt: gradingResult.gradedAt
    };

  } catch (error) {
    console.error('Error in gradeTest:', error);
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', 'Failed to grade test. Please try again.');
  }
});