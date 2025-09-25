const { fetchSingleDocumentForGrading } = require('./shortAnswerSingleDocService');

/**
 * Short Answer Grading Service
 * Implements comprehensive grading logic for text-based answers with multiple validation approaches
 */

/**
 * Normalizes text for comparison
 * @param {string} text - Text to normalize
 * @param {boolean} caseSensitive - Whether comparison should be case sensitive
 * @returns {string} - Normalized text
 */
function normalizeText(text, caseSensitive = false) {
  if (!text || typeof text !== 'string') {
    return '';
  }

  let normalized = text.trim();

  if (!caseSensitive) {
    normalized = normalized.toLowerCase();
  }

  // Remove extra whitespace
  normalized = normalized.replace(/\s+/g, ' ');

  // Remove common mathematical spacing inconsistencies
  normalized = normalized.replace(/\s*([=+\-*/()^])\s*/g, '$1');

  // Normalize common mathematical notations
  normalized = normalized.replace(/\*\*/g, '^'); // Convert ** to ^
  normalized = normalized.replace(/\s*\^\s*/g, '^'); // Remove spaces around ^

  return normalized;
}

/**
 * Checks if user answer matches any of the acceptable variations
 * @param {string} userAnswer - User's answer
 * @param {Object} question - Question data with correct answer and variations
 * @returns {boolean} - Whether the answer matches any variation
 */
function checkAnswerVariations(userAnswer, question) {
  const caseSensitive = question.caseSensitive || false;
  const normalizedUserAnswer = normalizeText(userAnswer, caseSensitive);

  if (!normalizedUserAnswer) {
    return false;
  }

  // Check primary correct answer
  const correctAnswer = question.correctAnswer?.answer || question.correctAnswer;
  if (correctAnswer) {
    const normalizedCorrect = normalizeText(correctAnswer, caseSensitive);
    if (normalizedUserAnswer === normalizedCorrect) {
      return true;
    }
  }

  // Check answer variations
  const variations = question.correctAnswer?.variations || question.answerVariations || [];
  for (const variation of variations) {
    const normalizedVariation = normalizeText(variation, caseSensitive);
    if (normalizedUserAnswer === normalizedVariation) {
      return true;
    }
  }

  return false;
}

/**
 * Grades numerical answers with tolerance support
 * @param {string} userAnswer - User's numerical answer
 * @param {Object} question - Question data
 * @returns {boolean} - Whether the numerical answer is correct
 */
function gradeNumericalAnswer(userAnswer, question) {
  const correctAnswer = question.correctAnswer?.answer || question.correctAnswer;
  const tolerance = question.tolerance || 0;

  // Extract numbers from strings (handles formats like "x = 3" or "3")
  const userNum = extractNumber(userAnswer);
  const correctNum = extractNumber(correctAnswer);

  if (userNum === null || correctNum === null) {
    return false;
  }

  if (tolerance > 0) {
    return Math.abs(userNum - correctNum) <= tolerance;
  }

  return Math.abs(userNum - correctNum) < 1e-10; // Handle floating point precision issues
}

/**
 * Extracts numerical value from text
 * @param {string} text - Text containing a number
 * @returns {number|null} - Extracted number or null if not found
 */
function extractNumber(text) {
  if (typeof text === 'number') {
    return text;
  }

  if (typeof text !== 'string') {
    return null;
  }

  // Extract number from various formats
  const matches = text.match(/([+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)/);
  return matches ? parseFloat(matches[1]) : null;
}

/**
 * Grades coordinate answers (points, ordered pairs)
 * @param {string} userAnswer - User's coordinate answer
 * @param {Object} question - Question data
 * @returns {boolean} - Whether the coordinate answer is correct
 */
function gradeCoordinateAnswer(userAnswer, question) {
  const correctAnswer = question.correctAnswer?.answer || question.correctAnswer;

  // Extract coordinates from formats like "(3; 8)", "(3, 8)", "3, 8", "x=3, y=8"
  const coordRegex = /[^\d\-]*([+-]?\d+(?:\.\d+)?)[,;\s]+[^\d\-]*([+-]?\d+(?:\.\d+)?)/;

  const userMatch = userAnswer.match(coordRegex);
  const correctMatch = correctAnswer.match(coordRegex);

  if (!userMatch || !correctMatch) {
    return false;
  }

  const userX = parseFloat(userMatch[1]);
  const userY = parseFloat(userMatch[2]);
  const correctX = parseFloat(correctMatch[1]);
  const correctY = parseFloat(correctMatch[2]);

  const tolerance = question.tolerance || 0;

  if (tolerance > 0) {
    return Math.abs(userX - correctX) <= tolerance && Math.abs(userY - correctY) <= tolerance;
  }

  return userX === correctX && userY === correctY;
}

/**
 * Grades domain/range answers with interval notation
 * @param {string} userAnswer - User's domain/range answer
 * @param {Object} question - Question data
 * @returns {boolean} - Whether the domain/range answer is correct
 */
function gradeDomainRangeAnswer(userAnswer, question) {
  // First try exact matching with variations
  if (checkAnswerVariations(userAnswer, question)) {
    return true;
  }

  // If no exact match, try to parse interval notation
  // This is a simplified version - could be expanded for more complex intervals
  const normalizedUser = normalizeText(userAnswer, false);
  const correctAnswer = question.correctAnswer?.answer || question.correctAnswer;
  const normalizedCorrect = normalizeText(correctAnswer, false);

  // Handle common interval notation equivalents
  const equivalentNotations = [
    [/x\s*∈\s*\(([^;,]+)[;,]\s*∞\)/, /x\s*>\s*$1/],
    [/x\s*∈\s*\[([^;,]+)[;,]\s*∞\)/, /x\s*>=\s*$1/],
    [/x\s*∈\s*\(([^;,]+)[;,]\s*([^)]+)\)/, /\$1\s*<\s*x\s*<\s*$2/],
    [/\(([^;,]+)[;,]\s*∞\)/, /x\s*>\s*$1/]
  ];

  for (const [pattern, replacement] of equivalentNotations) {
    if (normalizedUser.match(pattern) && normalizedCorrect.match(replacement)) {
      return true;
    }
    if (normalizedCorrect.match(pattern) && normalizedUser.match(replacement)) {
      return true;
    }
  }

  return false;
}

/**
 * Grades algebraic expressions with basic equivalence checking
 * @param {string} userAnswer - User's algebraic answer
 * @param {Object} question - Question data
 * @returns {boolean} - Whether the algebraic answer is correct
 */
function gradeAlgebraicAnswer(userAnswer, question) {
  // First try exact matching with variations
  if (checkAnswerVariations(userAnswer, question)) {
    return true;
  }

  // Basic algebraic normalization
  const normalizedUser = normalizeText(userAnswer, false);
  const correctAnswer = question.correctAnswer?.answer || question.correctAnswer;
  const normalizedCorrect = normalizeText(correctAnswer, false);

  // Handle common algebraic equivalences
  const algebraicEquivalents = [
    // Multiplication order: 2x vs x*2 vs x2
    [/(\d+)([a-z])/g, '$1*$2'],
    [/([a-z])(\d+)/g, '$1*$2'],
    // Power notation: x^2 vs x²
    [/\^2/g, '²'],
    [/\^3/g, '³'],
    // Parentheses normalization
    [/\s*\*\s*\(/g, '*('],
    [/\)\s*\*/g, ')*']
  ];

  let processedUser = normalizedUser;
  let processedCorrect = normalizedCorrect;

  for (const [pattern, replacement] of algebraicEquivalents) {
    processedUser = processedUser.replace(pattern, replacement);
    processedCorrect = processedCorrect.replace(pattern, replacement);
  }

  return processedUser === processedCorrect;
}

/**
 * Main grading function for short answer questions
 * @param {Object} question - Question data with answer information
 * @param {string} userAnswer - User's submitted answer
 * @returns {Object} - Grading result with detailed feedback
 */
function gradeShortAnswer(question, userAnswer) {
  if (!userAnswer || typeof userAnswer !== 'string') {
    return {
      questionId: question.id,
      format: 'short_answer',
      userAnswer: userAnswer || '',
      correctAnswer: question.correctAnswer?.answer || question.correctAnswer,
      isCorrect: false,
      marksAwarded: 0,
      maxMarks: question.maxMarks || question.marks || 1,
      feedback: 'No answer provided'
    };
  }

  const answerType = question.answerType || 'text';
  let isCorrect = false;
  let feedback = '';

  try {
    switch (answerType.toLowerCase()) {
      case 'numerical':
        isCorrect = gradeNumericalAnswer(userAnswer, question);
        feedback = isCorrect ? 'Correct numerical answer' : 'Incorrect numerical value';
        break;

      case 'coordinates':
        isCorrect = gradeCoordinateAnswer(userAnswer, question);
        feedback = isCorrect ? 'Correct coordinates' : 'Incorrect coordinate values';
        break;

      case 'domain_range':
        isCorrect = gradeDomainRangeAnswer(userAnswer, question);
        feedback = isCorrect ? 'Correct domain/range' : 'Incorrect domain/range notation';
        break;

      case 'equation':
      case 'algebraic':
        isCorrect = gradeAlgebraicAnswer(userAnswer, question);
        feedback = isCorrect ? 'Correct algebraic expression' : 'Incorrect algebraic form';
        break;

      default:
        // Default text matching with variations
        isCorrect = checkAnswerVariations(userAnswer, question);
        feedback = isCorrect ? 'Correct answer' : 'Answer does not match expected response';
        break;
    }
  } catch (error) {
    console.error(`Error grading question ${question.id}:`, error);
    isCorrect = false;
    feedback = 'Error processing answer';
  }

  const maxMarks = question.maxMarks || question.marks || 1;

  return {
    questionId: question.id,
    format: 'short_answer',
    answerType: answerType,
    userAnswer: userAnswer,
    correctAnswer: question.correctAnswer?.answer || question.correctAnswer,
    acceptedVariations: question.correctAnswer?.variations || question.answerVariations || [],
    isCorrect: isCorrect,
    marksAwarded: isCorrect ? maxMarks : 0,
    maxMarks: maxMarks,
    feedback: feedback,
    caseSensitive: question.caseSensitive || false,
    tolerance: question.tolerance || 0
  };
}

/**
 * Grades multiple short answer questions in batch
 * @param {Object} submissions - Object with questionId as keys and answers as values
 * @returns {Array} - Array of grading results
 */
async function gradeShortAnswerSubmissions(submissions) {
  const questionIds = Object.keys(submissions);

  if (questionIds.length === 0) {
    return {
      results: [],
      statistics: {
        totalQuestions: 0,
        correctAnswers: 0,
        totalMarks: 0,
        marksAwarded: 0,
        percentage: 0
      },
      gradedAt: new Date().toISOString()
    };
  }

  // Fetch questions from database (single document structure)
  const questions = await fetchSingleDocumentForGrading(questionIds);

  const gradingResults = [];

  for (const question of questions) {
    const submissionValue = submissions[question.id];

    // Extract answer from submission object if needed
    const userAnswer = typeof submissionValue === 'object' && submissionValue !== null
      ? submissionValue.answer
      : submissionValue;

    console.log(`Grading question ${question.id}: "${userAnswer}"`);
    const result = gradeShortAnswer(question, userAnswer);
    gradingResults.push(result);
  }

  // Calculate statistics
  const totalQuestions = gradingResults.length;
  const correctAnswers = gradingResults.filter(r => r.isCorrect).length;
  const totalMarks = gradingResults.reduce((sum, r) => sum + (r.maxMarks || 0), 0);
  const marksAwarded = gradingResults.reduce((sum, r) => sum + (r.marksAwarded || 0), 0);
  const percentage = totalMarks > 0 ? Math.round((marksAwarded / totalMarks) * 100) : 0;

  return {
    results: gradingResults,
    statistics: {
      totalQuestions,
      correctAnswers,
      totalMarks,
      marksAwarded,
      percentage
    },
    gradedAt: new Date().toISOString()
  };
}

module.exports = {
  normalizeText,
  checkAnswerVariations,
  gradeNumericalAnswer,
  gradeCoordinateAnswer,
  gradeDomainRangeAnswer,
  gradeAlgebraicAnswer,
  gradeShortAnswer,
  gradeShortAnswerSubmissions
};