const admin = require('firebase-admin');
const functions = require('firebase-functions');

/**
 * Database service for Firestore operations
 */

/**
 * Builds Firestore query for questions based on parameters
 * @param {Object} params - Query parameters
 * @returns {Query} - Firestore query
 */
function buildQuestionQuery(params) {
  const { grade, subject, paper, year, season, topic, limit = 50 } = params;
  
  let query = admin.firestore().collection('questions')
    .where('grade', '==', grade)
    .where('subject', '==', subject)
    .limit(limit);

  if (paper) {
    query = query.where('paper', '==', paper);
  }
  if (year) {
    query = query.where('year', '==', year);
  }
  if (season) {
    query = query.where('season', '==', season);
  }
  if (topic) {
    query = query.where('topic', '==', topic);
  }

  return query;
}

/**
 * Fetches blueprint document from Firestore
 * @param {string} blueprintId - Blueprint document ID
 * @returns {Object} - Blueprint data
 * @throws {HttpsError} - If blueprint not found
 */
async function fetchBlueprint(blueprintId) {
  console.log('Looking for blueprint:', blueprintId);

  const blueprintDoc = await admin.firestore()
    .collection('blueprints')
    .doc(blueprintId)
    .get();

  if (!blueprintDoc.exists) {
    console.error('Blueprint not found:', blueprintId);
    
    // Let's also log what blueprints are available for debugging
    try {
      const allBlueprints = await admin.firestore().collection('blueprints').limit(10).get();
      const availableIds = allBlueprints.docs.map(doc => doc.id);
      console.log('Available blueprint IDs:', availableIds);
    } catch (err) {
      console.log('Could not fetch available blueprints:', err.message);
    }
    
    throw new functions.https.HttpsError('not-found', 'Exam format not found. Please check your subject and paper selection.');
  }

  const blueprint = blueprintDoc.data();
  console.log('Blueprint found:', blueprint);
  
  return blueprint;
}

/**
 * Executes question query and validates results
 * @param {Query} query - Firestore query
 * @param {Object} params - Original query parameters for error messages
 * @returns {Array} - Array of question documents
 * @throws {HttpsError} - If no questions found
 */
async function executeQuestionQuery(query, params) {
  const questionSnapshot = await query.get();
  
  if (questionSnapshot.empty) {
    console.error('No questions found for query:', params);
    throw new functions.https.HttpsError('not-found', 'No questions found for the selected criteria.');
  }

  return questionSnapshot.docs;
}

/**
 * Fetches questions by IDs for grading
 * @param {Array} questionIds - Array of question IDs
 * @returns {Array} - Array of question documents
 * @throws {HttpsError} - If questions not found
 */
async function fetchQuestionsForGrading(questionIds) {
  const questionsSnapshot = await admin.firestore()
    .collection('questions')
    .where(admin.firestore.FieldPath.documentId(), 'in', questionIds)
    .get();

  if (questionsSnapshot.empty) {
    throw new functions.https.HttpsError('not-found', 'Questions not found for grading.');
  }

  return questionsSnapshot.docs;
}

/**
 * Saves test results to user's profile
 * @param {string} userId - User ID
 * @param {Object} resultData - Test result data
 */
async function saveUserTestResults(userId, resultData) {
  try {
    await admin.firestore()
      .collection('users')
      .doc(userId)
      .collection('testResults')
      .add(resultData);
    
    console.log(`Test results saved for user: ${userId}`);
  } catch (error) {
    console.error('Error saving user test results:', error);
    // Don't throw error - saving results is not critical for the grading process
  }
}

module.exports = {
  buildQuestionQuery,
  fetchBlueprint,
  executeQuestionQuery,
  fetchQuestionsForGrading,
  saveUserTestResults
};
