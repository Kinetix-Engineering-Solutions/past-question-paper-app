// Test script to demonstrate SA step-based marking for drag-and-drop ordering
// Run with: node test_sa_marking.js

// Mock helper function
function safeArray(arr) {
  return Array.isArray(arr) ? arr : [];
}

// Simplified gradeDragAndDropOrdering function for testing
function gradeDragAndDropOrdering(question, userAnswers) {
  const correctOrder = safeArray(question.correctOrder);
  let userOrderArray;
  
  // Parse user answers if they come as string
  if (typeof userAnswers === 'string') {
    try {
      userOrderArray = userAnswers.split(/[,->]+/).map(s => s.trim()).filter(s => s);
    } catch (e) {
      userOrderArray = [];
    }
  } else {
    userOrderArray = safeArray(userAnswers);
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

console.log('=== South African Step-Based Marking Tests ===\n');

// Test Case 1: 4-mark question with 4 steps (each step = 1 mark)
console.log('Test 1: 4-mark Mathematics Question');
const mathQuestion = {
  id: 'math_q1',
  maxMarks: 4,
  correctOrder: ['identify', 'substitute', 'calculate', 'solve']
};

const testCases = [
  {
    name: 'Perfect Answer',
    userAnswer: 'identify,substitute,calculate,solve',
    expected: '4/4 steps correct = 4 marks'
  },
  {
    name: 'Partial Answer (3 correct)',
    userAnswer: 'identify,substitute,calculate,wrong',
    expected: '3/4 steps correct = 3 marks'
  },
  {
    name: 'Half Correct',
    userAnswer: 'identify,wrong,calculate,solve',
    expected: '2/4 steps correct = 2 marks'
  },
  {
    name: 'One Step Correct',
    userAnswer: 'identify,wrong,wrong,wrong',
    expected: '1/4 steps correct = 1 mark'
  },
  {
    name: 'All Wrong',
    userAnswer: 'wrong,wrong,wrong,wrong',
    expected: '0/4 steps correct = 0 marks'
  }
];

testCases.forEach(testCase => {
  const result = gradeDragAndDropOrdering(mathQuestion, testCase.userAnswer);
  console.log(`\n${testCase.name}:`);
  console.log(`  User: [${testCase.userAnswer}]`);
  console.log(`  Expected: ${testCase.expected}`);
  console.log(`  Result: ${result.correctCount}/${result.totalSteps} steps = ${result.marksAwarded} marks`);
  console.log(`  Marks per step: ${result.marksPerStep}`);
  console.log(`  Passed: ${result.isCorrect ? 'Yes' : 'No'} (≥50% threshold)`);
});

console.log('\n' + '='.repeat(60));

// Test Case 2: 6-mark question with 4 steps (each step = 1.5 marks)
console.log('\nTest 2: 6-mark Physics Question');
const physicsQuestion = {
  id: 'physics_q1',
  maxMarks: 6,
  correctOrder: ['analyze', 'formula', 'substitute', 'calculate']
};

const physicsTests = [
  {
    name: 'All Correct',
    userAnswer: 'analyze,formula,substitute,calculate',
    expected: '4/4 steps = 6 marks'
  },
  {
    name: 'Three Correct',
    userAnswer: 'analyze,formula,substitute,wrong',
    expected: '3/4 steps = 4.5 marks'
  },
  {
    name: 'Two Correct',
    userAnswer: 'analyze,wrong,substitute,wrong',
    expected: '2/4 steps = 3 marks'
  }
];

physicsTests.forEach(testCase => {
  const result = gradeDragAndDropOrdering(physicsQuestion, testCase.userAnswer);
  console.log(`\n${testCase.name}:`);
  console.log(`  Result: ${result.correctCount}/${result.totalSteps} steps = ${result.marksAwarded} marks`);
  console.log(`  Marks per step: ${result.marksPerStep}`);
});

console.log('\n' + '='.repeat(60));

// Test Case 3: 3-mark question with 4 steps (each step = 0.75 marks)
console.log('\nTest 3: 3-mark Chemistry Question');
const chemQuestion = {
  id: 'chem_q1',
  maxMarks: 3,
  correctOrder: ['weigh', 'dissolve', 'transfer', 'dilute']
};

const chemTest = {
  userAnswer: 'weigh,dissolve,wrong,dilute',
};

const chemResult = gradeDragAndDropOrdering(chemQuestion, chemTest.userAnswer);
console.log(`\nPartial Answer:`);
console.log(`  Result: ${chemResult.correctCount}/${chemResult.totalSteps} steps = ${chemResult.marksAwarded} marks`);
console.log(`  Marks per step: ${chemResult.marksPerStep}`);
console.log(`  Detailed breakdown:`);
chemResult.detailedResults.forEach(step => {
  console.log(`    Step ${step.stepPosition}: ${step.isCorrect ? '✓' : '✗'} ${step.marksAwarded} marks`);
});

console.log('\n' + '='.repeat(60));
console.log('\nSA Step-Based Marking Summary:');
console.log('• Each step has equal weight: total marks ÷ number of steps');
console.log('• Students get credit for each correctly positioned step');
console.log('• No rounding errors or complex percentage calculations');
console.log('• Aligns with traditional SA marking schemes');
console.log('• Pass threshold: 50% of total marks');
