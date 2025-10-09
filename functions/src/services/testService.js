const { safeArray, mapQuestionData, normalizePaperFormat } = require('../helpers/dataHelpers');
const { 
  buildQuestionQuery, 
  fetchBlueprint, 
  executeQuestionQuery,
  enrichQuestionWithParent,
  hasParent 
} = require('./databaseService');
const { generateBlueprintCompliantTest } = require('./enhancedTestService');
// ✅ SHORT ANSWER FIX: Removed unused import - short answers now use standard generation
// const { generateShortAnswerTest } = require('./shortAnswerTestService');

function parsePqpSegments(questionNumber) {
  if (!questionNumber || typeof questionNumber !== 'string') {
    return [];
  }

  return questionNumber
    .split('.')
    .map((segment) => {
      const numeric = parseInt(segment, 10);
      return Number.isFinite(numeric) ? numeric : 0;
    });
}

function extractQuestionNumber(question) {
  if (!question || typeof question !== 'object') {
    return null;
  }

  const pqpNumber = question?.pqpData?.questionNumber;
  if (pqpNumber && typeof pqpNumber === 'string') {
    return pqpNumber;
  }

  const directNumber = question.questionNumber;
  if (typeof directNumber === 'string') {
    return directNumber;
  }

  if (typeof directNumber === 'number') {
    return directNumber.toString();
  }

  return null;
}

function comparePqpQuestionNumbers(a, b) {
  const aSegments = parsePqpSegments(extractQuestionNumber(a));
  const bSegments = parsePqpSegments(extractQuestionNumber(b));

  const maxLength = Math.max(aSegments.length, bSegments.length);

  for (let index = 0; index < maxLength; index += 1) {
    const aValue = index < aSegments.length ? aSegments[index] : 0;
    const bValue = index < bSegments.length ? bSegments[index] : 0;

    if (aValue !== bValue) {
      return aValue - bValue;
    }
  }

  return 0;
}

function sortQuestionsByPqpNumber(questions) {
  if (!Array.isArray(questions) || questions.length === 0) {
    return questions;
  }

  const hasPqpNumbers = questions.some((question) => extractQuestionNumber(question));
  if (!hasPqpNumbers) {
    return questions;
  }

  const sorted = [...questions].sort(comparePqpQuestionNumbers);

  return sorted.map((question, index) => ({
    ...question,
    questionNumber: index + 1,
  }));
}

function shouldSortByPqp(params) {
  if (!params || typeof params !== 'object') {
    return false;
  }

  const mode = (params.mode || '').toString().toLowerCase();

  return mode === 'full_exam' || mode === 'pqp' || params.isPQPMode === true;
}

/**
 * Test generation service for creating past paper tests
 */

/**
 * Selects random questions from a pool based on count requirement
 * Supports optional seeded randomness.
 * @param {Array} questionDocs - Array of question documents
 * @param {number} requiredCount - Number of questions needed
 * @param {Object} [options]
 * @param {number|string} [options.seed] - Optional seed for deterministic shuffle
 * @returns {Array} - Selected questions
 */
function selectRandomQuestions(questionDocs, requiredCount, options = {}) {
  if (questionDocs.length <= requiredCount) {
    return questionDocs;
  }

  const { seed } = options;

  // Small seeded RNG (Mulberry32-ish)
  const createSeededRandom = (s) => {
    let t = (s >>> 0) || 0x9e3779b9;
    return () => {
      t += 0x6D2B79F5;
      let x = Math.imul(t ^ (t >>> 15), 1 | t);
      x ^= x + Math.imul(x ^ (x >>> 7), 61 | x);
      return ((x ^ (x >>> 14)) >>> 0) / 4294967296;
    };
  };

  const toSeedNumber = (s) => {
    if (typeof s === 'number') return s;
    if (typeof s === 'string') {
      let h = 0;
      for (let i = 0; i < s.length; i++) h = (h * 31 + s.charCodeAt(i)) | 0;
      return h >>> 0;
    }
    return undefined;
  };

  const rand = seed !== undefined ? createSeededRandom(toSeedNumber(seed)) : Math.random;

  // Fisher-Yates shuffle algorithm (seeded if provided)
  const shuffled = [...questionDocs];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(rand() * (i + 1));
    [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
  }

  return shuffled.slice(0, requiredCount);
}

/**
 * Processes questions for specific format requirements
 * Option 3: Enriches questions with parent context if applicable
 * @param {Array} questions - Array of question data
 * @param {string} format - Question format type
 * @returns {Promise<Array>} - Processed questions with parent context
 */
async function processQuestionsForFormat(questions, format) {
  const processedQuestions = [];
  
  for (const question of questions) {
    let processedQuestion = { ...question };

    // OPTION 3: Enrich with parent context if question has parent
    if (hasParent(question)) {
      processedQuestion = await enrichQuestionWithParent(processedQuestion);
    }

    // Ensure drag and drop questions have complete data
    if (format === 'dragAndDrop') {
      processedQuestion.dragItems = safeArray(question.dragItems);
      processedQuestion.dragTargets = safeArray(question.dragTargets);
      processedQuestion.dropTargets = safeArray(question.dropTargets || question.dragTargets);

      console.log(`Processed drag-and-drop question ${question.id}:`, {
        dragItems: processedQuestion.dragItems.length,
        dropTargets: processedQuestion.dropTargets.length
      });
    }

    // Ensure short answer questions have complete data
    if (format === 'shortAnswer' || format === 'short_answer') {
      processedQuestion.answerType = question.answerType || 'text';
      processedQuestion.caseSensitive = question.caseSensitive || false;
      processedQuestion.tolerance = question.tolerance || 0;

      // Handle answer variations
      if (question.correctAnswer && typeof question.correctAnswer === 'object') {
        processedQuestion.answerVariations = question.correctAnswer.variations || [];
      } else {
        processedQuestion.answerVariations = question.answerVariations || [];
      }

      console.log(`Processed short-answer question ${question.id}:`, {
        answerType: processedQuestion.answerType,
        variations: processedQuestion.answerVariations.length
      });
    }

    processedQuestions.push(processedQuestion);
  }
  
  return processedQuestions;
}

/**
 * Generates questions for a specific format section
 * @param {Object} formatConfig - Format configuration from blueprint
 * @param {Object} params - Query parameters
 * @returns {Array} - Generated questions for this format
 */
async function generateQuestionsForFormat(formatConfig, params) {
  console.log(`Generating ${formatConfig.questionCount} questions for format: ${formatConfig.format}`);

  // Build and execute query
  const query = buildQuestionQuery({
    ...params,
    limit: formatConfig.questionCount * 3 // Get more questions for better selection
  });

  const questionDocs = await executeQuestionQuery(query, params);

  // Map document data
  const questionData = questionDocs.map(doc => mapQuestionData(doc));

  // IMPORTANT: Filter out parent questions (they're context providers, not answerable questions)
  // Parents have isParent: true and should NEVER appear as standalone questions in tests
  const answerableQuestions = questionData.filter(q => !q.isParent);
  
  if (answerableQuestions.length < questionData.length) {
    console.log(`🚫 Filtered out ${questionData.length - answerableQuestions.length} parent questions (context documents)`);
  }

  // Filter by format if specified
  const filteredQuestions = formatConfig.format 
    ? answerableQuestions.filter(q => q.format === formatConfig.format)
    : answerableQuestions;

  console.log(`Found ${filteredQuestions.length} questions for format ${formatConfig.format}`);

  // Select required number of questions
  const selectedQuestions = selectRandomQuestions(filteredQuestions, formatConfig.questionCount);

  // Process questions for format-specific requirements (now async)
  const processedQuestions = await processQuestionsForFormat(selectedQuestions, formatConfig.format);

  return processedQuestions;
}

/**
 * Generates a complete test paper based on blueprint
 * @param {Object} params - Test generation parameters
 * @returns {Object} - Generated test data
 */
async function generateTestPaper(params) {
  console.log('Generating test with params:', params);

  // ✅ SHORT ANSWER FIX: Removed special routing - now treated like MCQs (individual documents)
  // Short answers are now fetched using standard query below, same as MCQ/True-False/Drag-Drop
  // if (params.format === 'short_answer' || params.questionType === 'short_answer') {
  //   console.log(`📝 Generating short answer test in ${params.mode || 'pqp'} mode`);
  //   return generateShortAnswerTest(params);
  // }

  // Special handling for topic-based tests (no blueprint needed)
  if (params.mode === 'by_topic' && params.topic) {
    console.log(`🎯 Generating topic-based test for: ${params.topic}`);
    return generateTopicBasedTest(params);
  }

  try {
    // Try enhanced blueprint-compliant generation first
    const enhancedResult = await generateBlueprintCompliantTest(params);
    
    if (enhancedResult && enhancedResult.questions && enhancedResult.questions.length > 0) {
      console.log(`✅ Enhanced generation successful: ${enhancedResult.questions.length} questions`);
      const sortedQuestions = shouldSortByPqp(params)
        ? sortQuestionsByPqpNumber(enhancedResult.questions)
        : enhancedResult.questions;
      return {
        questions: sortedQuestions,
        totalQuestions: enhancedResult.totalQuestions,
        blueprint: enhancedResult.blueprint,
        params: params,
        generatedAt: enhancedResult.generatedAt,
        complianceReport: enhancedResult.complianceReport,
        topicDistribution: enhancedResult.topicDistribution,
        cognitiveDistribution: enhancedResult.cognitiveDistribution
      };
    }
  } catch (enhancedError) {
    console.warn('Enhanced generation failed, falling back to legacy:', enhancedError.message);
  }

  // Fallback to legacy generation if enhanced fails
  console.log('🔄 Using legacy test generation as fallback');
  return generateLegacyTestPaper(params);
}

/**
 * Legacy test generation method (fallback)
 * @param {Object} params - Test generation parameters
 * @returns {Object} - Generated test data
 */
async function generateLegacyTestPaper(params) {
  // Fetch blueprint for paper format (using original format)
  const blueprintId = `${params.subject}_${normalizePaperFormat(params.paper)}_gr${params.grade}`.toLowerCase();
  console.log('Looking for blueprint with ID:', blueprintId);
  const blueprint = await fetchBlueprint(blueprintId);

  const generatedQuestions = [];
  let questionNumber = 1;

  // Check if blueprint has formats (new structure) or use legacy approach
  if (blueprint.formats && Array.isArray(blueprint.formats)) {
    // New blueprint structure with formats
    for (const formatConfig of blueprint.formats) {
      const formatQuestions = await generateQuestionsForFormat(formatConfig, params);

      // Add question numbers and format info
      const numberedQuestions = formatQuestions.map(question => ({
        ...question,
        questionNumber: questionNumber++,
        sectionFormat: formatConfig.format,
        maxMarks: formatConfig.marksPerQuestion || 1
      }));

      generatedQuestions.push(...numberedQuestions);
    }
  } else {
    // Legacy blueprint structure - generate questions directly
    console.log('Using legacy blueprint structure');
    
    const totalQuestions = blueprint.totalQuestions || 
      Math.ceil(blueprint.totalMarks / 5) || // Estimate based on marks
      20; // Default fallback
    
    console.log(`Generating ${totalQuestions} questions for legacy blueprint`);

    // Build and execute query
    const query = buildQuestionQuery({
      ...params,
      limit: totalQuestions * 2 // Get more questions for better selection
    });

    const questionDocs = await executeQuestionQuery(query, params);

    // Map document data
    const questionData = questionDocs.map(doc => mapQuestionData(doc));

    // IMPORTANT: Filter out parent questions (they're context providers, not answerable questions)
    const answerableQuestions = questionData.filter(q => !q.isParent);
    
    if (answerableQuestions.length < questionData.length) {
      console.log(`🚫 Filtered out ${questionData.length - answerableQuestions.length} parent questions from legacy test`);
    }

    // Select required number of questions
    const selectedQuestions = selectRandomQuestions(answerableQuestions, totalQuestions);

    // Add question numbers
    const numberedQuestions = selectedQuestions.map(question => ({
      ...question,
      questionNumber: questionNumber++,
      maxMarks: question.marks || 1
    }));

    generatedQuestions.push(...numberedQuestions);
  }

  console.log(`Generated ${generatedQuestions.length} total questions`);

  const orderedQuestions = shouldSortByPqp(params)
    ? sortQuestionsByPqpNumber(generatedQuestions)
    : generatedQuestions;

  return {
    questions: orderedQuestions,
    totalQuestions: orderedQuestions.length,
    blueprint: blueprint,
    params: params,
    generatedAt: new Date().toISOString()
  };
}

/**
 * Generates questions for a specific topic (no blueprint needed)
 * @param {Object} params - Test generation parameters including topic
 * @returns {Object} - Generated test data
 */
async function generateTopicBasedTest(params) {
  console.log(`🎯 Generating topic-based test for topic: ${params.topic}`);
  
  const defaultQuestionCount = 10; // Default number of questions for topic practice
  const questionCount = params.questionCount || defaultQuestionCount;
  const poolFactor = Number(params.poolFactor || 5); // Wider sampling for better randomness
  const excludeIds = Array.isArray(params.excludeIds) ? new Set(params.excludeIds) : null;
  const seed = params.seed; // optional deterministic shuffle
  
  try {
    // Build query to find questions for the specific topic
    const query = buildQuestionQuery({
      ...params,
      topic: params.topic, // This will filter questions by topic
      // Sample a larger pool to improve randomness
      limit: Math.max(questionCount * poolFactor, questionCount)
    });

    console.log(`📝 Searching for questions with topic: ${params.topic}`);
    const questionDocs = await executeQuestionQuery(query, params);
    
    if (questionDocs.length === 0) {
      console.warn(`⚠️ No questions found for topic: ${params.topic}`);
      return {
        questions: [],
        totalQuestions: 0,
        params: params,
        generatedAt: new Date().toISOString(),
        error: `No questions available for topic: ${params.topic}`
      };
    }

    console.log(`📋 Found ${questionDocs.length} questions for topic: ${params.topic}`);

    // Map document data to question format
    let questionData = questionDocs.map(doc => mapQuestionData(doc));

    // IMPORTANT: Filter out parent questions (they're context providers, not answerable questions)
    questionData = questionData.filter(q => !q.isParent);
    
    if (questionDocs.length > questionData.length) {
      console.log(`🚫 Filtered out ${questionDocs.length - questionData.length} parent questions from topic test`);
    }

    // Exclude previously seen question IDs if provided
    if (excludeIds && excludeIds.size > 0) {
      const before = questionData.length;
      questionData = questionData.filter(q => q && q.id && !excludeIds.has(q.id));
      console.log(`🧹 Excluded ${before - questionData.length} previously seen questions (remain ${questionData.length})`);
    }

    // Select required number of questions randomly
    const selectedQuestions = selectRandomQuestions(questionData, questionCount, { seed });

    // Add question numbers
    let questionNumber = 1;
    const numberedQuestions = selectedQuestions.map(question => ({
      ...question,
      questionNumber: questionNumber++,
      maxMarks: question.marks || question.maxMarks || 1
    }));

    console.log(`✅ Generated ${numberedQuestions.length} questions for topic: ${params.topic}`);

    return {
      questions: numberedQuestions,
      totalQuestions: numberedQuestions.length,
      params: params,
      generatedAt: new Date().toISOString(),
      topicDistribution: {
        [params.topic]: numberedQuestions.length
      }
    };

  } catch (error) {
    console.error(`❌ Error generating topic-based test for ${params.topic}:`, error);
    throw new Error(`Failed to generate questions for topic: ${params.topic}`);
  }
}

module.exports = {
  selectRandomQuestions,
  processQuestionsForFormat,
  generateQuestionsForFormat,
  generateTestPaper,
  generateLegacyTestPaper,
  generateTopicBasedTest
};
