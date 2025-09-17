const admin = require('firebase-admin');
// IMPORTANT: Make sure you have a 'serviceAccountKey.json' in the root of this folder.
try {
  const serviceAccount = require('./serviceAccountKey.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
} catch (e) {
  console.error("❌ ERROR: serviceAccountKey.json not found or invalid.");
  console.error("Please download it from your Firebase project settings and place it in the root directory.");
  process.exit(1);
}


const db = admin.firestore();

// --- Configuration ---
const TARGET_COLLECTION = 'questions_test';
const SUBJECT_TO_GENERATE = 'mathematics';
const QUESTIONS_TO_GENERATE = 100;
const BATCH_SIZE = 250; // Firestore batch write limit is 500 operations

const TOPICS = {
  mathematics: ['Algebra', 'Functions & Graphs', 'Differential Calculus', 'Probability', 'Geometry'],
};

const COGNITIVE_LEVELS = ['Level 1', 'Level 2', 'Level 3', 'Level 4'];

/**
 * Generates a random integer between min and max (inclusive)
 */
function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

/**
 * Generates a single realistic question object
 * @param {number} id - The unique ID for the question
 * @param {string} subject - The subject of the question
 * @returns {Object} A question object
 */
function generateQuestion(id, subject) {
  const topic = TOPICS[subject][getRandomInt(0, TOPICS[subject].length - 1)];
  const cognitiveLevel = COGNITIVE_LEVELS[getRandomInt(0, COGNITIVE_LEVELS.length - 1)];
  const marks = getRandomInt(3, 25);
  const year = getRandomInt(2010, 2023);
  const questionNumber = getRandomInt(1, 12);

  return {
    id: `${subject}_test_q${id}`,
    subject: subject,
    paper: 'paper_1',
    grade: '12',
    topic: topic,
    cognitiveLevel: cognitiveLevel,
    maxMarks: marks,
    year: year,
    questionNumber: `Q${questionNumber}`,
    description: `This is a sample test question for ${topic} from the year ${year}. It is worth ${marks} marks and is considered ${cognitiveLevel}.`,
    subQuestions: [],
    source: 'Simulated Exam Board',
    difficulty: Math.random()
  };
}

/**
 * Deletes all documents from a collection in batches.
 * @param {CollectionReference} collectionRef - The Firestore collection reference.
 */
async function deleteCollection(collectionRef) {
  const query = collectionRef.limit(BATCH_SIZE);
  let snapshot;

  console.log(`🔥 Deleting all documents from the '${TARGET_COLLECTION}' collection...`);
  let deletedCount = 0;
  while ((snapshot = await query.get()).size > 0) {
    const batch = db.batch();
    snapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });
    await batch.commit();
    deletedCount += snapshot.size;
    console.log(`  ...deleted ${deletedCount} documents.`);
  }
  if (deletedCount === 0) {
    console.log(`  Collection '${TARGET_COLLECTION}' was already empty.`);
  } else {
    console.log(`✅ Finished deleting ${deletedCount} documents.`);
  }
}

/**
 * Populates the target collection with a set of simulated data.
 */
async function populateDatabase() {
  console.log('� Starting database population...');
  const questionsCollection = db.collection(TARGET_COLLECTION);

  // 1. Clear existing questions from the test collection
  await deleteCollection(questionsCollection);

  // 2. Generate and upload new questions
  console.log(`✨ Generating and uploading ${QUESTIONS_TO_GENERATE} new questions for '${SUBJECT_TO_GENERATE}'...`);
  
  const questions = [];
  for (let i = 1; i <= QUESTIONS_TO_GENERATE; i++) {
    questions.push(generateQuestion(i, SUBJECT_TO_GENERATE));
  }

  // Upload in batches
  for (let i = 0; i < questions.length; i += BATCH_SIZE) {
    const batch = db.batch();
    const batchQuestions = questions.slice(i, i + BATCH_SIZE);
    
    batchQuestions.forEach(question => {
      const docRef = questionsCollection.doc(question.id);
      batch.set(docRef, question);
    });
    
    await batch.commit();
    console.log(`  Uploaded batch of ${batchQuestions.length} questions.`);
  }

  console.log(`\n✅ Database population complete. Total questions uploaded: ${questions.length}.`);
  console.log(`➡️  You can now see the data in your Firestore console under the '${TARGET_COLLECTION}' collection.`);
}

populateDatabase().catch(error => {
  console.error('❌ An error occurred during database population:', error);
  process.exit(1);
});
