/**
 * Detailed Analysis of Current Selection Algorithm
 * This script analyzes the problems with cognitive level distribution
 */

const { generateSimulatedDatabase } = require('./simulate_large_database');

function analyzeCurrentSelectionIssues() {
  console.log('🔍 Detailed Analysis of Selection Issues\n');
  
  const database = generateSimulatedDatabase();
  
  // Blueprint requirements
  const blueprint = {
    topics: {
      "Algebra, Equations & Inequalities": 25,
      "Functions & Graphs": 35,
      "Differential Calculus": 35,
      "Pattern & Sequences": 25,
      "Probability": 25,
      "Finance, Growth & Decay": 15
    },
    cognitiveLevels: {
      "Level 1": 0.2,  // 20%
      "Level 2": 0.35, // 35%
      "Level 3": 0.3,  // 30%
      "Level 4": 0.15  // 15%
    }
  };

  console.log('📊 Database Cognitive Distribution by Topic:');
  
  for (const [topicName, marksNeeded] of Object.entries(blueprint.topics)) {
    const topicQuestions = database.filter(q => q.topic === topicName);
    
    console.log(`\n${topicName} (${marksNeeded} marks needed):`);
    console.log(`  Total available: ${topicQuestions.length} questions`);
    
    // Analyze cognitive distribution in this topic
    const cognitiveBreakdown = {};
    topicQuestions.forEach(q => {
      if (!cognitiveBreakdown[q.cognitiveLevel]) {
        cognitiveBreakdown[q.cognitiveLevel] = { count: 0, totalMarks: 0, questions: [] };
      }
      cognitiveBreakdown[q.cognitiveLevel].count++;
      cognitiveBreakdown[q.cognitiveLevel].totalMarks += q.marks;
      cognitiveBreakdown[q.cognitiveLevel].questions.push(q);
    });
    
    // Show breakdown
    Object.entries(cognitiveBreakdown).forEach(([level, data]) => {
      const percentage = ((data.count / topicQuestions.length) * 100).toFixed(1);
      const avgMarks = (data.totalMarks / data.count).toFixed(1);
      console.log(`    ${level}: ${data.count} questions (${percentage}%), ${data.totalMarks} marks total, ${avgMarks} avg marks`);
    });
    
    // Simulate current selection (by cognitive level order)
    console.log(`  Current Selection Strategy (Level 1 → 2 → 3 → 4):`);
    let currentMarks = 0;
    const selected = [];
    
    // Sort by cognitive level (current naive approach)
    const sortedQuestions = [...topicQuestions].sort((a, b) => {
      const levelOrder = { 'Level 1': 1, 'Level 2': 2, 'Level 3': 3, 'Level 4': 4 };
      return levelOrder[a.cognitiveLevel] - levelOrder[b.cognitiveLevel];
    });
    
    for (const question of sortedQuestions) {
      if (currentMarks < marksNeeded) {
        selected.push(question);
        currentMarks += question.marks;
        
        if (currentMarks >= marksNeeded) break;
      }
    }
    
    const selectedCognitive = {};
    selected.forEach(q => {
      selectedCognitive[q.cognitiveLevel] = (selectedCognitive[q.cognitiveLevel] || 0) + 1;
    });
    
    console.log(`    Selected: ${selected.length} questions, ${currentMarks} marks`);
    Object.entries(selectedCognitive).forEach(([level, count]) => {
      const percentage = ((count / selected.length) * 100).toFixed(1);
      console.log(`      ${level}: ${count} questions (${percentage}%)`);
    });
  }

  // Overall analysis
  console.log('\n🎯 Problem Analysis:');
  console.log('1. ISSUE: Sequential selection by cognitive level');
  console.log('   - Algorithm picks Level 1 first, then Level 2, etc.');
  console.log('   - This creates heavy bias toward lower levels');
  console.log('   - No consideration of target distribution');
  
  console.log('\n2. ISSUE: No cross-topic balancing');
  console.log('   - Each topic selected independently');
  console.log('   - No attempt to balance cognitive levels across topics');
  console.log('   - Missing optimization for overall compliance');
  
  console.log('\n3. ISSUE: Marks overshoot');
  console.log('   - Selection continues until marks target met');
  console.log('   - No consideration of total exam marks limit');
  console.log('   - No optimization for exact mark targets');

  // Show what an ideal selection should look like
  console.log('\n✅ Ideal Solution Strategy:');
  console.log('1. Calculate total questions needed across all topics');
  console.log('2. Determine target count per cognitive level');
  console.log('3. Select questions to meet both topic AND cognitive requirements');
  console.log('4. Use question swapping/substitution for optimization');
  console.log('5. Balance marks vs cognitive level requirements');

  return { database, blueprint };
}

// Simulate an improved selection strategy
function simulateImprovedSelection(database, blueprint) {
  console.log('\n🚀 Simulating Improved Selection Strategy\n');
  
  const totalMarksTarget = Object.values(blueprint.topics).reduce((sum, marks) => sum + marks, 0);
  const estimatedTotalQuestions = Math.ceil(totalMarksTarget / 6); // Assume 6 marks average
  
  console.log(`Target: ${totalMarksTarget} marks, ~${estimatedTotalQuestions} questions`);
  
  // Calculate target cognitive distribution
  const targetCognitive = {};
  Object.entries(blueprint.cognitiveLevels).forEach(([level, percentage]) => {
    targetCognitive[level] = Math.round(estimatedTotalQuestions * percentage);
  });
  
  console.log('Target cognitive distribution:');
  Object.entries(targetCognitive).forEach(([level, count]) => {
    console.log(`  ${level}: ${count} questions`);
  });
  
  // Step 1: Pre-select questions for each topic with cognitive awareness
  const selectedQuestions = [];
  const cognitiveCounts = { 'Level 1': 0, 'Level 2': 0, 'Level 3': 0, 'Level 4': 0 };
  
  for (const [topicName, marksNeeded] of Object.entries(blueprint.topics)) {
    console.log(`\nSelecting for ${topicName} (${marksNeeded} marks):`);
    
    const topicQuestions = database.filter(q => q.topic === topicName);
    
    // Smart selection: prefer cognitive levels that are under-represented
    const selected = [];
    let currentMarks = 0;
    
    // Create a priority queue based on cognitive level needs
    const questionsByLevel = {};
    topicQuestions.forEach(q => {
      if (!questionsByLevel[q.cognitiveLevel]) {
        questionsByLevel[q.cognitiveLevel] = [];
      }
      questionsByLevel[q.cognitiveLevel].push(q);
    });
    
    // Sort each level by marks (prefer questions that fit better)
    Object.values(questionsByLevel).forEach(questions => {
      questions.sort((a, b) => a.marks - b.marks);
    });
    
    // Select questions with cognitive level balancing
    while (currentMarks < marksNeeded) {
      let bestQuestion = null;
      let bestLevel = null;
      let bestPriority = -1;
      
      // Find the best question considering cognitive level needs
      Object.entries(questionsByLevel).forEach(([level, questions]) => {
        if (questions.length === 0) return;
        
        const currentRatio = cognitiveCounts[level] / Math.max(selectedQuestions.length, 1);
        const targetRatio = blueprint.cognitiveLevels[level];
        const need = targetRatio - currentRatio;
        
        // Higher priority for under-represented levels
        const priority = need * 100 + (10 - questions[0].marks); // Prefer needed levels + smaller marks
        
        if (priority > bestPriority && currentMarks + questions[0].marks <= marksNeeded + 5) { // Allow small overshoot
          bestQuestion = questions[0];
          bestLevel = level;
          bestPriority = priority;
        }
      });
      
      if (!bestQuestion) {
        // If no perfect fit, take the smallest available question
        for (const [level, questions] of Object.entries(questionsByLevel)) {
          if (questions.length > 0) {
            bestQuestion = questions[0];
            bestLevel = level;
            break;
          }
        }
      }
      
      if (!bestQuestion) break;
      
      // Select the question
      selected.push(bestQuestion);
      selectedQuestions.push(bestQuestion);
      currentMarks += bestQuestion.marks;
      cognitiveCounts[bestLevel]++;
      
      // Remove from available
      questionsByLevel[bestLevel] = questionsByLevel[bestLevel].filter(q => q.id !== bestQuestion.id);
    }
    
    console.log(`  Selected: ${selected.length} questions, ${currentMarks} marks`);
    const topicCognitive = {};
    selected.forEach(q => {
      topicCognitive[q.cognitiveLevel] = (topicCognitive[q.cognitiveLevel] || 0) + 1;
    });
    Object.entries(topicCognitive).forEach(([level, count]) => {
      console.log(`    ${level}: ${count} questions`);
    });
  }
  
  // Final analysis
  console.log('\n📊 Improved Selection Results:');
  console.log(`Total selected: ${selectedQuestions.length} questions`);
  console.log(`Total marks: ${selectedQuestions.reduce((sum, q) => sum + q.marks, 0)}`);
  
  console.log('\nCognitive distribution:');
  Object.entries(cognitiveCounts).forEach(([level, count]) => {
    const actualPercent = (count / selectedQuestions.length * 100).toFixed(1);
    const targetPercent = (blueprint.cognitiveLevels[level] * 100).toFixed(1);
    const compliance = Math.abs(count / selectedQuestions.length - blueprint.cognitiveLevels[level]) <= 0.1;
    console.log(`  ${level}: ${count} questions (${actualPercent}% vs ${targetPercent}% target) ${compliance ? '✅' : '❌'}`);
  });
  
  return selectedQuestions;
}

// Run the analysis
if (require.main === module) {
  const { database, blueprint } = analyzeCurrentSelectionIssues();
  simulateImprovedSelection(database, blueprint);
}

module.exports = {
  analyzeCurrentSelectionIssues,
  simulateImprovedSelection
};
