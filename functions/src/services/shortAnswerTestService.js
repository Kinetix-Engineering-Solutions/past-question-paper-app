const { generateSingleDocumentTest } = require('./shortAnswerSingleDocService');
const { safeArray, mapQuestionData } = require('../helpers/dataHelpers');
const { getParentQuestion, enrichQuestionWithParent, hasParent } = require('./databaseService');

/**
 * Test generation service specifically for short answer questions
 * Option 3: Uses parent-child relationships instead of manual chainId
 */

/**
 * Processes short answer questions for test format
 * @param {Array} questions - Array of short answer question data
 * @param {string} mode - Test mode (pqp, sprint)
 * @returns {Array} - Processed questions with parent context
 */
async function processShortAnswerQuestions(questions, mode = 'pqp') {
  const processedQuestions = [];
  
  for (let i = 0; i < questions.length; i++) {
    const question = questions[i];
    const processedQuestion = { ...question };

    // Ensure required short answer fields are present
    processedQuestion.answerType = question.answerType || 'text';
    processedQuestion.caseSensitive = question.caseSensitive || false;
    processedQuestion.tolerance = question.tolerance || 0;

    // Handle answer variations
    if (question.correctAnswer && typeof question.correctAnswer === 'object') {
      processedQuestion.correctAnswer = question.correctAnswer.answer;
      processedQuestion.answerVariations = question.correctAnswer.variations || [];
    } else {
      processedQuestion.answerVariations = question.answerVariations || [];
    }

    // OPTION 3: Enrich with parent context if applicable
    if (hasParent(question)) {
      const enrichedQuestion = await enrichQuestionWithParent(question);
      Object.assign(processedQuestion, enrichedQuestion);
    }

    // Mode-specific processing
    if (mode === 'pqp' && question.pqpData) {
      processedQuestion.questionText = question.pqpData.questionText || question.questionText;
      processedQuestion.maxMarks = question.pqpData.marks || question.marks;
      processedQuestion.questionNumber = question.pqpData.questionNumber;
      // ✅ NO chainId, dependsOn, or partOfChain
    } else if (mode === 'sprint' && question.sprintData) {
      processedQuestion.questionText = question.sprintData.questionText || question.questionText;
      processedQuestion.maxMarks = question.sprintData.marks || question.marks;
      processedQuestion.questionNumber = i + 1; // Sequential numbering for sprint
      processedQuestion.providedContext = question.sprintData.providedContext || {};
    } else {
      // Fallback to basic question data
      processedQuestion.maxMarks = question.maxMarks || question.marks || 1;
      processedQuestion.questionNumber = i + 1;
    }

    // Add learning support features
    processedQuestion.hints = question.hints || [];
    processedQuestion.workingSteps = question.workingSteps || [];
    processedQuestion.showWorking = question.showWorking || false;

    processedQuestions.push(processedQuestion);
  }
  
  return processedQuestions;
}

/**
 * Generates PQP mode short answer test
 * Option 3: Uses parent references instead of chainId
 * @param {Object} params - Test generation parameters
 * @returns {Object} - Generated PQP test data
 */
async function generateShortAnswerPQPTest(params) {
  console.log('Generating Short Answer PQP test with params:', params);

  const { grade, subject, paper, year, season, topic, parentId, limit = 50 } = params;

  try {
    let questions = [];

    if (parentId) {
      // OPTION 3: Fetch questions by parent reference
      console.log(`Fetching questions for parent: ${parentId}`);
      const { getChildQuestions } = require('./databaseService');
      questions = await getChildQuestions(parentId);
    } else {
      // Fetch questions normally
      const queryParams = {
        mode: 'pqp',
        grade,
        subject,
        paper,
        year,
        season,
        topic,
        limit
      };

      questions = await fetchShortAnswerQuestionsWithDependencies(queryParams);
    }

    if (questions.length === 0) {
      throw new Error('No short answer PQP questions found for the specified criteria');
    }

    console.log(`Found ${questions.length} PQP short answer questions`);

    // Process questions for PQP format (now async)
    const processedQuestions = await processShortAnswerQuestions(questions, 'pqp');

    // OPTION 3: Group questions by parent for organization
    const parentGroups = { standalone: [] };
    processedQuestions.forEach(question => {
      const groupKey = question.parentQuestionId || 'standalone';
      if (!parentGroups[groupKey]) {
        parentGroups[groupKey] = [];
      }
      parentGroups[groupKey].push(question);
    });

    console.log(`Questions organized into ${Object.keys(parentGroups).length} groups`);

    // Calculate total marks
    const totalMarks = processedQuestions.reduce((sum, q) => sum + (q.maxMarks || 1), 0);

    return {
      questions: processedQuestions,
      totalQuestions: processedQuestions.length,
      totalMarks: totalMarks,
      parentGroups: parentGroups,  // Renamed from chainGroups
      generatedAt: new Date().toISOString(),
      mode: 'pqp',
      format: 'short_answer',
      params: params
    };

  } catch (error) {
    console.error('Error generating PQP short answer test:', error);
    throw error;
  }
}

/**
 * Generates Sprint mode short answer test
 * @param {Object} params - Test generation parameters
 * @returns {Object} - Generated Sprint test data
 */
async function generateShortAnswerSprintTest(params) {
  console.log('Generating Short Answer Sprint test with params:', params);

  const { grade, subject, topic, limit = 50 } = params;

  try {
    const queryParams = {
      mode: 'sprint',
      grade,
      subject,
      topic,
      limit
    };

    const questions = await fetchShortAnswerQuestionsWithDependencies(queryParams);

    if (questions.length === 0) {
      throw new Error('No short answer Sprint questions found for the specified criteria');
    }

    console.log(`Found ${questions.length} Sprint short answer questions`);

    // Process questions for Sprint format (now async)
    const processedQuestions = await processShortAnswerQuestions(questions, 'sprint');

    // Calculate total marks
    const totalMarks = processedQuestions.reduce((sum, q) => sum + (q.maxMarks || 1), 0);

    return {
      questions: processedQuestions,
      totalQuestions: processedQuestions.length,
      totalMarks: totalMarks,
      generatedAt: new Date().toISOString(),
      mode: 'sprint',
      format: 'short_answer',
      params: params
    };

  } catch (error) {
    console.error('Error generating Sprint short answer test:', error);
    throw error;
  }
}

/**
 * Main function to generate short answer tests (both PQP and Sprint)
 * @param {Object} params - Test generation parameters
 * @returns {Object} - Generated test data
 */
async function generateShortAnswerTest(params) {
  console.log(`Generating short answer test from single document structure`);

  try {
    // Use the single document service
    const testData = await generateSingleDocumentTest(params);

    // Remove sensitive data (correct answers) before sending to client
    const sanitizedQuestions = testData.questions.map(question => {
      const { correctAnswer, answerVariations, workingSteps, ...sanitized } = question;
      return {
        ...sanitized,
        // Keep some metadata for client-side validation
        answerType: question.answerType,
        caseSensitive: question.caseSensitive,
        tolerance: question.tolerance,
        hasHints: (question.hints || []).length > 0,
        hasWorkingSteps: (question.workingSteps || []).length > 0
      };
    });

    return {
      ...testData,
      questions: sanitizedQuestions
    };

  } catch (error) {
    console.error('Error in generateShortAnswerTest:', error);
    throw error;
  }
}




module.exports = {
  processShortAnswerQuestions,
  generateShortAnswerPQPTest,
  generateShortAnswerSprintTest,
  generateShortAnswerTest
};