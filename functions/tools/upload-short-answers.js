/**
 * Upload Short Answer Questions to Firestore
 * Run: node functions/tools/upload-short-answers.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('../../serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// TEST: Upload only 3 standalone questions (no parent-child chains)
const parentQuestions = []; // Empty - not uploading parent questions for this test

// 3 Test Short Answer Questions (standalone only)
const shortAnswerQuestions = [
  {
    id: 'sa_math_001',
    format: 'short_answer',
    answerType: 'numerical',
    
    // Content
    questionText: 'Calculate the discriminant of the quadratic equation 2x² + 5x + 3 = 0',
    imageUrl: null,
    
    // Answer Data
    correctAnswer: '1',
    answerVariations: ['1', '1.0', '1.00'],
    tolerance: 0.01,
    caseSensitive: false,
    
    // Classification
    subject: 'Mathematics',
    topic: 'Quadratic Equations',
    grade: 12,
    paper: 'p1',
    year: 2023,
    season: 'November',
    cognitiveLevel: 'Level 2', // ✅ REQUIRED: CAPS cognitive level
    marks: 2,
    maxMarks: 2,
    
    // Mode-specific data
    pqpData: {
      questionNumber: '1.1',
      questionText: 'Calculate the discriminant of the quadratic equation 2x² + 5x + 3 = 0',
      marks: 2
    },
    
    sprintData: {
      questionText: 'Calculate the discriminant of the quadratic equation 2x² + 5x + 3 = 0',
      marks: 2,
      hints: [
        'Use the formula Δ = b² - 4ac',
        'Substitute a = 2, b = 5, c = 3'
      ],
      providedContext: 'The discriminant helps determine the nature of the roots of a quadratic equation.'
    },
    
    availableInModes: ['pqp', 'sprint', 'by_topic']
  },
  
  {
    id: 'sa_math_002',
    format: 'short_answer',
    answerType: 'equation',
    
    questionText: 'Determine the equation of the horizontal asymptote of f(x) = 3(2^x) - 4',
    imageUrl: null,
    
    correctAnswer: 'y = -4',
    answerVariations: ['y=-4', 'y = - 4', '-4', 'y equals -4'],
    caseSensitive: false,
    
    subject: 'Mathematics',
    topic: 'Exponential Functions',
    grade: 12,
    paper: 'p1',
    year: 2023,
    season: 'November',
    cognitiveLevel: 'Level 1', // ✅ REQUIRED: CAPS cognitive level
    marks: 2,
    maxMarks: 2,
    
    pqpData: {
      questionNumber: '2.1',
      questionText: 'Determine the equation of the horizontal asymptote of f(x) = 3(2^x) - 4',
      marks: 2
    },
    
    sprintData: {
      questionText: 'Determine the equation of the horizontal asymptote of f(x) = 3(2^x) - 4',
      marks: 2,
      hints: [
        'Consider what happens as x approaches negative infinity',
        'The horizontal asymptote is y = c, where c is the constant term'
      ],
      providedContext: 'For exponential functions f(x) = a(b^x) + c, the horizontal asymptote is y = c'
    },
    
    availableInModes: ['pqp', 'sprint', 'by_topic']
  },
  
  {
    id: 'sa_math_003',
    format: 'short_answer',
    answerType: 'domain_range',
    
    questionText: 'Write down the domain of g(x) = √(x - 2)',
    imageUrl: null,
    
    correctAnswer: 'x ∈ [2; ∞)',
    answerVariations: ['x >= 2', 'x ≥ 2', '[2; ∞)', '[2, ∞)', 'x ∈ [2, ∞)', '{x | x >= 2}'],
    caseSensitive: false,
    
    subject: 'Mathematics',
    topic: 'Functions',
    grade: 12,
    paper: 'p1',
    year: 2023,
    season: 'November',
    cognitiveLevel: 'Level 2', // ✅ REQUIRED: CAPS cognitive level
    marks: 2,
    maxMarks: 2,
    
    pqpData: {
      questionNumber: '3.1',
      questionText: 'Write down the domain of g(x) = √(x - 2)',
      marks: 2
    },
    
    sprintData: {
      questionText: 'Write down the domain of g(x) = √(x - 2)',
      marks: 2,
      hints: [
        'The expression under the square root must be non-negative',
        'Solve x - 2 ≥ 0'
      ],
      providedContext: 'The domain is the set of all valid x-values for which the function is defined.'
    },
    
    availableInModes: ['pqp', 'sprint', 'by_topic']
  }
  // Only 3 questions for testing
];

/**
 * Upload questions to Firestore (TEST: 3 standalone questions only)
 */
async function uploadQuestions() {
  console.log('🚀 Starting TEST upload - 3 short answer questions...\n');
  
  const batch = db.batch();
  
  // Upload the 3 test questions
  console.log('📝 Uploading test questions...');
  for (const question of shortAnswerQuestions) {
    const docRef = db.collection('questions').doc(question.id);
    batch.set(docRef, question);
    console.log(`✅ Prepared: ${question.id} - "${question.questionText.substring(0, 60)}..."`);
  }
  
  try {
    await batch.commit();
    console.log(`\n🎉 Successfully uploaded ${shortAnswerQuestions.length} test questions!`);
    console.log('\n📊 Test Questions:');
    console.log('   1. sa_math_001: Discriminant (numerical, 2 marks)');
    console.log('   2. sa_math_002: Asymptote (equation, 2 marks)');
    console.log('   3. sa_math_003: Domain (domain/range, 2 marks)');
    console.log('\n✨ Test questions are now LIVE!');
  } catch (error) {
    console.error('❌ Error uploading questions:', error);
    throw error;
  } finally {
    // Close the app
    await admin.app().delete();
  }
}

// Run the upload
uploadQuestions()
  .then(() => {
    console.log('\n✅ Upload complete! You can now test short answers in the app.');
    process.exit(0);
  })
  .catch(error => {
    console.error('\n❌ Upload failed:', error);
    process.exit(1);
  });
