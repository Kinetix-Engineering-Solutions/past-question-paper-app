const functions = require('firebase-functions');

/**
 * Validation helper functions
 */

/**
 * Validates request parameters for test generation
 * @param {Object} params - Request parameters
 * @throws {HttpsError} - If validation fails
 */
function validateTestParams(params) {
  const { grade, subject } = params;
  
  if (grade === null || grade === undefined || typeof grade !== 'number' || !subject) {
    console.log('Validation failed - Grade:', grade, 'Type:', typeof grade, 'Subject:', subject);
    throw new functions.https.HttpsError('invalid-argument', 'Grade (as number) and subject are required.');
  }
}

/**
 * Validates grading request parameters
 * @param {Object} data - Request data containing submissions
 * @throws {HttpsError} - If validation fails
 */
function validateGradingParams(data) {
  const { submissions } = data;
  
  if (!submissions || typeof submissions !== 'object') {
    throw new functions.https.HttpsError('invalid-argument', 'Submissions object is required.');
  }
  
  const questionIds = Object.keys(submissions);
  if (questionIds.length === 0) {
    throw new functions.https.HttpsError('invalid-argument', 'No submissions provided for grading.');
  }
  
  console.log('Validated grading parameters:', { submissionCount: questionIds.length });
}

module.exports = {
  validateTestParams,
  validateGradingParams
};
