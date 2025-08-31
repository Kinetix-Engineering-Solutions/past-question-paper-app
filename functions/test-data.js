// Script to add test questions to Firestore
const admin = require('firebase-admin');

// Initialize Firebase Admin with project ID
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  projectId: 'vibe-code-4c59f'
});

const testQuestions = [
  {
    // Mathematics questions
    subject: "Mathematics",
    paper: "Paper 1", 
    grade: 12,
    topic: "Algebra",
    cognitiveLevel: "Application",
    marks: 5,
    year: 2023,
    season: "Summer",
    format: "MCQ",
    questionText: "Solve for x: $2x + 5 = 13$",
    imageUrl: null,
    options: ["x = 3", "x = 4", "x = 5", "x = 6"],
    optionImages: null,
    correctOrder: [],
    correctAnswer: "x = 4",
    explanation: "Subtract 5 from both sides: 2x = 8, then divide by 2: x = 4"
  },
  {
    subject: "Mathematics",
    paper: "Paper 1",
    grade: 12, 
    topic: "Calculus",
    cognitiveLevel: "Knowledge",
    marks: 3,
    year: 2023,
    season: "Summer",
    format: "MCQ",
    questionText: "What is the derivative of $x^2$?",
    imageUrl: null,
    options: ["x", "2x", "x²", "2x²"],
    optionImages: null,
    correctOrder: [],
    correctAnswer: "2x",
    explanation: "Using the power rule: d/dx(x^n) = nx^(n-1), so d/dx(x^2) = 2x"
  },
  {
    // Physics questions
    subject: "Physics", 
    paper: "Paper 2",
    grade: 12,
    topic: "Mechanics",
    cognitiveLevel: "Application",
    marks: 4,
    year: 2023,
    season: "Summer", 
    format: "MCQ",
    questionText: "A car accelerates from 0 to 20 m/s in 4 seconds. What is its acceleration?",
    imageUrl: null,
    options: ["2 m/s²", "5 m/s²", "10 m/s²", "20 m/s²"],
    optionImages: null,
    correctOrder: [],
    correctAnswer: "5 m/s²",
    explanation: "Acceleration = (final velocity - initial velocity) / time = (20 - 0) / 4 = 5 m/s²"
  }
];

async function addTestQuestions() {
  const db = admin.firestore();
  
  for (let i = 0; i < testQuestions.length; i++) {
    await db.collection('questions').add(testQuestions[i]);
    console.log(`Added question ${i + 1}`);
  }
  
  console.log('All test questions added successfully!');
}

// Uncomment to run: node test-data.js
addTestQuestions().catch(console.error);

module.exports = { testQuestions };
