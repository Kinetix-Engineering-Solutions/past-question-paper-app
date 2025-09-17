const { safeArray, mapQuestionData, normalizePaperFormat } = require('../helpers/dataHelpers');
const { buildQuestionQuery, fetchBlueprint, executeQuestionQuery } = require('./databaseService');
const { generateBlueprintCompliantTest } = require('./enhancedTestService');

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
 * @param {Array} questions - Array of question data
 * @param {string} format - Question format type
 * @returns {Array} - Processed questions
 */
function processQuestionsForFormat(questions, format) {
  return questions.map(question => {
    const processedQuestion = { ...question };

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

    return processedQuestion;
  });
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

  // Filter by format if specified
  const filteredQuestions = formatConfig.format 
    ? questionData.filter(q => q.format === formatConfig.format)
    : questionData;

  console.log(`Found ${filteredQuestions.length} questions for format ${formatConfig.format}`);

  // Select required number of questions
  const selectedQuestions = selectRandomQuestions(filteredQuestions, formatConfig.questionCount);

  // Process questions for format-specific requirements
  const processedQuestions = processQuestionsForFormat(selectedQuestions, formatConfig.format);

  return processedQuestions;
}

/**
 * Generates a complete test paper based on blueprint
 * @param {Object} params - Test generation parameters
 * @returns {Object} - Generated test data
 */
async function generateTestPaper(params) {
  console.log('Generating test with params:', params);

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
      return {
        questions: enhancedResult.questions,
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

    // Select required number of questions
    const selectedQuestions = selectRandomQuestions(questionData, totalQuestions);

    // Add question numbers
    const numberedQuestions = selectedQuestions.map(question => ({
      ...question,
      questionNumber: questionNumber++,
      maxMarks: question.marks || 1
    }));

    generatedQuestions.push(...numberedQuestions);
  }

  console.log(`Generated ${generatedQuestions.length} total questions`);

  return {
    questions: generatedQuestions,
    totalQuestions: generatedQuestions.length,
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
