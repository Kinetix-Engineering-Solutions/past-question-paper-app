const admin = require('firebase-admin');
const functions = require('firebase-functions');

/**
 * Database service specifically for short answer questions with PQP support
 */

/**
 * Builds query for short answer questions with PQP mode support
 * Option 3: Uses parentQuestionId instead of chainId
 * @param {Object} params - Query parameters
 * @param {number} params.grade - Grade level
 * @param {string} params.subject - Subject name
 * @param {string} params.paper - Paper identifier (p1, p2, etc.)
 * @param {number} [params.year] - Exam year
 * @param {string} [params.season] - Exam season
 * @param {string} [params.topic] - Specific topic
 * @param {string} [params.parentId] - Parent question identifier (replaces chainId)
 * @param {number} [params.limit=50] - Query limit
 * @returns {Query} - Firestore query
 */
async function fetchShortAnswerDocument() {
  const doc = await admin.firestore()
    .collection('questions')
    .doc('short_answer')
    .get();

  if (!doc.exists) {
    return null;
  }

  return { id: doc.id, ...doc.data() };
}

function buildShortAnswerPQPQuery(params) {
  // This function is now replaced by direct document fetch
  // since your structure is a single document, not a collection
  throw new Error('Use fetchShortAnswerDocument instead - structure is a single document');

  // Add PQP-specific filters using nested field queries
  if (paper) {
    query = query.where('pqpData.paper', '==', paper);
  }
  if (year) {
    query = query.where('pqpData.year', '==', year);
  }
  if (season) {
    query = query.where('pqpData.season', '==', season);
  }
  if (topic) {
    query = query.where('topic', '==', topic);
  }
  if (parentId) {
    query = query.where('parentQuestionId', '==', parentId);
  }

  return query;
}

/**
 * Builds query for short answer questions with Sprint mode support
 * @param {Object} params - Query parameters
 * @param {number} params.grade - Grade level
 * @param {string} params.subject - Subject name
 * @param {string} [params.difficulty] - Difficulty level (easy, medium, hard)
 * @param {Array<string>} [params.tags] - Question tags
 * @param {string} [params.topic] - Specific topic
 * @param {number} [params.limit=50] - Query limit
 * @returns {Query} - Firestore query
 */
function buildShortAnswerSprintQuery(params) {
  const { grade, subject, difficulty, tags, topic, limit = 50 } = params;

  let query = admin.firestore()
    .collection('questions')
    .doc('short_answer')
    .collection('questions')
    .where('grade', '==', grade)
    .where('subject', '==', subject)
    .where('availableInModes', 'array-contains', 'sprint')
    .limit(limit);

  // Add Sprint-specific filters
  if (difficulty) {
    query = query.where('sprintData.difficulty', '==', difficulty);
  }
  if (topic) {
    query = query.where('topic', '==', topic);
  }
  if (tags && tags.length > 0) {
    // Use array-contains-any for multiple tag matching
    query = query.where('sprintData.tags', 'array-contains-any', tags);
  }

  return query;
}

/**
 * Fetches questions that are part of a specific PQP chain with dependencies
 * @param {string} chainId - Chain identifier
 * @param {number} grade - Grade level
 * @param {string} subject - Subject name
 * @returns {Array} - Ordered array of questions in the chain
 */
async function fetchPQPQuestionChain(chainId, grade, subject) {
  console.log(`Fetching PQP chain: ${chainId} for grade ${grade} ${subject}`);

  const chainQuery = admin.firestore()
    .collection('questions')
    .doc('short_answer')
    .collection('questions')
    .where('grade', '==', grade)
    .where('subject', '==', subject)
    .where('pqpData.chainId', '==', chainId)
    .where('pqpData.partOfChain', '==', true);

  const chainSnapshot = await chainQuery.get();

  if (chainSnapshot.empty) {
    console.warn(`No questions found for chain: ${chainId}`);
    return [];
  }

  const questions = chainSnapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));

  // Sort questions by question number to maintain chain order
  questions.sort((a, b) => {
    const questionNumberA = parseFloat(a.pqpData?.questionNumber || '0');
    const questionNumberB = parseFloat(b.pqpData?.questionNumber || '0');
    return questionNumberA - questionNumberB;
  });

  console.log(`Found ${questions.length} questions in chain ${chainId}`);
  return questions;
}

/**
 * Validates that all dependencies for a question are satisfied
 * @param {Object} question - Question with dependencies
 * @param {Array} availableQuestions - Questions available in the current test
 * @returns {boolean} - Whether dependencies are satisfied
 */
function validateQuestionDependencies(question, availableQuestions) {
  // Handle both pqpData.dependsOn and direct dependencies property
  const dependencies = question.pqpData?.dependsOn || question.dependencies || [];

  if (!dependencies || dependencies.length === 0) {
    return true; // No dependencies
  }

  const availableIds = availableQuestions.map(q => q.id);

  // Check if all dependencies are available
  for (const dependencyId of dependencies) {
    if (!availableIds.includes(dependencyId)) {
      console.warn(`Dependency ${dependencyId} not available for question ${question.id}`);
      return false;
    }
  }

  return true;
}

/**
 * Fetches short answer questions with dependency resolution
 * @param {Object} params - Query parameters
 * @returns {Array} - Questions with resolved dependencies
 */
async function fetchShortAnswerQuestionsWithDependencies(params) {
  const { mode = 'pqp' } = params;

  let query;
  if (mode === 'pqp') {
    query = buildShortAnswerPQPQuery(params);
  } else if (mode === 'sprint') {
    query = buildShortAnswerSprintQuery(params);
  } else {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid mode. Must be "pqp" or "sprint".');
  }

  const questionSnapshot = await query.get();

  if (questionSnapshot.empty) {
    console.warn('No short answer questions found for parameters:', params);
    return [];
  }

  const questions = questionSnapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));

  if (mode === 'pqp') {
    // For PQP mode, resolve dependencies and maintain chain order
    const questionsWithDependencies = [];
    const processedIds = new Set();

    // Sort by chain ID and question number first
    questions.sort((a, b) => {
      const chainComparison = (a.pqpData?.chainId || '').localeCompare(b.pqpData?.chainId || '');
      if (chainComparison !== 0) return chainComparison;

      const questionNumberA = parseFloat(a.pqpData?.questionNumber || '0');
      const questionNumberB = parseFloat(b.pqpData?.questionNumber || '0');
      return questionNumberA - questionNumberB;
    });

    // Add questions in dependency order
    for (const question of questions) {
      if (validateQuestionDependencies(question, questionsWithDependencies)) {
        questionsWithDependencies.push(question);
        processedIds.add(question.id);
      }
    }

    console.log(`Processed ${questionsWithDependencies.length} questions with satisfied dependencies`);
    return questionsWithDependencies;
  }

  // For Sprint mode, return questions as-is (no dependencies)
  return questions;
}

/**
 * Fetches questions by their IDs, specifically for short answer format
 * @param {Array} questionIds - Array of question IDs
 * @returns {Array} - Array of short answer question documents
 */
async function fetchShortAnswerQuestionsForGrading(questionIds) {
  const questionsSnapshot = await admin.firestore()
    .collection('questions')
    .doc('short_answer')
    .collection('questions')
    .where(admin.firestore.FieldPath.documentId(), 'in', questionIds)
    .get();

  if (questionsSnapshot.empty) {
    throw new functions.https.HttpsError('not-found', 'Short answer questions not found for grading.');
  }

  return questionsSnapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));
}

/**
 * Gets questions that depend on a specific question (for chain building)
 * @param {string} questionId - The question ID that other questions depend on
 * @param {number} grade - Grade level
 * @param {string} subject - Subject name
 * @returns {Array} - Questions that depend on the given question
 */
async function getQuestionsDependentOn(questionId, grade, subject) {
  const dependentQuery = admin.firestore()
    .collection('questions')
    .doc('short_answer')
    .collection('questions')
    .where('grade', '==', grade)
    .where('subject', '==', subject)
    .where('pqpData.dependsOn', 'array-contains', questionId);

  const dependentSnapshot = await dependentQuery.get();

  return dependentSnapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));
}

module.exports = {
  buildShortAnswerPQPQuery,
  buildShortAnswerSprintQuery,
  fetchPQPQuestionChain,
  validateQuestionDependencies,
  fetchShortAnswerQuestionsWithDependencies,
  fetchShortAnswerQuestionsForGrading,
  getQuestionsDependentOn
};