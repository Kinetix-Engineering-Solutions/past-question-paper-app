/**
 * Data transformation and validation helpers
 */

/**
 * Safely converts Firestore data arrays to plain JavaScript objects
 * @param {*} data - The data to convert
 * @returns {Array|null} - Converted array or null
 */
function safeArray(data) {
  if (!data) return null;
  if (Array.isArray(data)) {
    return data.map(item => {
      if (typeof item === 'object' && item !== null) {
        // Convert Firestore object to plain object
        return JSON.parse(JSON.stringify(item));
      }
      return item;
    });
  }
  return null;
}

/**
 * Maps Firestore document to standardized Question object
 * @param {DocumentSnapshot} doc - Firestore document
 * @returns {Object} - Standardized question object
 */
function mapQuestionData(doc) {
  const questionData = doc.data();
  console.log(`Processing question ${doc.id} with format: ${questionData.format || questionData.questionType}`);
  
  return {
    id: doc.id,
    // Core question fields
    subject: questionData.subject,
    paper: questionData.paper,
    grade: questionData.grade,
    topic: questionData.topic || questionData.topicId,
    cognitiveLevel: questionData.cognitiveLevel,
    marks: questionData.marks || questionData.mark || questionData.points || 1,
    year: questionData.year,
    season: questionData.season,
    
    // Question content
    format: questionData.format || questionData.questionType || questionData.question_type || questionData.type,
    questionText: questionData.questionText || questionData.question_text || questionData.text,
    imageUrl: questionData.imageUrl || questionData.questionImage,
    
    // Options (for MCQ, True/False, etc.)
    options: safeArray(questionData.options || questionData.choices || questionData.answers) || [],
    optionImages: safeArray(questionData.optionImages),
    
    // Drag and drop specific fields
    dragItems: safeArray(questionData.dragItems),
    dragTargets: safeArray(questionData.dragTargets || questionData.dropTargets),
    
    // Legacy fields for backward compatibility
    correctOrder: Array.isArray(questionData.correctOrder) ? questionData.correctOrder : [],
    
    // Other fields
    points: questionData.points,
    timeAllocation: questionData.timeAllocation,
    
    // ✅ Option 3: Parent-Child fields (CRITICAL - must be included!)
    isParent: questionData.isParent || false, // Mark parent questions
    parentQuestionId: questionData.parentQuestionId,
    usesParentImage: questionData.usesParentImage || false,
    parentContext: questionData.parentContext,
    
    // ✅ Dual mode fields
    availableInModes: questionData.availableInModes,
    pqpData: questionData.pqpData,
    sprintData: questionData.sprintData,
    
    // ✅ Short answer fields
    correctAnswer: questionData.correctAnswer,
    answerType: questionData.answerType,
    caseSensitive: questionData.caseSensitive,
    tolerance: questionData.tolerance,
    answerVariations: questionData.answerVariations,
    
    // ✅ Additional metadata
    explanation: questionData.explanation,
    difficulty: questionData.difficulty,
  };
}

/**
 * Normalizes paper format (e.g., "Paper 1" -> "p1")
 * @param {string} paper - Paper name to normalize
 * @returns {string} - Normalized paper format
 */
function normalizePaperFormat(paper) {
  let normalizedPaper = paper.toLowerCase().trim();
  
  // Convert "paper 1" to "p1", "paper1" to "p1", etc.
  if (normalizedPaper.includes('paper')) {
    normalizedPaper = normalizedPaper
      .replace('paper', 'p')
      .replace(/\s+/g, '');
  }
  
  // Ensure it starts with 'p' and has a number
  if (!normalizedPaper.startsWith('p')) {
    normalizedPaper = 'p' + normalizedPaper;
  }
  
  return normalizedPaper;
}

module.exports = {
  safeArray,
  mapQuestionData,
  normalizePaperFormat
};
