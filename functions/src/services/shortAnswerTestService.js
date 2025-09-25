const { generateSingleDocumentTest } = require('./shortAnswerSingleDocService');
const { safeArray, mapQuestionData } = require('../helpers/dataHelpers');

/**
 * Test generation service specifically for short answer questions
 * Extends the main test service with PQP chain support and dependency resolution
 */

/**
 * Processes short answer questions for test format
 * @param {Array} questions - Array of short answer question data
 * @param {string} mode - Test mode (pqp, sprint)
 * @returns {Array} - Processed questions
 */
function processShortAnswerQuestions(questions, mode = 'pqp') {
  return questions.map((question, index) => {
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

    // Mode-specific processing
    if (mode === 'pqp' && question.pqpData) {
      processedQuestion.questionText = question.pqpData.questionText;
      processedQuestion.maxMarks = question.pqpData.marks;
      processedQuestion.questionNumber = question.pqpData.questionNumber;
      processedQuestion.chainId = question.pqpData.chainId;
      processedQuestion.dependencies = question.pqpData.dependsOn || [];
      processedQuestion.partOfChain = question.pqpData.partOfChain || false;
    } else if (mode === 'sprint' && question.sprintData) {
      processedQuestion.questionText = question.sprintData.questionText;
      processedQuestion.maxMarks = question.sprintData.marks;
      processedQuestion.questionNumber = index + 1; // Sequential numbering for sprint
      processedQuestion.difficulty = question.sprintData.difficulty;
      processedQuestion.estimatedTime = question.sprintData.estimatedTime;
      processedQuestion.tags = question.sprintData.tags || [];
      processedQuestion.providedContext = question.sprintData.providedContext || {};
    } else {
      // Fallback to basic question data
      processedQuestion.maxMarks = question.maxMarks || question.marks || 1;
      processedQuestion.questionNumber = index + 1;
    }

    // Add learning support features
    processedQuestion.hints = question.hints || [];
    processedQuestion.workingSteps = question.workingSteps || [];
    processedQuestion.showWorking = question.showWorking || false;

    return processedQuestion;
  });
}

/**
 * Generates PQP mode short answer test with chain support
 * @param {Object} params - Test generation parameters
 * @returns {Object} - Generated PQP test data
 */
async function generateShortAnswerPQPTest(params) {
  console.log('Generating Short Answer PQP test with params:', params);

  const { grade, subject, paper, year, season, topic, chainId, limit = 50 } = params;

  try {
    let questions = [];

    if (chainId) {
      // Fetch specific question chain
      console.log(`Fetching PQP chain: ${chainId}`);
      questions = await fetchPQPQuestionChain(chainId, grade, subject);
    } else {
      // Fetch questions with dependency resolution
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

    // Process questions for PQP format
    const processedQuestions = processShortAnswerQuestions(questions, 'pqp');

    // Group questions by chain for organization
    const chainGroups = {};
    processedQuestions.forEach(question => {
      const chain = question.chainId || 'individual';
      if (!chainGroups[chain]) {
        chainGroups[chain] = [];
      }
      chainGroups[chain].push(question);
    });

    console.log(`Questions organized into ${Object.keys(chainGroups).length} chain groups`);

    // Calculate total marks
    const totalMarks = processedQuestions.reduce((sum, q) => sum + (q.maxMarks || 1), 0);

    return {
      questions: processedQuestions,
      totalQuestions: processedQuestions.length,
      totalMarks: totalMarks,
      chainGroups: chainGroups,
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

  const { grade, subject, difficulty, tags, topic, limit = 50 } = params;

  try {
    const queryParams = {
      mode: 'sprint',
      grade,
      subject,
      difficulty,
      tags,
      topic,
      limit
    };

    const questions = await fetchShortAnswerQuestionsWithDependencies(queryParams);

    if (questions.length === 0) {
      throw new Error('No short answer Sprint questions found for the specified criteria');
    }

    console.log(`Found ${questions.length} Sprint short answer questions`);

    // Process questions for Sprint format
    const processedQuestions = processShortAnswerQuestions(questions, 'sprint');

    // Group questions by difficulty for analysis
    const difficultyGroups = {};
    processedQuestions.forEach(question => {
      const diff = question.difficulty || 'unknown';
      if (!difficultyGroups[diff]) {
        difficultyGroups[diff] = [];
      }
      difficultyGroups[diff].push(question);
    });

    // Calculate total marks and estimated time
    const totalMarks = processedQuestions.reduce((sum, q) => sum + (q.maxMarks || 1), 0);
    const estimatedTime = processedQuestions.reduce((sum, q) => sum + (q.estimatedTime || 2), 0);

    return {
      questions: processedQuestions,
      totalQuestions: processedQuestions.length,
      totalMarks: totalMarks,
      estimatedTime: estimatedTime,
      difficultyGroups: difficultyGroups,
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

/**
 * Validates that questions in a chain have proper dependencies
 * @param {Array} questions - Array of questions in a chain
 * @returns {Object} - Validation result with any issues found
 */
function validateQuestionChain(questions) {
  const issues = [];
  const questionIds = new Set(questions.map(q => q.id));

  questions.forEach(question => {
    if (question.dependencies && question.dependencies.length > 0) {
      const missingDependencies = question.dependencies.filter(dep => !questionIds.has(dep));

      if (missingDependencies.length > 0) {
        issues.push({
          questionId: question.id,
          questionNumber: question.questionNumber,
          missingDependencies: missingDependencies
        });
      }
    }
  });

  return {
    isValid: issues.length === 0,
    issues: issues,
    totalQuestions: questions.length,
    questionsWithDependencies: questions.filter(q => q.dependencies && q.dependencies.length > 0).length
  };
}

module.exports = {
  processShortAnswerQuestions,
  generateShortAnswerPQPTest,
  generateShortAnswerSprintTest,
  generateShortAnswerTest,
  validateQuestionChain
};