const admin = require('firebase-admin');
const functions = require('firebase-functions');

/**
 * Database service for single short answer document structure
 * Your structure: questions/short_answer = single document with question data
 */

/**
 * Debug function to list all documents in the questions collection
 */
async function debugQuestionsCollection() {
  try {
    console.log('🔍 Debugging questions collection...');
    const questionsSnapshot = await admin.firestore()
      .collection('questions')
      .get();

    if (questionsSnapshot.empty) {
      console.log('❌ No documents found in questions collection');
      return [];
    }

    const documents = [];
    questionsSnapshot.forEach(doc => {
      console.log(`📄 Found document ID: ${doc.id}`);
      documents.push({ id: doc.id, data: doc.data() });
    });

    console.log(`✅ Found ${documents.length} documents in questions collection`);
    return documents;
  } catch (error) {
    console.error('❌ Error debugging questions collection:', error);
    return [];
  }
}

/**
 * Fetches the single short answer document from Firestore
 * @returns {Object|null} - The short answer question document or null if not found
 */
async function fetchShortAnswerDocument() {
  try {
    // First debug what's in the questions collection
    await debugQuestionsCollection();

    const doc = await admin.firestore()
      .collection('questions')
      .doc('short answer')  // Using space not underscore based on debug output
      .get();

    if (!doc.exists) {
      console.log('❌ Short answer document not found at questions/short answer');

      // Try alternative document names
      console.log('🔍 Trying alternative document names...');
      const alternatives = ['short_answer', 'short_answers', 'shortAnswer', 'shortAnswers', 'short-answer'];

      for (const alt of alternatives) {
        const altDoc = await admin.firestore()
          .collection('questions')
          .doc(alt)
          .get();

        if (altDoc.exists) {
          console.log(`✅ Found document at questions/${alt} instead!`);
          const data = altDoc.data();
          return { id: altDoc.id, ...data };
        }
      }

      return null;
    }

    const data = doc.data();
    console.log('Short answer document found:', {
      grade: data.grade,
      subject: data.subject,
      availableInModes: data.availableInModes,
      pqpData: data.pqpData ? 'present' : 'missing',
      sprintData: data.sprintData ? 'present' : 'missing'
    });

    return { id: doc.id, ...data };
  } catch (error) {
    console.error('Error fetching short answer document:', error);
    throw error;
  }
}

/**
 * Checks if the single document matches PQP criteria
 * @param {Object} document - The short answer document
 * @param {Object} params - Query parameters
 * @returns {boolean} - Whether the document matches PQP criteria
 */
function matchesPQPCriteria(document, params) {
  const { grade, subject, paper, year, season, topic } = params;

  // Check basic fields
  if (document.grade !== grade) return false;
  if (document.subject !== subject) return false;

  // Check if available in PQP mode
  if (!document.availableInModes || !document.availableInModes.includes('pqp')) return false;

  // Check PQP-specific data
  if (!document.pqpData) return false;

  if (paper && document.pqpData.paper !== paper) return false;
  // Note: Handle both 'year ' and 'year' keys due to space in document
  if (year && document.pqpData.year !== year && document.pqpData['year '] !== year) return false;
  if (season && document.pqpData.season !== season) return false;
  if (topic && document.topic !== topic) return false;

  return true;
}

/**
 * Checks if the single document matches Sprint criteria
 * @param {Object} document - The short answer document
 * @param {Object} params - Query parameters
 * @returns {boolean} - Whether the document matches Sprint criteria
 */
function matchesSprintCriteria(document, params) {
  const { grade, subject, difficulty, tags, topic } = params;

  // Check basic fields
  if (document.grade !== grade) return false;
  if (document.subject !== subject) return false;

  // Check if available in Sprint mode
  if (!document.availableInModes || !document.availableInModes.includes('sprint')) return false;

  // Check Sprint-specific data
  if (!document.sprintData) return false;

  if (difficulty && document.sprintData.difficulty !== difficulty) return false;
  if (topic && document.topic !== topic) return false;

  // Check tags (if provided)
  if (tags && tags.length > 0) {
    if (!document.sprintData.tags || document.sprintData.tags.length === 0) return false;

    // Check if any of the requested tags match
    const hasMatchingTag = tags.some(tag => document.sprintData.tags.includes(tag));
    if (!hasMatchingTag) return false;
  }

  return true;
}

/**
 * Generates PQP test from single short answer document
 * @param {Object} params - Test generation parameters
 * @returns {Object} - Generated test data
 */
async function generateSingleDocumentPQPTest(params) {
  console.log('Generating PQP test from single document with params:', params);

  const document = await fetchShortAnswerDocument();
  if (!document) {
    throw new Error('Short answer document not found at questions/short_answer');
  }

  if (!matchesPQPCriteria(document, params)) {
    console.log('Document does not match PQP criteria');
    console.log('Document criteria:', {
      grade: document.grade,
      subject: document.subject,
      availableInModes: document.availableInModes,
      pqpData: document.pqpData
    });
    console.log('Requested criteria:', params);
    throw new Error('Short answer question does not match the specified PQP criteria');
  }

  // Process the document for PQP mode
  const processedQuestion = {
    id: document.id,
    ...document,
    questionText: document.pqpData.questionText,
    maxMarks: document.pqpData.marks,
    questionNumber: document.pqpData.questionNumber,
    mode: 'pqp'
  };

  return {
    questions: [processedQuestion],
    totalQuestions: 1,
    totalMarks: document.pqpData.marks || 1,
    generatedAt: new Date().toISOString(),
    mode: 'pqp',
    format: 'short_answer',
    params: params
  };
}

/**
 * Generates Sprint test from single short answer document
 * @param {Object} params - Test generation parameters
 * @returns {Object} - Generated test data
 */
async function generateSingleDocumentSprintTest(params) {
  console.log('Generating Sprint test from single document with params:', params);

  const document = await fetchShortAnswerDocument();
  if (!document) {
    throw new Error('Short answer document not found at questions/short_answer');
  }

  if (!matchesSprintCriteria(document, params)) {
    console.log('Document does not match Sprint criteria');
    console.log('Document criteria:', {
      grade: document.grade,
      subject: document.subject,
      availableInModes: document.availableInModes,
      sprintData: document.sprintData
    });
    console.log('Requested criteria:', params);
    throw new Error('Short answer question does not match the specified Sprint criteria');
  }

  // Process the document for Sprint mode
  const processedQuestion = {
    id: document.id,
    ...document,
    questionText: document.sprintData.questionText,
    maxMarks: document.sprintData.marks,
    questionNumber: 1,
    difficulty: document.sprintData.difficulty,
    estimatedTime: document.sprintData.estimatedTime,
    providedContext: document.sprintData.providedContext,
    mode: 'sprint'
  };

  return {
    questions: [processedQuestion],
    totalQuestions: 1,
    totalMarks: document.sprintData.marks || 1,
    estimatedTime: document.sprintData.estimatedTime || 2,
    generatedAt: new Date().toISOString(),
    mode: 'sprint',
    format: 'short_answer',
    params: params
  };
}

/**
 * Main function to generate tests from single document
 * @param {Object} params - Test generation parameters
 * @returns {Object} - Generated test data
 */
async function generateSingleDocumentTest(params) {
  const { mode = 'pqp' } = params;

  try {
    if (mode === 'pqp') {
      return await generateSingleDocumentPQPTest(params);
    } else if (mode === 'sprint') {
      return await generateSingleDocumentSprintTest(params);
    } else {
      throw new Error(`Invalid mode: ${mode}. Must be 'pqp' or 'sprint'.`);
    }
  } catch (error) {
    console.error('Error in generateSingleDocumentTest:', error);
    throw error;
  }
}

/**
 * Fetches single short answer question for grading
 * @param {Array} questionIds - Array containing the question ID
 * @returns {Array} - Array with the single question document
 */
async function fetchSingleDocumentForGrading(questionIds) {
  if (!questionIds.includes('short answer') && !questionIds.includes('short_answer')) {
    throw new functions.https.HttpsError('not-found', 'Short answer question ID not found in grading request.');
  }

  const document = await fetchShortAnswerDocument();
  if (!document) {
    throw new functions.https.HttpsError('not-found', 'Short answer question not found for grading.');
  }

  return [document];
}

module.exports = {
  debugQuestionsCollection,
  fetchShortAnswerDocument,
  matchesPQPCriteria,
  matchesSprintCriteria,
  generateSingleDocumentPQPTest,
  generateSingleDocumentSprintTest,
  generateSingleDocumentTest,
  fetchSingleDocumentForGrading
};