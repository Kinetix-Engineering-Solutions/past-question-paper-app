// Debug the grading issue step by step
// Run with: node debug_grading_issue.js

const { safeArray } = require('./functions/src/helpers/dataHelpers');

// Mock the safeArray function since we might not have the helper
function mockSafeArray(arr) {
  return Array.isArray(arr) ? arr : [];
}

function gradeDragAndDropOrdering(question, userAnswers) {
  const correctOrder = mockSafeArray(question.correctOrder);
  let userOrderArray;
  
  // Parse user answers if they come as string
  if (typeof userAnswers === 'string') {
    try {
      // Handle format like "item1,item2,item3" (comma-separated)
      // Note: Avoid using -> in the regex as it can interfere with step IDs containing numbers
      userOrderArray = userAnswers.split(',').map(s => s.trim()).filter(s => s);
    } catch (e) {
      userOrderArray = [];
    }
  } else {
    userOrderArray = mockSafeArray(userAnswers);
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
    const isCorrect = correctStep === userStep;
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

  return {
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
    markingMethod: 'step-based',
    explanation: `Each correct step awards ${marksPerStep.toFixed(2)} marks. Total: ${correctCount}/${totalSteps} steps correct.`
  };
}

console.log('=== Testing Grading Logic with Incorrect Order ===\n');

// Test Case: 4-mark question where user gets order wrong
const testQuestion = {
  id: 'test_q1',
  maxMarks: 4,
  correctOrder: ['step1', 'step2', 'step3', 'step4']
};

console.log('Test 1: Completely wrong order');
const wrongAnswer1 = 'step4,step3,step2,step1';
const result1 = gradeDragAndDropOrdering(testQuestion, wrongAnswer1);
console.log(`Result: isCorrect = ${result1.isCorrect}`);
console.log(`Marks: ${result1.marksAwarded}/${result1.maxMarks}`);
console.log(`Correct count: ${result1.correctCount}/${result1.totalSteps}`);
console.log('Detailed results:');
result1.detailedResults.forEach(step => {
  console.log(`  Step ${step.stepPosition}: ${step.isCorrect ? '✓' : '✗'} "${step.userAnswer}" (expected "${step.correctAnswer}")`);
});

console.log('\n' + '='.repeat(50) + '\n');

console.log('Test 2: Partially wrong order');
const wrongAnswer2 = 'step1,step3,step2,step4';
const result2 = gradeDragAndDropOrdering(testQuestion, wrongAnswer2);
console.log(`Result: isCorrect = ${result2.isCorrect}`);
console.log(`Marks: ${result2.marksAwarded}/${result2.maxMarks}`);
console.log(`Correct count: ${result2.correctCount}/${result2.totalSteps}`);
console.log('Detailed results:');
result2.detailedResults.forEach(step => {
  console.log(`  Step ${step.stepPosition}: ${step.isCorrect ? '✓' : '✗'} "${step.userAnswer}" (expected "${step.correctAnswer}")`);
});

console.log('\n' + '='.repeat(50) + '\n');

console.log('Test 3: Correct order (should be true)');
const correctAnswer = 'step1,step2,step3,step4';
const result3 = gradeDragAndDropOrdering(testQuestion, correctAnswer);
console.log(`Result: isCorrect = ${result3.isCorrect}`);
console.log(`Marks: ${result3.marksAwarded}/${result3.maxMarks}`);
console.log(`Correct count: ${result3.correctCount}/${result3.totalSteps}`);
