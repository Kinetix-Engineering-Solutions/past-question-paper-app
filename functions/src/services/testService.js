const { safeArray, mapQuestionData, normalizePaperFormat } = require('../helpers/dataHelpers');
const { buildQuestionQuery, fetchBlueprint, executeQuestionQuery } = require('./databaseService');
const { generateBlueprintCompliantTest } = require('./enhancedTestService');

/**
 * Test generation service for creating past paper tests
 */

/**
 * Selects random questions from a pool based on count requirement
 * @param {Array} questionDocs - Array of question documents
 * @param {number} requiredCount - Number of questions needed
 * @returns {Array} - Selected questions
 */
function selectRandomQuestions(questionDocs, requiredCount) {
  if (questionDocs.length <= requiredCount) {
    return questionDocs;
  }

  // Fisher-Yates shuffle algorithm
  const shuffled = [...questionDocs];
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
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

module.exports = {
  selectRandomQuestions,
  processQuestionsForFormat,
  generateQuestionsForFormat,
  generateTestPaper,
  generateLegacyTestPaper
};
