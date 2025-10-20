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

  // IMPORTANT: Exclude parent questions (they're context documents, not answerable questions)
  // Parents have isParent: true and should never appear as standalone questions
  // Note: Firestore doesn't support != operator, so we filter in memory after fetching

  return query;
}

/**
 * Builds enhanced Firestore query with cognitive level filtering
 * @param {Object} params - Query parameters including cognitiveLevel
 * @returns {Query} - Enhanced Firestore query
 */
function buildEnhancedQuestionQuery(params) {
  const { grade, subject, paper, year, season, topic, cognitiveLevel, limit = 50 } = params;
  
  let query = admin.firestore().collection('questions')
    .where('grade', '==', grade)
    .where('subject', '==', subject);

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
  if (cognitiveLevel) {
    query = query.where('cognitiveLevel', '==', cognitiveLevel);
  }

  // IMPORTANT: Exclude parent questions (they're context documents, not answerable questions)
  // Note: Firestore doesn't support != operator, so we filter in memory after fetching

  query = query.limit(limit);
  
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
  if (!Array.isArray(questionIds) || questionIds.length === 0) {
    throw new functions.https.HttpsError('invalid-argument', 'No question IDs provided for grading.');
  }

  // Firestore limits 'in' queries to 10 elements per call. For larger tests,
  // chunk the IDs and merge the results to avoid runtime failures on big exams.
  const batches = [];
  for (let i = 0; i < questionIds.length; i += 10) {
    batches.push(questionIds.slice(i, i + 10));
  }

  const questionDocs = [];

  for (const batch of batches) {
    const snapshot = await admin.firestore()
      .collection('questions')
      .where(admin.firestore.FieldPath.documentId(), 'in', batch)
      .get();

    questionDocs.push(...snapshot.docs);
  }

  if (questionDocs.length === 0) {
    throw new functions.https.HttpsError('not-found', 'Questions not found for grading.');
  }

  if (questionDocs.length !== questionIds.length) {
    const missingIds = questionIds.filter(id => !questionDocs.find(doc => doc.id === id));
    console.warn('⚠️ Missing question documents for grading:', missingIds);
  }

  return questionDocs;
}

/**
 * Saves test results to user's profile
 * @param {string} userId - User ID
 * @param {Object} resultData - Test result data
 */
async function saveUserTestResults(userId, resultData) {
  try {
    // Validate userId exists
    if (!userId || typeof userId !== 'string' || userId.trim() === '') {
      console.error('⚠️ SKIPPED: Attempting to save results with invalid userId:', userId);
      console.error('   Result data would have been:', {
        subject: resultData?.statistics?.subject,
        score: resultData?.statistics?.marksAwarded,
        timestamp: new Date().toISOString()
      });
      return; // Skip saving if no valid userId
    }
    
    const statistics = resultData.statistics || {};
    const metadata = resultData.metadata || {};

    const subject = metadata.subject || statistics.subject || null;
    const paper = metadata.paper || statistics.paper || null;
    const mode = metadata.mode || statistics.mode || 'Practice';
    const totalQuestions = metadata.totalQuestions || statistics.totalQuestions || (resultData.results ? resultData.results.length : 0);
    const score = statistics.marksAwarded || 0;
    const totalMarks = statistics.totalMarks || 0;
    const grade = statistics.grade || 'F';
    const percentage = statistics.percentage || 0;

    console.log(`📊 Saving test results for user: ${userId}`);
    console.log(`   Subject: ${subject || 'Unknown'} | Mode: ${mode}`);
    console.log(`   Score: ${score}/${totalMarks} (${percentage}% - ${grade})`);

    const serverTimestamp = admin.firestore.FieldValue.serverTimestamp();

    const payload = {
      userId,
      subject,
      paper,
      mode,
      totalQuestions,
      score,
      totalMarks,
      percentage,
      grade,
      durationMinutes: metadata.durationMinutes ?? null,
      sessionDurationSeconds: metadata.sessionDurationSeconds ?? null,
      results: resultData.results || [],
      statistics,
      metadata,
      gradedAt: resultData.gradedAt || metadata.submittedAt || new Date().toISOString(),
      testDate: serverTimestamp,
      savedAt: serverTimestamp,
    };

    const saveResult = await admin.firestore()
      .collection('users')
      .doc(userId)
      .collection('testResults')
      .add(payload);
    
    console.log(`✅ Test results saved successfully for user: ${userId}`);
    console.log(`   Document ID: ${saveResult.id}`);
    console.log(`   Path: users/${userId}/testResults/${saveResult.id}`);
    
  } catch (error) {
    console.error(`❌ Error saving user test results for ${userId}:`, error);
    console.error('   Error details:', {
      code: error.code,
      message: error.message,
      path: `users/${userId}/testResults/`
    });
    // Don't throw error - saving results is not critical for the grading process
    // User still gets grading results even if storage fails
  }
}

// ============================================================================
// OPTION 3: Parent-Child Relationship Functions
// ============================================================================

/**
 * Fetches a parent question by ID
 * @param {string} parentId - Parent question ID
 * @returns {Object|null} - Parent question data or null if not found
 */
async function getParentQuestion(parentId) {
  try {
    const doc = await admin.firestore()
      .collection('questions')
      .doc(parentId)
      .get();
    
    if (!doc.exists) {
      console.warn(`Parent question not found: ${parentId}`);
      return null;
    }
    
    return { id: doc.id, ...doc.data() };
  } catch (error) {
    console.error(`Error fetching parent question ${parentId}:`, error);
    return null;
  }
}

/**
 * Fetches all child questions of a parent
 * @param {string} parentId - Parent question ID
 * @returns {Array} - Array of child question documents
 */
async function getChildQuestions(parentId) {
  try {
    const parent = await getParentQuestion(parentId);
    if (!parent || !parent.childQuestionIds || parent.childQuestionIds.length === 0) {
      return [];
    }
    
    // Fetch children in batches (Firestore 'in' limit is 10)
    const childIds = parent.childQuestionIds;
    const batches = [];
    
    for (let i = 0; i < childIds.length; i += 10) {
      const batch = childIds.slice(i, i + 10);
      batches.push(batch);
    }
    
    const childDocs = [];
    for (const batch of batches) {
      const snapshot = await admin.firestore()
        .collection('questions')
        .where(admin.firestore.FieldPath.documentId(), 'in', batch)
        .get();
      
      childDocs.push(...snapshot.docs);
    }
    
    return childDocs
      .filter(doc => doc.exists)
      .map(doc => ({ id: doc.id, ...doc.data() }));
  } catch (error) {
    console.error(`Error fetching child questions for parent ${parentId}:`, error);
    return [];
  }
}

/**
 * Fetches a question family (parent + all children)
 * @param {string} parentId - Parent question ID
 * @returns {Object|null} - Question family with parent and children, or null
 */
async function getQuestionFamily(parentId) {
  try {
    const parent = await getParentQuestion(parentId);
    if (!parent) {
      return null;
    }
    
    const children = await getChildQuestions(parentId);
    
    return {
      parent,
      children,
      imageUrl: parent.imageUrl,
      mainQuestionText: parent.mainQuestionText,
      totalMarks: parent.totalMarks,
      questionCount: parent.questionCount || children.length
    };
  } catch (error) {
    console.error(`Error fetching question family ${parentId}:`, error);
    return null;
  }
}

/**
 * Checks if a question has a parent
 * @param {Object} question - Question document
 * @returns {boolean} - True if question has parent
 */
function hasParent(question) {
  return !!question.parentQuestionId;
}

/**
 * Gets the image URL for a question (handles parent inheritance)
 * @param {Object} question - Question document
 * @returns {string|null} - Image URL or null
 */
async function getQuestionImageUrl(question) {
  // Direct image URL
  if (question.imageUrl && !question.usesParentImage) {
    return question.imageUrl;
  }
  
  // Inherited from parent
  if (question.usesParentImage && question.parentQuestionId) {
    const parent = await getParentQuestion(question.parentQuestionId);
    return parent?.imageUrl || null;
  }
  
  return null;
}

/**
 * Enriches a question with parent context (if applicable)
 * @param {Object} question - Question document
 * @returns {Object} - Enriched question with parent data
 */
async function enrichQuestionWithParent(question) {
  if (!hasParent(question)) {
    return question;
  }
  
  const parent = await getParentQuestion(question.parentQuestionId);
  if (!parent) {
    return question;
  }
  
  // Return proper parent context object with all needed fields
  return {
    ...question,
    parentContext: {
      questionText: parent.questionText || parent.mainQuestionText,
      imageUrl: parent.imageUrl,
      pqpData: parent.pqpData
    },
    imageUrl: question.usesParentImage ? parent.imageUrl : question.imageUrl
  };
}

/**
 * Fetches questions by parent ID (alias for getChildQuestions)
 * @param {string} parentId - Parent question ID
 * @returns {Array} - Array of child questions
 */
async function fetchQuestionsByParentId(parentId) {
  return getChildQuestions(parentId);
}

module.exports = {
  buildQuestionQuery,
  buildEnhancedQuestionQuery,
  fetchBlueprint,
  executeQuestionQuery,
  fetchQuestionsForGrading,
  saveUserTestResults,
  // Option 3: Parent-child functions
  getParentQuestion,
  getChildQuestions,
  getQuestionFamily,
  hasParent,
  getQuestionImageUrl,
  enrichQuestionWithParent,
  fetchQuestionsByParentId
};
