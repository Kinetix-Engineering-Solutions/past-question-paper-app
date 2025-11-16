const { safeArray } = require('../helpers/dataHelpers');
const { fetchQuestionsForGrading, saveUserTestResults } = require('./databaseService');
const { gradeShortAnswer, gradeShortAnswerSubmissions } = require('./shortAnswerGradingService');

/**
 * Grading service for evaluating test submissions
 */

/**
 * Grades a multiple choice question
 * @param {Object} question - Question data
 * @param {string} userAnswer - User's selected answer
 * @returns {Object} - Grading result
 */
function gradeMultipleChoice(question, userAnswer) {
  // Normalize both answers for comparison (trim whitespace, case-insensitive)
  const normalizedUserAnswer = (userAnswer || '').toString().trim().toUpperCase();
  const normalizedCorrectAnswer = (question.correctAnswer || '').toString().trim().toUpperCase();

  const isCorrect = normalizedUserAnswer === normalizedCorrectAnswer;
  const maxMarks = question.maxMarks || question.marks || 2;

  return {
    questionId: question.id,
    format: 'multipleChoice',
    userAnswer: userAnswer,
    correctAnswer: question.correctAnswer,
    isCorrect: isCorrect,
    marksAwarded: isCorrect ? maxMarks : 0,
    maxMarks: maxMarks
  };
}

/**
 * Grades a true/false question
 * @param {Object} question - Question data
 * @param {boolean} userAnswer - User's true/false answer
 * @returns {Object} - Grading result
 */
function gradeTrueFalse(question, userAnswer) {
  // Normalize both answers for comparison (handles "true"/"false" strings and booleans)
  const normalizedUserAnswer = (userAnswer || '').toString().trim().toLowerCase();
  const normalizedCorrectAnswer = (question.correctAnswer || '').toString().trim().toLowerCase();

  const isCorrect = normalizedUserAnswer === normalizedCorrectAnswer;
  const maxMarks = question.maxMarks || question.marks || 1;

  return {
    questionId: question.id,
    format: 'trueFalse',
    userAnswer: userAnswer,
    correctAnswer: question.correctAnswer,
    isCorrect: isCorrect,
    marksAwarded: isCorrect ? maxMarks : 0,
    maxMarks: maxMarks
  };
}

/**
 * Grades a drag and drop question - supports both matching and ordering formats
 * @param {Object} question - Question data
 * @param {string|Array} userAnswers - User's drag and drop answers
 * @returns {Object} - Grading result
 */
function gradeDragAndDrop(question, userAnswers) {
  console.log(`Grading drag-and-drop question ${question.id}:`);
  console.log('User answers:', userAnswers);
  
  // Check if this is ordering format (steps arrangement)
  if (question.correctOrder && Array.isArray(question.correctOrder) && question.correctOrder.length > 0) {
    return gradeDragAndDropOrdering(question, userAnswers);
  } else {
    // Traditional matching format
    return gradeDragAndDropMatching(question, userAnswers);
  }
}

/**
 * Grades drag and drop questions in ordering/sequencing format
 * Uses South African step-based marking guidelines where each correct step
 * receives a proportional mark value (total marks / number of steps)
 * @param {Object} question - Question data
 * @param {string|Array} userAnswers - User's ordered sequence
 * @returns {Object} - Grading result with step-based marking
 */
function gradeDragAndDropOrdering(question, userAnswers) {
  console.log('=== GRADING DRAG-AND-DROP ORDERING ===');
  console.log('Question ID:', question.id);
  console.log('Question correctOrder:', question.correctOrder);
  console.log('User answers (raw):', userAnswers, 'Type:', typeof userAnswers);
  
  const correctOrder = safeArray(question.correctOrder);
  let userOrderArray;
  
  // Parse user answers if they come as string
  if (typeof userAnswers === 'string') {
    try {
      // Handle format like "item1,item2,item3" (comma-separated)
      // Note: Avoid using -> in the regex as it can interfere with step IDs containing numbers
      userOrderArray = userAnswers.split(',').map(s => s.trim()).filter(s => s);
      console.log('Parsed user answers:', userOrderArray);
    } catch (e) {
      console.log('Error parsing user answers:', e);
      userOrderArray = [];
    }
  } else {
    userOrderArray = safeArray(userAnswers);
    console.log('User answers as array:', userOrderArray);
  }
  
  console.log('Expected order:', correctOrder);
  console.log('User order:', userOrderArray);

  let correctCount = 0;
  const detailedResults = [];
  const totalSteps = correctOrder.length;
  const maxMarks = question.maxMarks || question.marks || totalSteps;
  
  // Calculate marks per step following SA guidelines
  const marksPerStep = maxMarks / totalSteps;

  // Check each position in the correct sequence (SA step-based marking)
  correctOrder.forEach((correctStep, index) => {
    const userStep = userOrderArray[index];
    // Normalize both for comparison (trim whitespace, case-sensitive for step IDs)
    const normalizedCorrectStep = (correctStep || '').toString().trim();
    const normalizedUserStep = (userStep || '').toString().trim();
    const isCorrect = normalizedCorrectStep === normalizedUserStep;
    const stepMarks = isCorrect ? marksPerStep : 0;

    if (isCorrect) correctCount++;

    detailedResults.push({
      stepPosition: index + 1,
      userAnswer: userStep || 'Not provided',
      correctAnswer: correctStep,
      isCorrect: isCorrect,
      marksAwarded: stepMarks,
      marksAvailable: marksPerStep
    });
  });

  // Direct step-based marking: each correct step gets its proportion of marks
  const marksAwarded = correctCount * marksPerStep;
  const percentage = totalSteps > 0 ? (correctCount / totalSteps) : 0;

  const result = {
    questionId: question.id,
    format: 'dragAndDrop',
    subFormat: 'ordering',
    userAnswers: userOrderArray,
    correctOrder: correctOrder,
    correctCount: correctCount,
    totalSteps: totalSteps,
    marksPerStep: marksPerStep,
    percentage: percentage,
    detailedResults: detailedResults,
    isCorrect: marksAwarded >= (maxMarks * 0.5), // 50% threshold for SA guidelines
    marksAwarded: marksAwarded,
    maxMarks: maxMarks,
    markingMethod: 'step-based', // Identifier for SA step-based marking
    explanation: `Each correct step awards ${marksPerStep.toFixed(2)} marks. Total: ${correctCount}/${totalSteps} steps correct.`
  };
  
  console.log('=== GRADING RESULT ===');
  console.log('Question:', question.id);
  console.log('Correct count:', correctCount, 'out of', totalSteps);
  console.log('Marks awarded:', marksAwarded, 'out of', maxMarks);
  console.log('Is correct:', result.isCorrect);
  console.log('Threshold check:', marksAwarded, '>=', (maxMarks * 0.5), '?', marksAwarded >= (maxMarks * 0.5));
  console.log('=== END GRADING ===\n');
  
  return result;
}

/**
 * Grades drag and drop questions in traditional matching format
 * @param {Object} question - Question data
 * @param {string|Array} userAnswers - User's drag and drop mappings
 * @returns {Object} - Grading result
 */
function gradeDragAndDropMatching(question, userAnswers) {
  const dragTargets = safeArray(question.dragTargets || question.dropTargets);
  let userAnswersArray;
  
  // Parse user answers if they come as string format "target1:item1,target2:item2"
  if (typeof userAnswers === 'string') {
    try {
      const pairs = userAnswers.split(',');
      userAnswersArray = pairs.map(pair => {
        const [target, item] = pair.split(':');
        return { target: target?.trim(), item: item?.trim() };
      });
    } catch (e) {
      userAnswersArray = safeArray(userAnswers);
    }
  } else {
    userAnswersArray = safeArray(userAnswers);
  }
  
  console.log('Expected targets:', dragTargets);
  console.log('User answers:', userAnswersArray);

  let correctCount = 0;
  const detailedResults = [];

  // Check each drag target
  dragTargets.forEach((target, index) => {
    const userMapping = userAnswersArray.find(ua => ua.target === target.id) || userAnswersArray[index];
    const userAnswer = userMapping?.item || userMapping;
    const expectedAnswer = target.correctPair || target.correctAnswer;
    // Normalize both for comparison (trim whitespace, case-sensitive for IDs)
    const normalizedUserAnswer = (userAnswer || '').toString().trim();
    const normalizedExpectedAnswer = (expectedAnswer || '').toString().trim();
    const isCorrect = normalizedUserAnswer === normalizedExpectedAnswer;

    if (isCorrect) correctCount++;

    detailedResults.push({
      targetId: target.id || index,
      targetText: target.text || target.label,
      userAnswer: userAnswer,
      correctAnswer: expectedAnswer,
      isCorrect: isCorrect
    });
  });

  const totalTargets = dragTargets.length;
  const percentage = totalTargets > 0 ? (correctCount / totalTargets) : 0;
  const maxMarks = question.maxMarks || totalTargets;
  const marksAwarded = Math.round(maxMarks * percentage);

  return {
    questionId: question.id,
    format: 'dragAndDrop',
    subFormat: 'matching',
    userAnswers: userAnswersArray,
    correctCount: correctCount,
    totalTargets: totalTargets,
    percentage: percentage,
    detailedResults: detailedResults,
    isCorrect: percentage >= 0.5, // 50% threshold for matching questions
    marksAwarded: marksAwarded,
    maxMarks: maxMarks
  };
}

/**
 * Grades a fill in the blanks question
 * @param {Object} question - Question data
 * @param {Array} userAnswers - User's answers for each blank
 * @returns {Object} - Grading result
 */
function gradeFillInBlanks(question, userAnswers) {
  const expectedAnswers = safeArray(question.correctAnswers);
  const userAnswersArray = safeArray(userAnswers);
  
  let correctCount = 0;
  const detailedResults = [];

  expectedAnswers.forEach((expectedAnswer, index) => {
    const userAnswer = (userAnswersArray[index] || '').toString().trim().toLowerCase();
    const expected = expectedAnswer.toString().trim().toLowerCase();
    const isCorrect = userAnswer === expected;
    
    if (isCorrect) correctCount++;
    
    detailedResults.push({
      blankIndex: index,
      userAnswer: userAnswersArray[index],
      correctAnswer: expectedAnswer,
      isCorrect: isCorrect
    });
  });

  const totalBlanks = expectedAnswers.length;
  const percentage = totalBlanks > 0 ? (correctCount / totalBlanks) : 0;
  const maxMarks = question.maxMarks || totalBlanks;
  const marksAwarded = Math.round(maxMarks * percentage);

  return {
    questionId: question.id,
    format: 'fillInBlanks',
    userAnswers: userAnswersArray,
    correctCount: correctCount,
    totalBlanks: totalBlanks,
    percentage: percentage,
    detailedResults: detailedResults,
    isCorrect: percentage >= 0.5,
    marksAwarded: marksAwarded,
    maxMarks: maxMarks
  };
}

/**
 * Grades a single question based on its format
 * @param {Object} question - Question data
 * @param {Object} submission - User's submission for this question
 * @returns {Object} - Grading result
 */
function gradeSingleQuestion(question, submission) {
  const format = question.format || 'multipleChoice';
  
  console.log(`Grading question ${question.id} with format: ${format}`);

  // Normalize format for consistent handling
  const normalizedFormat = format.toLowerCase().replace(/[-_]/g, '');

  switch (normalizedFormat) {
    case 'multiplechoice':
    case 'mcq':
      return gradeMultipleChoice(question, submission.answer);
      
    case 'truefalse':
      return gradeTrueFalse(question, submission.answer);
      
    case 'draganddrop':
    case 'dragdrop':  // Handle drag_drop format (becomes dragdrop after normalization)
      return gradeDragAndDrop(question, submission.answers || submission.answer);
      
    case 'fillinblanks':
      return gradeFillInBlanks(question, submission.answers || submission.answer);

    case 'shortanswer':
    case 'short_answer':
      return gradeShortAnswer(question, submission.answer);

    default:
      console.warn(`Unknown question format: ${format}. Defaulting to multiple choice.`);
      return gradeMultipleChoice(question, submission.answer);
  }
}

/**
 * Calculates overall test statistics
 * @param {Array} results - Individual question results
 * @returns {Object} - Test statistics
 */
function calculateTestStatistics(results) {
  const totalQuestions = results.length;
  const correctQuestions = results.filter(r => r.isCorrect).length;
  const totalMarks = results.reduce((sum, r) => sum + (r.maxMarks || 0), 0);
  const marksAwarded = results.reduce((sum, r) => sum + (r.marksAwarded || 0), 0);
  
  const percentage = totalMarks > 0 ? Math.round((marksAwarded / totalMarks) * 100) : 0;
  
  // Calculate grade based on percentage
  let grade = 'F';
  if (percentage >= 90) grade = 'A+';
  else if (percentage >= 80) grade = 'A';
  else if (percentage >= 70) grade = 'B';
  else if (percentage >= 60) grade = 'C';
  else if (percentage >= 50) grade = 'D';

  return {
    totalQuestions,
    correctQuestions,
    totalMarks,
    marksAwarded,
    percentage,
    grade,
    accuracy: totalQuestions > 0 ? Math.round((correctQuestions / totalQuestions) * 100) : 0
  };
}

/**
 * Grades a complete test submission
 * @param {Object} params - Grading parameters
 * @returns {Object} - Complete grading results
 */
async function gradeTestSubmission(params) {
  const { submissions, userId, metadata = {} } = params;

  console.log('Grading test submission:', {
    submissionCount: Object.keys(submissions).length,
    subject: metadata.subject,
    mode: metadata.mode,
  });

  // Get question IDs from submissions
  const questionIds = Object.keys(submissions);

  // ✅ SHORT ANSWER FIX: Removed mega-document check
  // Short answers now use individual documents (sa_math_001, sa_math_002, etc.)
  // They're graded using the standard flow below, just like MCQs
  // if (questionIds.includes('short answer')) {
  //   console.log('📝 Routing to short answer grading service');
  //   return await gradeShortAnswerSubmissions(submissions);
  // }

  // Fetch questions from database (for MCQ, True/False, Drag-Drop, and Short Answer)
  const questionDocs = await fetchQuestionsForGrading(questionIds);
  
  // Create question lookup map
  const questionsMap = {};
  questionDocs.forEach(doc => {
    questionsMap[doc.id] = { id: doc.id, ...doc.data() };
  });

  // Grade each question
  const results = [];
  for (const questionId of questionIds) {
    const question = questionsMap[questionId];
    const submissionValue = submissions[questionId];
    
    if (question) {
      // Handle truly unanswered questions (null or undefined only)
      // Empty string ("") is treated as a valid answer (e.g., for drag-drop with no items selected)
      if (submissionValue === undefined || submissionValue === null) {
        console.warn(`⚠️ Unanswered question: ${questionId} - Grading as 0 marks`);
        
        // DEBUG: Check what marks field is available in question
        console.log(`Question ${questionId} marks fields:`, {
          maxMarks: question.maxMarks,
          marks: question.marks,
          availableFields: Object.keys(question)
        });
        
        // Create a "no answer" result for unanswered questions
        const format = (question.format || 'multipleChoice').toLowerCase().replace(/[-_]/g, '');
        const noAnswerResult = {
          questionId: question.id,
          format: question.format,
          userAnswer: null,
          correctAnswer: question.correctAnswer,
          isCorrect: false,
          marksAwarded: 0,
          maxMarks: question.maxMarks || question.marks || 2,
          wasUnanswered: true
        };
        
        results.push(noAnswerResult);
      } else {
        // Normalize submission format - handle both object and direct value formats
        const submission = typeof submissionValue === 'object' && submissionValue !== null
          ? submissionValue
          : { answer: submissionValue };
        
        console.log(`Processing submission for ${questionId}:`, submission);
        
        const result = gradeSingleQuestion(question, submission);
        results.push(result);
      }
    } else {
      console.warn(`Missing question for ID: ${questionId}`);
    }
  }

  // Calculate overall statistics
  const baseStatistics = calculateTestStatistics(results);
  const statistics = {
    ...baseStatistics,
    totalQuestions: metadata.totalQuestions || baseStatistics.totalQuestions || results.length,
    subject: metadata.subject || null,
    paper: metadata.paper || null,
    mode: metadata.mode || 'Practice',
    durationMinutes: metadata.durationMinutes ?? null,
    sessionDurationSeconds: metadata.sessionDurationSeconds ?? null,
    flags: metadata.flags || {},
  };

  const gradedAtIso = metadata.submittedAt || new Date().toISOString();

  const gradingResult = {
    results: results,
    statistics: statistics,
    metadata: {
      ...metadata,
      totalQuestions: statistics.totalQuestions,
      subject: statistics.subject,
      paper: statistics.paper,
      mode: statistics.mode,
      durationMinutes: statistics.durationMinutes,
      sessionDurationSeconds: statistics.sessionDurationSeconds,
    },
    gradedAt: gradedAtIso,
    userId: userId
  };

  // Save results to user's profile (non-blocking)
  if (userId) {
    saveUserTestResults(userId, gradingResult).catch(console.error);
  }

  console.log('Grading completed:', statistics);
  return gradingResult;
}

module.exports = {
  gradeMultipleChoice,
  gradeTrueFalse,
  gradeDragAndDrop,
  gradeFillInBlanks,
  gradeSingleQuestion,
  calculateTestStatistics,
  gradeTestSubmission
};
