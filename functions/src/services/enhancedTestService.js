const { safeArray, mapQuestionData, normalizePaperFormat } = require('../helpers/dataHelpers');
const { 
  buildEnhancedQuestionQuery, 
  fetchBlueprint, 
  executeQuestionQuery,
  enrichQuestionWithParent,
  hasParent 
} = require('./databaseService');
const admin = require('firebase-admin');

/**
 * Enhanced test generation service with blueprint-compliant question selection
 */

/**
 * Builds question query with topic and cognitive level filtering
 * @param {Object} params - Query parameters including topic and cognitiveLevel
 * @returns {Query} - Enhanced Firestore query
 */
function buildLocalEnhancedQuestionQuery(params) {
  return buildEnhancedQuestionQuery(params);
}

/**
 * Selects questions for a specific topic based on marks allocation using knapsack-style fitting
 * @param {string} topicName - Name of the topic
 * @param {number} marksNeeded - Marks required for this topic
 * @param {Object} params - Base query parameters
 * @param {number} tolerance - Tolerance percentage for marks deviation (default 0.15 = 15%)
 * @returns {Array} - Selected questions for this topic
 */
async function selectQuestionsForTopic(topicName, marksNeeded, params, tolerance = 0.30) {
  console.log(`Selecting questions for topic: ${topicName} (${marksNeeded} marks needed, ±${(tolerance * 100).toFixed(1)}% tolerance)`);
  
  // Query more questions to have better selection pool
  const query = buildEnhancedQuestionQuery({
    ...params,
    topic: topicName,
    limit: 50 // Get substantial pool for knapsack selection
  });

  try {
    const questionDocs = await executeQuestionQuery(query, params);
    const questionData = questionDocs.map(doc => mapQuestionData(doc));
    
    console.log(`📥 Retrieved ${questionData.length} total questions for ${topicName}`);
    
    // IMPORTANT: Filter out parent questions (they're context providers, not answerable questions)
    const answerableQuestions = questionData.filter(q => !q.isParent);
    
    if (answerableQuestions.length < questionData.length) {
      console.log(`🚫 Filtered out ${questionData.length - answerableQuestions.length} parent questions from ${topicName}`);
    }
    
    console.log(`✅ ${answerableQuestions.length} answerable questions for ${topicName}`);
    
    // Use knapsack-style selection for precise marks fitting
    const selectedQuestions = selectQuestionsKnapsackStyle(answerableQuestions, marksNeeded, tolerance);
    
    const selectedMarks = selectedQuestions.reduce((sum, q) => sum + Number(q.maxMarks || q.marks || 0), 0);
    console.log(`✅ Selected ${selectedQuestions.length} questions for ${topicName} (${selectedMarks} marks)`);
    
    if (selectedQuestions.length === 0) {
      console.warn(`⚠️ WARNING: No questions selected for ${topicName}! Available: ${answerableQuestions.length}, Marks needed: ${marksNeeded}`);
    }
    
    return selectedQuestions;
    
  } catch (error) {
    console.error(`❌ Failed to get questions for topic ${topicName}:`, error.message);
    return [];
  }
}

/**
 * Knapsack-style question selection for precise marks fitting
 * @param {Array} availableQuestions - Pool of available questions
 * @param {number} targetMarks - Target marks to achieve
 * @param {number} tolerance - Acceptable deviation percentage
 * @returns {Array} - Optimally selected questions
 */
function selectQuestionsKnapsackStyle(availableQuestions, targetMarks, tolerance) {
  if (availableQuestions.length === 0) {
    console.warn(`⚠️ No available questions for knapsack selection`);
    return [];
  }
  
  const maxDeviation = targetMarks * tolerance;
  const minMarks = Math.max(1, targetMarks - maxDeviation); // Don't go below 1 mark
  const maxMarks = targetMarks + maxDeviation;
  
  console.log(`🎯 Knapsack target: ${targetMarks}m (range: ${minMarks.toFixed(1)}m - ${maxMarks.toFixed(1)}m)`);
  
  // Sort questions by marks (descending) for greedy approach
  const sortedQuestions = availableQuestions
    .map(q => ({ ...q, marks: Number(q.maxMarks || q.marks || 0) }))
    .filter(q => q.marks > 0)
    .sort((a, b) => b.marks - a.marks);
  
  if (sortedQuestions.length === 0) {
    console.warn(`⚠️ No questions with marks > 0 available`);
    return [];
  }
  
  console.log(`📊 Available questions: ${sortedQuestions.length} (total marks: ${sortedQuestions.reduce((s,q)=>s+q.marks,0)})`);
  
  // Greedy knapsack: pick questions until we're close to target
  let selectedQuestions = [];
  let currentMarks = 0;
  let remainingQuestions = [...sortedQuestions];
  
  // Phase 1: Greedy selection - pick questions that fit
  for (let i = 0; i < remainingQuestions.length && currentMarks < minMarks; i++) {
    const question = remainingQuestions[i];
    // More lenient: allow going over maxMarks if we're still under minMarks
    if (currentMarks + question.marks <= maxMarks || currentMarks < minMarks) {
      selectedQuestions.push(question);
      currentMarks += question.marks;
      remainingQuestions.splice(i, 1);
      i--; // Adjust index after removal
    }
  }
  
  console.log(`📦 Phase 1 complete: ${selectedQuestions.length} questions, ${currentMarks}m`);
  
  // Phase 2: Fine-tuning through swaps if we're outside tolerance
  if (currentMarks < minMarks || currentMarks > maxMarks) {
    console.log(`🔄 Phase 2: Optimizing (current: ${currentMarks}m, target: ${minMarks}-${maxMarks}m)`);
    selectedQuestions = optimizeMarksWithSwaps(selectedQuestions, remainingQuestions, targetMarks, tolerance);
    currentMarks = selectedQuestions.reduce((sum, q) => sum + q.marks, 0);
    console.log(`✅ Phase 2 complete: ${selectedQuestions.length} questions, ${currentMarks}m`);
  }
  
  // If still no questions, just take as many as we can up to maxMarks
  if (selectedQuestions.length === 0) {
    console.warn(`⚠️ Knapsack failed to select questions, falling back to simple selection`);
    let fallbackMarks = 0;
    for (const q of sortedQuestions) {
      if (fallbackMarks + q.marks <= maxMarks) {
        selectedQuestions.push(q);
        fallbackMarks += q.marks;
      }
      if (fallbackMarks >= minMarks) break;
    }
    console.log(`🔄 Fallback: selected ${selectedQuestions.length} questions, ${fallbackMarks}m`);
  }
  
  return selectedQuestions;
}

/**
 * Optimize marks allocation through intelligent question swaps
 * @param {Array} selected - Currently selected questions
 * @param {Array} available - Available questions for swapping
 * @param {number} target - Target marks
 * @param {number} tolerance - Tolerance percentage
 * @returns {Array} - Optimized selection
 */
function optimizeMarksWithSwaps(selected, available, target, tolerance) {
  const maxDeviation = target * tolerance;
  let bestSelection = [...selected];
  let bestScore = Math.abs(selected.reduce((sum, q) => sum + q.marks, 0) - target);
  
  // Try swapping each selected question with available ones
  for (let i = 0; i < selected.length; i++) {
    const currentQ = selected[i];
    
    for (const candidateQ of available) {
      const newSelection = [...selected];
      newSelection[i] = candidateQ;
      
      const newMarks = newSelection.reduce((sum, q) => sum + q.marks, 0);
      const newScore = Math.abs(newMarks - target);
      
      // Accept if closer to target and within tolerance
      if (newScore < bestScore && newMarks >= target - maxDeviation && newMarks <= target + maxDeviation) {
        bestSelection = newSelection;
        bestScore = newScore;
      }
    }
  }
  
  return bestSelection;
}

/**
 * Selects the best questions for a topic, optimizing for cognitive level variety and randomness
 * @param {Array} availableQuestions - Available questions for the topic
 * @param {number} questionsNeeded - Number of questions needed
 * @param {number} marksNeeded - Target marks for this topic
 * @returns {Array} - Optimally selected questions with variety and randomness
 */
function selectBestQuestionsForTopic(availableQuestions, questionsNeeded, marksNeeded) {
  if (availableQuestions.length <= questionsNeeded) {
    return availableQuestions;
  }

  // Group questions by cognitive level for variety
  const questionsByLevel = {};
  availableQuestions.forEach(q => {
    const level = q.cognitiveLevel || 'Level 1';
    if (!questionsByLevel[level]) {
      questionsByLevel[level] = [];
    }
    questionsByLevel[level].push(q);
  });

  // Add randomness by shuffling questions within each level
  Object.keys(questionsByLevel).forEach(level => {
    questionsByLevel[level] = questionsByLevel[level].sort(() => Math.random() - 0.5);
  });

  const selectedQuestions = [];
  const levelsToUse = Object.keys(questionsByLevel);
  
  // Distribute questions across cognitive levels with scoring system
  for (let i = 0; i < questionsNeeded && selectedQuestions.length < questionsNeeded; i++) {
    const levelIndex = i % levelsToUse.length;
    const level = levelsToUse[levelIndex];
    
    if (questionsByLevel[level] && questionsByLevel[level].length > 0) {
      // Score questions based on variety factors
      const question = questionsByLevel[level].shift(); // Already shuffled
      question.varietyScore = calculateVarietyScore(question, selectedQuestions);
      selectedQuestions.push(question);
    }
  }

  // If we still need more questions, add from any available with scoring
  while (selectedQuestions.length < questionsNeeded && availableQuestions.length > selectedQuestions.length) {
    const remainingQuestions = availableQuestions
      .filter(q => !selectedQuestions.includes(q))
      .map(q => ({ ...q, varietyScore: calculateVarietyScore(q, selectedQuestions) }))
      .sort((a, b) => b.varietyScore - a.varietyScore); // Higher score = better variety
    
    if (remainingQuestions.length > 0) {
      selectedQuestions.push(remainingQuestions[0]);
    } else {
      break;
    }
  }

  return selectedQuestions;
}

/**
 * Calculate variety score for question selection
 * @param {Object} question - Question to score
 * @param {Array} selectedQuestions - Already selected questions
 * @returns {number} - Variety score (higher = more variety)
 */
function calculateVarietyScore(question, selectedQuestions) {
  let score = 100; // Base score
  
  // Penalize if cognitive level is already well-represented
  const levelCount = selectedQuestions.filter(q => 
    (q.cognitiveLevel || 'Level 1') === (question.cognitiveLevel || 'Level 1')
  ).length;
  score -= levelCount * 10;
  
  // Reward recent years slightly
  const year = question.year || 2020;
  score += (year - 2020) * 2;
  
  // Penalize very similar mark values to encourage variety
  const marks = Number(question.maxMarks || question.marks || 0);
  const similarMarksCount = selectedQuestions.filter(q => 
    Math.abs(Number(q.maxMarks || q.marks || 0) - marks) <= 1
  ).length;
  score -= similarMarksCount * 5;
  
  // Add small random factor for unpredictability
  score += Math.random() * 10;
  
  return score;
}

/**
 * Advanced cognitive level balancing with score-based optimization
 * @param {Array} selectedQuestions - Currently selected questions
 * @param {Object} requiredLevels - Required cognitive level distribution from blueprint
 * @param {Object} params - Query parameters for finding replacement questions
 * @returns {Array} - Questions with optimized cognitive level distribution
 */
async function balanceCognitiveLevels(selectedQuestions, requiredLevels, params, options = {}) {
  console.log('🧠 Advanced cognitive level balancing...');

  const tolerancePct = options.tolerancePct ?? 0.1;
  const maxSwaps = options.maxSwaps ?? 50;
  const blueprintTopics = options.blueprintTopics || {};

  // Helper functions
  const countBy = (arr, keyFn) => arr.reduce((acc, it) => {
    const k = keyFn(it);
    acc[k] = (acc[k] || 0) + 1;
    return acc;
  }, {});

  const computeTopicMarks = (arr) => arr.reduce((acc, q) => {
    const t = q.allocatedTopic || q.topic;
    const m = Number(q.maxMarks || q.marks || 0);
    acc[t] = (acc[t] || 0) + m;
    return acc;
  }, {});

  // Calculate comprehensive compliance score
  const calculateComplianceScore = (questions) => {
    const currentDist = countBy(questions, q => q.cognitiveLevel || 'Level 1');
    const currentTopicMarks = computeTopicMarks(questions);
    
    // Cognitive compliance
    let cognitiveScore = 0;
    Object.entries(requiredLevels).forEach(([level, target]) => {
      const current = currentDist[level] || 0;
      const deviation = Math.abs(current - target) / Math.max(target, 1);
      cognitiveScore += Math.max(0, 1 - deviation); // Higher is better
    });
    
    // Topic marks compliance
    let topicScore = 0;
    Object.entries(blueprintTopics).forEach(([topic, target]) => {
      const current = currentTopicMarks[topic] || 0;
      const deviation = Math.abs(current - target) / Math.max(target, 1);
      topicScore += Math.max(0, 1 - deviation);
    });
    
    // Total marks compliance
    const totalTarget = Object.values(blueprintTopics).reduce((sum, marks) => sum + marks, 0);
    const totalCurrent = Object.values(currentTopicMarks).reduce((sum, marks) => sum + marks, 0);
    const marksScore = totalTarget > 0 ? Math.max(0, 1 - Math.abs(totalCurrent - totalTarget) / totalTarget) : 1;
    
    const normalizedCognitive = cognitiveScore / Math.max(Object.keys(requiredLevels).length, 1);
    const normalizedTopic = topicScore / Math.max(Object.keys(blueprintTopics).length, 1);
    const normalizedMarks = marksScore; // already 0..1
    return {
      cognitive: normalizedCognitive,
      topic: normalizedTopic,
      marks: normalizedMarks,
      total: (normalizedCognitive + normalizedTopic + normalizedMarks) / 3
    };
  };

  let currentQuestions = [...selectedQuestions];
  let bestScore = calculateComplianceScore(currentQuestions);
  let swaps = 0;

  console.log('Initial compliance score:', {
    cognitive: bestScore.cognitive.toFixed(3),
    topic: bestScore.topic.toFixed(3),
    marks: bestScore.marks.toFixed(3),
    total: bestScore.total.toFixed(3)
  });

  // Advanced optimization loop
  while (swaps < maxSwaps && bestScore.total < 0.95) { // Stop if 95% average normalized compliance
    let improvedThisRound = false;

    // Get current distributions
    const currentDistribution = countBy(currentQuestions, q => q.cognitiveLevel || 'Level 1');
    const currentTopicMarks = computeTopicMarks(currentQuestions);

    // Find levels that need adjustment
    const levelAdjustments = {};
    Object.entries(requiredLevels).forEach(([level, target]) => {
      const current = currentDistribution[level] || 0;
      levelAdjustments[level] = target - current;
    });

    // Try swaps that improve overall score
    for (let i = 0; i < currentQuestions.length && !improvedThisRound; i++) {
      const currentQ = currentQuestions[i];
      const currentLevel = currentQ.cognitiveLevel || 'Level 1';
      const currentTopic = currentQ.allocatedTopic || currentQ.topic;

      // Only try swapping if this level has surplus or we need improvement
      if (levelAdjustments[currentLevel] >= 0 && bestScore.total > 0.8) continue;

      try {
        // Find candidate questions for the same topic but different cognitive levels
        const targetLevels = Object.keys(levelAdjustments)
          .filter(level => levelAdjustments[level] > 0)
          .sort((a, b) => levelAdjustments[b] - levelAdjustments[a]); // Prioritize higher deficits

        for (const targetLevel of targetLevels) {
          const query = buildEnhancedQuestionQuery({
            ...params,
            topic: currentTopic,
            cognitiveLevel: targetLevel,
            limit: 10
          });

          const docs = await executeQuestionQuery(query, { ...params, topic: currentTopic, cognitiveLevel: targetLevel });
          const candidates = docs
            .map(doc => mapQuestionData(doc))
            .filter(c => !c.isParent) // Filter out parent questions
            .filter(c => !currentQuestions.some(q => q.id === c.id));

          // Test each candidate
          for (const candidate of candidates) {
            const testQuestions = [...currentQuestions];
            testQuestions[i] = { ...candidate, allocatedTopic: currentTopic };
            
            const testScore = calculateComplianceScore(testQuestions);
            
            // Hierarchical decision: A swap is accepted if it improves the primary goal (cognitive) 
            // without causing significant degradation in other metrics.
            const cognitiveImproves = testScore.cognitive > bestScore.cognitive;
            const topicIsAcceptable = testScore.topic >= bestScore.topic * 0.95; // Allow up to 5% degradation
            const marksAreAcceptable = testScore.marks >= bestScore.marks * 0.95; // Allow up to 5% degradation

            if (cognitiveImproves && topicIsAcceptable && marksAreAcceptable && testScore.total > bestScore.total) {
              console.log(`🔄 Hierarchical swap: ${currentQ.id}(${currentLevel}) → ${candidate.id}(${targetLevel})`);
              console.log(`  Scores (C/T/M): (${bestScore.cognitive.toFixed(2)}/${bestScore.topic.toFixed(2)}/${bestScore.marks.toFixed(2)}) → (${testScore.cognitive.toFixed(2)}/${testScore.topic.toFixed(2)}/${testScore.marks.toFixed(2)})`);
              
              currentQuestions[i] = { ...candidate, allocatedTopic: currentTopic };
              bestScore = testScore;
              swaps++;
              improvedThisRound = true;
              break;
            }
          }
          
          if (improvedThisRound) break;
        }
      } catch (err) {
        console.warn(`Query failed for topic ${currentTopic}:`, err.message);
      }
    }

    if (!improvedThisRound) {
      console.log('🎯 No more improvements found, stopping optimization');
      break;
    }
  }

  console.log(`✅ Balancing complete. Swaps performed: ${swaps}`);
  console.log('Final compliance score:', {
    cognitive: bestScore.cognitive.toFixed(3),
    topic: bestScore.topic.toFixed(3),
    marks: bestScore.marks.toFixed(3),
    total: bestScore.total.toFixed(3)
  });
  
  return currentQuestions;
}

/**
 * Calculate detailed compliance report with deviation values
 * @param {Array} questions - Selected questions
 * @param {Object} blueprint - Blueprint requirements
 * @returns {Object} - Detailed compliance report
 */
function calculateDetailedComplianceReport(questions, blueprint) {
  const totalQuestions = questions.length;
  
  // Topic compliance
  const actualTopicMarks = {};
  questions.forEach(q => {
    const topic = q.allocatedTopic || q.topic;
    const marks = Number(q.maxMarks || q.marks || 0);
    actualTopicMarks[topic] = (actualTopicMarks[topic] || 0) + marks;
  });
  
  let topicDeviations = [];
  let topicCompliant = true;
  Object.entries(blueprint.topics || {}).forEach(([topic, targetMarks]) => {
    const actualMarks = actualTopicMarks[topic] || 0;
    const deviation = actualMarks - targetMarks;
    const deviationPct = targetMarks > 0 ? deviation / targetMarks : 0;
    const tolerance = targetMarks * 0.2; // 20% tolerance
    const isCompliant = Math.abs(deviation) <= tolerance;
    
    topicDeviations.push({
      topic,
      target: targetMarks,
      actual: actualMarks,
      deviation,
      deviationPct: deviationPct * 100,
      compliant: isCompliant
    });
    
    if (!isCompliant) topicCompliant = false;
  });
  
  // Cognitive level compliance
  const actualCognitiveDist = {};
  questions.forEach(q => {
    const level = q.cognitiveLevel || 'Level 1';
    actualCognitiveDist[level] = (actualCognitiveDist[level] || 0) + 1;
  });
  
  let cognitiveDeviations = [];
  let cognitiveCompliant = true;
  Object.entries(blueprint.cognitiveLevels || {}).forEach(([level, targetPct]) => {
    const targetCount = Math.round(totalQuestions * targetPct);
    const actualCount = actualCognitiveDist[level] || 0;
    const deviation = actualCount - targetCount;
    const actualPct = totalQuestions > 0 ? actualCount / totalQuestions : 0;
    const deviationPct = actualPct - targetPct;
    const tolerance = 0.1; // 10% tolerance
    const isCompliant = Math.abs(deviationPct) <= tolerance;
    
    cognitiveDeviations.push({
      level,
      targetPct: targetPct * 100,
      actualPct: actualPct * 100,
      targetCount,
      actualCount,
      deviation,
      deviationPct: deviationPct * 100,
      compliant: isCompliant
    });
    
    if (!isCompliant) cognitiveCompliant = false;
  });
  
  // Total marks compliance
  const totalTargetMarks = Object.values(blueprint.topics || {}).reduce((sum, marks) => sum + marks, 0);
  const totalActualMarks = Object.values(actualTopicMarks).reduce((sum, marks) => sum + marks, 0);
  const marksDeviation = totalActualMarks - totalTargetMarks;
  const marksDeviationPct = totalTargetMarks > 0 ? marksDeviation / totalTargetMarks : 0;
  const marksTolerance = totalTargetMarks * 0.2; // 20% tolerance
  const marksCompliant = Math.abs(marksDeviation) <= marksTolerance;
  
  return {
    topic: {
      compliant: topicCompliant,
      deviations: topicDeviations,
      summary: {
        totalTopics: Object.keys(blueprint.topics || {}).length,
        compliantTopics: topicDeviations.filter(d => d.compliant).length
      }
    },
    cognitive: {
      compliant: cognitiveCompliant,
      deviations: cognitiveDeviations,
      summary: {
        totalLevels: Object.keys(blueprint.cognitiveLevels || {}).length,
        compliantLevels: cognitiveDeviations.filter(d => d.compliant).length
      }
    },
    marks: {
      compliant: marksCompliant,
      target: totalTargetMarks,
      actual: totalActualMarks,
      deviation: marksDeviation,
      deviationPct: marksDeviationPct * 100,
      tolerance: marksTolerance
    },
    overall: {
      compliant: topicCompliant && cognitiveCompliant && marksCompliant,
      score: (
        (topicCompliant ? 1 : 0) +
        (cognitiveCompliant ? 1 : 0) +
        (marksCompliant ? 1 : 0)
      ) / 3
    }
  };
}
/**
 * Generates test questions using blueprint-compliant selection with async optimization
 * @param {Object} params - Test generation parameters
 * @returns {Object} - Generated test with blueprint compliance
 */
async function generateBlueprintCompliantTest(params) {
  console.log('🎯 Generating blueprint-compliant test');
  
  // Fetch blueprint
  const blueprintId = `${params.subject}_${normalizePaperFormat(params.paper)}_gr${params.grade}`.toLowerCase();
  console.log(`🔍 Looking for blueprint: ${blueprintId} (paper: ${params.paper} -> ${normalizePaperFormat(params.paper)})`);
  const blueprint = await fetchBlueprint(blueprintId);
  
  if (!blueprint.topics || !blueprint.cognitiveLevels) {
    console.warn('Blueprint missing topics or cognitive levels, falling back to legacy generation');
    return await generateLegacyTest(params);
  }

  const allSelectedQuestions = [];
  let questionNumber = 1;

  // Quick practice / scaled mode detection (duration or explicit quick flag)
  let effectiveBlueprint = { ...blueprint, topics: { ...blueprint.topics } };
  const isQuickPractice = params.mode === 'sprint' || params.mode === 'quick_practice' || params.quick || params.duration;

  if (isQuickPractice && params.duration) {
    const duration = params.duration; // minutes from slider (5-60)
    const baseTotal = blueprint.totalMarks || 150; // Full paper marks
    const baseDuration = 150; // Full paper duration in minutes (matching most papers)

    // Calculate target marks proportionally based on duration
    // Example: 15 min / 150 min * 150 marks = 15 marks
    //          30 min / 150 min * 150 marks = 30 marks
    //          60 min / 150 min * 150 marks = 60 marks
    const targetMarks = Math.max(10, Math.round(baseTotal * (duration / baseDuration)));
    const scale = targetMarks / baseTotal;

    // Scale each topic proportionally
    Object.entries(blueprint.topics).forEach(([t, m]) => {
      effectiveBlueprint.topics[t] = Math.max(2, Math.round(m * scale));
    });
    effectiveBlueprint.totalMarks = Object.values(effectiveBlueprint.topics).reduce((s,m)=>s+m,0);

    console.log(`⚡ Quick practice scaling active: duration=${duration}m (${Math.round(duration/baseDuration*100)}% of full paper)`);
    console.log(`   Base: ${baseTotal} marks in ${baseDuration}m → Target: ${effectiveBlueprint.totalMarks} marks`);
  }

  // Calculate total marks and estimate questions
  const totalMarks = effectiveBlueprint.totalMarks || blueprint.totalMarks || 150;
  console.log(`Target: ${totalMarks} marks across ${Object.keys(effectiveBlueprint.topics).length} topics`);

  // Step 1: Parallel topic selection for better performance
  const topicSelectionPromises = Object.entries(effectiveBlueprint.topics).map(async ([topicName, marksAllocated]) => {
    const topicQuestions = await selectQuestionsForTopic(topicName, marksAllocated, params, 0.30);
    
    return {
      topicName,
      marksAllocated,
      marksAchieved: topicQuestions.reduce((sum, q) => sum + Number(q.maxMarks || q.marks || 0), 0),
      questions: topicQuestions
    };
  });

  const topicResults = await Promise.all(topicSelectionPromises);
  
  // Step 1.5: SMART COMPENSATION - Check for shortfalls and redistribute
  let totalAchieved = topicResults.reduce((sum, tr) => sum + tr.marksAchieved, 0);
  const targetTotal = Object.values(effectiveBlueprint.topics).reduce((sum, m) => sum + m, 0);
  const shortfall = targetTotal - totalAchieved;
  
  console.log(`📊 Initial marks: ${totalAchieved}/${targetTotal} (${((totalAchieved/targetTotal)*100).toFixed(1)}%)`);
  
  if (shortfall > 0 && shortfall > targetTotal * 0.1) {
    // Significant shortfall (>10%), try smart compensation
    console.log(`⚠️ Significant shortfall detected: ${shortfall} marks (${((shortfall/targetTotal)*100).toFixed(1)}%)`);
    console.log(`🔄 Attempting smart compensation...`);
    
    // Find topics with surplus
    const topicsWithSurplus = topicResults.filter(tr => tr.marksAchieved > tr.marksAllocated);
    const topicsWithShortfall = topicResults.filter(tr => tr.marksAchieved < tr.marksAllocated);
    
    console.log(`   Surplus topics: ${topicsWithSurplus.length}`);
    console.log(`   Shortfall topics: ${topicsWithShortfall.length}`);
    
    // For each topic with shortfall, try to get more questions
    for (const topicResult of topicsWithShortfall) {
      const topicShortfall = topicResult.marksAllocated - topicResult.marksAchieved;
      console.log(`   📉 ${topicResult.topicName}: ${topicResult.marksAchieved}/${topicResult.marksAllocated} (need ${topicShortfall} more)`);
      
      // Get ALL available questions for this topic (not just within tolerance)
      const query = buildEnhancedQuestionQuery({
        ...params,
        topic: topicResult.topicName,
        limit: 100
      });
      
      try {
        const questionDocs = await executeQuestionQuery(query, params);
        const questionData = questionDocs.map(doc => mapQuestionData(doc));
        const answerableQuestions = questionData.filter(q => !q.isParent);
        
        // Get questions we haven't already selected
        const alreadySelectedIds = new Set(topicResult.questions.map(q => q.id));
        const additionalQuestions = answerableQuestions.filter(q => !alreadySelectedIds.has(q.id));
        
        if (additionalQuestions.length > 0) {
          // Add questions up to the allocated marks
          let addedMarks = 0;
          for (const q of additionalQuestions) {
            const qMarks = Number(q.maxMarks || q.marks || 0);
            if (topicResult.marksAchieved + addedMarks + qMarks <= topicResult.marksAllocated * 1.5) { // Allow 50% over
              topicResult.questions.push(q);
              addedMarks += qMarks;
              totalAchieved += qMarks;
              if (addedMarks >= topicShortfall) break;
            }
          }
          topicResult.marksAchieved += addedMarks;
          console.log(`   ✅ Added ${addedMarks} marks to ${topicResult.topicName} (now ${topicResult.marksAchieved})`);
        }
      } catch (err) {
        console.warn(`   ❌ Failed to get additional questions for ${topicResult.topicName}:`, err.message);
      }
    }
    
    console.log(`📊 After compensation: ${totalAchieved}/${targetTotal} (${((totalAchieved/targetTotal)*100).toFixed(1)}%)`);
  }
  
  // Combine all topic questions
  topicResults.forEach(({ topicName, marksAllocated, questions }) => {
    const numberedQuestions = questions.map(question => ({
      ...question,
      questionNumber: questionNumber++,
      allocatedTopic: topicName,
      allocatedMarks: marksAllocated
    }));
    
    allSelectedQuestions.push(...numberedQuestions);
  });

  console.log(`📊 Final selection: ${allSelectedQuestions.length} questions, ${totalAchieved} marks`);

  // Step 2: Skip cognitive level balancing - marks-based selection is sufficient
  // Cognitive levels are already balanced in original papers (for PQP)
  // and variety from different years provides natural balance (for Sprint/ByTopic)
  const balancedQuestions = allSelectedQuestions;
  console.log('✅ Using marks-based selection (cognitive balancing disabled for performance)');

  console.log(`✅ Generated ${balancedQuestions.length} blueprint-compliant questions`);

  // Step 3: Generate detailed compliance report
  const detailedComplianceReport = calculateDetailedComplianceReport(balancedQuestions, effectiveBlueprint);

  // Calculate distribution summaries for logging
  const topicDistribution = {};
  const cognitiveDistribution = {};
  const topicMarksDistribution = {};
  
  balancedQuestions.forEach(q => {
    const topic = q.allocatedTopic || q.topic;
    const level = q.cognitiveLevel || 'Level 1';
    const marks = Number(q.maxMarks || q.marks || 0);
    
    topicDistribution[topic] = (topicDistribution[topic] || 0) + 1;
    cognitiveDistribution[level] = (cognitiveDistribution[level] || 0) + 1;
    topicMarksDistribution[topic] = (topicMarksDistribution[topic] || 0) + marks;
  });

  console.log('📊 Final Distribution:');
  console.log('Topics (questions):', topicDistribution);
  console.log('Topics (marks):', topicMarksDistribution);
  console.log('Cognitive Levels:', cognitiveDistribution);
  console.log('🎯 Compliance Score:', detailedComplianceReport.overall.score.toFixed(3));

  const totalSelectedMarks = balancedQuestions.reduce((s, q) => s + Number(q.maxMarks || q.marks || 0), 0);

  // OPTION 3: Enrich questions with parent context before returning
  console.log('🔗 Enriching questions with parent context...');
  const enrichedQuestions = [];
  for (const question of balancedQuestions) {
    if (hasParent(question)) {
      const enriched = await enrichQuestionWithParent(question);
      enrichedQuestions.push(enriched);
    } else {
      enrichedQuestions.push(question);
    }
  }

  return {
    questions: enrichedQuestions,
    totalQuestions: enrichedQuestions.length,
    totalMarks: totalSelectedMarks,
    blueprint: effectiveBlueprint,
    topicDistribution,
    cognitiveDistribution,
    topicMarksDistribution,
    generatedAt: new Date().toISOString(),
    complianceReport: detailedComplianceReport,
    // Legacy format for backward compatibility
    complianceReport_legacy: {
      topicCompliant: detailedComplianceReport.topic.compliant,
      cognitiveCompliant: detailedComplianceReport.cognitive.compliant,
      marksCompliant: detailedComplianceReport.marks.compliant
    }
  };
}

/**
 * Legacy test generation (fallback)
 */
async function generateLegacyTest(params) {
  console.log('Using legacy test generation');
  // ... existing legacy code ...
  return { questions: [], totalQuestions: 0, blueprint: {}, generatedAt: new Date().toISOString() };
}

module.exports = {
  buildLocalEnhancedQuestionQuery,
  selectQuestionsForTopic,
  selectQuestionsKnapsackStyle,
  optimizeMarksWithSwaps,
  selectBestQuestionsForTopic,
  calculateVarietyScore,
  balanceCognitiveLevels,
  calculateDetailedComplianceReport,
  generateBlueprintCompliantTest,
  generateLegacyTest
};
