/**
 * CORRECTED: Upload script for parent-child question structure (Option 3)
 * 
 * KEY CONCEPT: Parent questions are CONTEXT DOCUMENTS, not answerable questions
 * - Parents do NOT have 'format' or 'questionType' (they're not questions to answer)
 * - Parents provide context (text, images, diagrams) for their children
 * - Children are the actual answerable questions with formats (MCQ, short_answer, etc.)
 * 
 * PARENT FIELDS (Context Document):
 * ✅ Required: id, isParent, type, questionText, imageUrl, subject, grade, topic, 
 *             paper, year, season, childQuestionIds, totalMarks, availableInModes, pqpData
 * ❌ NOT allowed: format, questionType, correctAnswer, options, marks (use totalMarks),
 *                cognitiveLevel, difficulty, caseSensitive, tolerance, sprintData
 * 
 * CHILD FIELDS (Answerable Question):
 * ✅ Required: id, format, questionType, questionText, parentQuestionId, usesParentImage,
 *             correctAnswer, marks, subject, grade, topic, paper, year, season,
 *             cognitiveLevel, difficulty, pqpData, sprintData, availableInModes
 * ❌ Usually omitted: imageUrl (unless child has unique image different from parent)
 */

const admin = require('firebase-admin');
const serviceAccount = require('../../serviceAccountKey.json');

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

/**
 * ========================================
 * PARENT QUESTION (CONTEXT DOCUMENT)
 * ========================================
 * This is NOT an answerable question - it's a context provider
 * No 'format', no 'questionType', no answer fields
 */
const parentQuestion = {
  id: 'parent_func_001',
  
  // Explicitly mark this as a parent/context document
  isParent: true,  // ✅ Use this instead of format
  type: 'context', // ✅ Clarifies it's not answerable
  
  // Context information (shared by all children)
  questionText: 'The sketch below shows the graphs of f(x) = ax² + bx + c and g(x) = mx + k. The graph of f cuts the x-axis at A(-1, 0) and B(3, 0). The turning point of f is D. The two graphs intersect at A and C(2, 5).',
  
  // Image displayed for all children
  imageUrl: 'https://firebasestorage.googleapis.com/v0/b/vibe-code-4c59f.appspot.com/o/questions%2Ffunctions_graph_001.png?alt=media',
  
  // Metadata (inherited by children for querying/filtering)
  subject: 'mathematics',
  grade: 12,
  topic: 'Functions & Graphs',
  paper: 'p1',
  year: 2023,
  season: 'November',
  
  // Parent-specific: List of child question IDs
  childQuestionIds: [
    'child_func_001_1',
    'child_func_001_2', 
    'child_func_001_3'
  ],
  
  // Total marks for all children combined
  totalMarks: 13,
  
  // Availability (children inherit this)
  availableInModes: ['pqp', 'sprint', 'by_topic'],
  
  // PQP data (parent-level metadata)
  pqpData: {
    questionNumber: '4.1', // Parent number (children are 4.1.1, 4.1.2, 4.1.3)
    year: 2023,
    season: 'November',
    paper: 'p1',
    marks: 13, // Total for all children
    isParent: true
  },
  
  // Timestamps
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  updatedAt: admin.firestore.FieldValue.serverTimestamp()
};

/**
 * ========================================
 * CHILD QUESTION 1: Short Answer
 * ========================================
 * This IS an answerable question with format='short_answer'
 */
const childQuestion1 = {
  id: 'child_func_001_1',
  
  // ✅ Children have formats (they're actual questions to answer)
  format: 'short_answer',
  questionType: 'short_answer',
  answerType: 'coordinates',
  
  // Question text (assumes parent context is shown above)
  questionText: 'Calculate the coordinates of D, the turning point of f.',
  
  // ✅ Parent reference (links to parent context document)
  parentQuestionId: 'parent_func_001',
  usesParentImage: true, // Flag indicating this uses parent's image
  
  // NO imageUrl field on child - it inherits from parent via displayImageUrl getter
  
  // ✅ Answer data (children have answers, parents don't)
  correctAnswer: {
    value: '(1, -4)',
    variations: ['(1;-4)', '(1, -4)', 'D(1, -4)', 'D(1;-4)', '(1,-4)']
  },
  marks: 4,
  
  // Metadata (must match parent for proper querying)
  subject: 'mathematics',
  grade: 12,
  topic: 'Functions & Graphs', // ✅ Exact match with blueprint
  paper: 'p1',
  year: 2023,
  season: 'November',
  cognitiveLevel: 'Level 3', // Application
  difficulty: 'medium',
  
  // Availability
  availableInModes: ['pqp', 'sprint', 'by_topic'],
  
  // PQP data (child-specific)
  pqpData: {
    questionNumber: '4.1.1', // ✅ Child numbering under parent 4.1
    year: 2023,
    season: 'November',
    paper: 'p1',
    marks: 4,
    showWithParent: true // UI flag to display parent context
  },
  
  // Sprint data (child-specific hints)
  sprintData: {
    hint: 'The turning point x-coordinate is midway between the x-intercepts. Use x = (x₁ + x₂)/2 = (-1 + 3)/2.',
    timeEstimate: 3, // minutes
    providedContext: {
      'x-intercepts': 'A(-1, 0) and B(3, 0)',
      'formula': 'x = -b/2a or x = (x₁ + x₂)/2'
    }
  },
  
  // Short answer specific fields
  caseSensitive: false,
  tolerance: 0,
  
  // Timestamps
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  updatedAt: admin.firestore.FieldValue.serverTimestamp()
};

/**
 * ========================================
 * CHILD QUESTION 2: Short Answer
 * ========================================
 */
const childQuestion2 = {
  id: 'child_func_001_2',
  
  format: 'short_answer',
  questionType: 'short_answer',
  answerType: 'equation',
  
  questionText: 'Determine the equation of f in the form f(x) = ax² + bx + c.',
  
  // Parent reference
  parentQuestionId: 'parent_func_001',
  usesParentImage: true,
  
  // Answer data
  correctAnswer: {
    value: 'f(x) = x² - 2x - 3',
    variations: [
      'f(x) = x² - 2x - 3',
      'f(x)=x²-2x-3',
      'y = x² - 2x - 3',
      'x² - 2x - 3',
      'f(x) = x^2 - 2x - 3',
      'f(x)=x^2-2x-3'
    ]
  },
  marks: 4,
  
  // Metadata
  subject: 'mathematics',
  grade: 12,
  topic: 'Functions & Graphs',
  paper: 'p1',
  year: 2023,
  season: 'November',
  cognitiveLevel: 'Level 3',
  difficulty: 'medium',
  
  availableInModes: ['pqp', 'sprint', 'by_topic'],
  
  pqpData: {
    questionNumber: '4.1.2',
    year: 2023,
    season: 'November',
    paper: 'p1',
    marks: 4,
    showWithParent: true
  },
  
  sprintData: {
    hint: 'Use factored form: f(x) = a(x + 1)(x - 3). Substitute point C(2, 5) to find "a".',
    timeEstimate: 4,
    providedContext: {
      'x-intercepts': 'A(-1, 0) and B(3, 0)',
      'point on f': 'C(2, 5)'
    }
  },
  
  caseSensitive: false,
  tolerance: 0,
  
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  updatedAt: admin.firestore.FieldValue.serverTimestamp()
};

/**
 * ========================================
 * CHILD QUESTION 3: Short Answer
 * ========================================
 */
const childQuestion3 = {
  id: 'child_func_001_3',
  
  format: 'short_answer',
  questionType: 'short_answer',
  answerType: 'equation',
  
  questionText: 'Determine the equation of g.',
  
  // Parent reference
  parentQuestionId: 'parent_func_001',
  usesParentImage: true,
  
  // Answer data
  correctAnswer: {
    value: 'g(x) = 2x + 1',
    variations: [
      'g(x) = 2x + 1',
      'g(x)=2x+1',
      'y = 2x + 1',
      '2x + 1',
      'g(x) = 2x+1',
      'g(x)=2x + 1'
    ]
  },
  marks: 5,
  
  // Metadata
  subject: 'mathematics',
  grade: 12,
  topic: 'Functions & Graphs',
  paper: 'p1',
  year: 2023,
  season: 'November',
  cognitiveLevel: 'Level 2', // Routine procedures
  difficulty: 'medium',
  
  availableInModes: ['pqp', 'sprint', 'by_topic'],
  
  pqpData: {
    questionNumber: '4.1.3',
    year: 2023,
    season: 'November',
    paper: 'p1',
    marks: 5,
    showWithParent: true
  },
  
  sprintData: {
    hint: 'Use two points A(-1, 0) and C(2, 5). Find gradient m = (y₂ - y₁)/(x₂ - x₁), then use y = mx + k.',
    timeEstimate: 5,
    providedContext: {
      'points on g': 'A(-1, 0) and C(2, 5)',
      'form': 'g(x) = mx + k'
    }
  },
  
  caseSensitive: false,
  tolerance: 0,
  
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
  updatedAt: admin.firestore.FieldValue.serverTimestamp()
};

/**
 * Upload questions to Firestore
 */
async function uploadParentChildTest() {
  try {
    console.log('🚀 Starting CORRECTED parent-child test upload...\n');
    console.log('📝 KEY STRUCTURE:');
    console.log('   • Parent = Context document (text + image)');
    console.log('   • Parent has NO "format" field (not answerable)');
    console.log('   • Parent has NO "sprintData" (children have hints)');
    console.log('   • Children = Answerable questions with formats');
    console.log('   • Children inherit parent image via "usesParentImage: true"\n');
    
    const batch = db.batch();
    
    // Upload parent (CONTEXT DOCUMENT)
    const parentRef = db.collection('questions').doc(parentQuestion.id);
    batch.set(parentRef, parentQuestion);
    console.log('✅ Prepared PARENT (Context Document):');
    console.log(`   ID: ${parentQuestion.id}`);
    console.log(`   Type: ${parentQuestion.type} (NOT a question format)`);
    console.log(`   isParent: ${parentQuestion.isParent}`);
    console.log(`   Context: "${parentQuestion.questionText.substring(0, 70)}..."`);
    console.log(`   Children: ${parentQuestion.childQuestionIds.length} sub-questions`);
    console.log(`   Total marks: ${parentQuestion.totalMarks}`);
    console.log(`   PQP Number: ${parentQuestion.pqpData.questionNumber}\n`);
    
    // Upload children (ANSWERABLE QUESTIONS)
    const children = [childQuestion1, childQuestion2, childQuestion3];
    children.forEach((child, index) => {
      const childRef = db.collection('questions').doc(child.id);
      batch.set(childRef, child);
      console.log(`✅ Prepared CHILD ${index + 1} (Answerable Question):`);
      console.log(`   ID: ${child.id}`);
      console.log(`   Format: ${child.format} ✅ (has answer format)`);
      console.log(`   Question: "${child.questionText}"`);
      console.log(`   PQP Number: ${child.pqpData.questionNumber}`);
      console.log(`   Marks: ${child.marks}`);
      console.log(`   Parent: ${child.parentQuestionId}`);
      console.log(`   Uses Parent Image: ${child.usesParentImage}`);
      console.log(`   Answer: ${child.correctAnswer.value}\n`);
    });
    
    // Commit batch
    await batch.commit();
    
    console.log('\n🎉 Successfully uploaded CORRECTED parent-child structure!');
    console.log('\n📊 Summary:');
    console.log('   • 1 Parent document (context provider, NO format field)');
    console.log('   • 3 Child questions (each has format field)');
    console.log('   • Topic: Functions & Graphs');
    console.log('   • Total marks: 13 (4 + 4 + 5)');
    console.log('   • PQP Numbering: 4.1 (parent), 4.1.1, 4.1.2, 4.1.3 (children)');
    console.log('\n✨ Questions are now LIVE in Firestore!');
    console.log('\n🔍 How to test:');
    console.log('   1. Run app and go to "By Topic" mode');
    console.log('   2. Select "Functions & Graphs" topic');
    console.log('   3. Verify parent context card appears for each child');
    console.log('   4. Check that all 3 children share the same graph image');
    console.log('   5. Test PQP mode - verify numbering: 4.1.1, 4.1.2, 4.1.3');
    console.log('\n💡 Parent Concept:');
    console.log('   • Parent is like a "scenario/diagram holder"');
    console.log('   • Parent itself is NEVER displayed as a standalone question');
    console.log('   • Parent content appears in the orange card above each child');
    console.log('   • This eliminates image duplication across child questions');
    
  } catch (error) {
    console.error('❌ Error uploading parent-child test:', error);
    throw error;
  } finally {
    process.exit(0);
  }
}

// Run upload
uploadParentChildTest();
