const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.generateTest = functions.https.onCall(async (data, context) => {
  // Authentication check temporarily disabled for testing
  // if (!context.auth) {
  //   throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated.');
  // }

  // The data comes wrapped in a data object from Firebase callable functions
  const { grade, subject, paper, mode, year, season, topic, duration } = data.data || data;
  
  console.log('Received test generation request:', data);
  console.log('Extracted parameters - Grade:', grade, 'Subject:', subject, 'Mode:', mode);

  // Validate required fields - check for null/undefined and ensure grade is a valid number
  if (grade === null || grade === undefined || typeof grade !== 'number' || !subject) {
    console.log('Validation failed - Grade:', grade, 'Type:', typeof grade, 'Subject:', subject);
    throw new functions.https.HttpsError('invalid-argument', 'Grade (as number) and subject are required.');
  }

  try {
    let questions = [];
    
    if (mode === 'full_exam') {
      // Handle full exam mode
      if (!paper) {
        throw new functions.https.HttpsError('invalid-argument', 'Paper is required for full exam mode.');
      }
      
      // Normalize paper format to handle both "paper 1" and "p1" formats
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
      
      const blueprintId = `${subject}_${normalizedPaper}_gr${grade}`.toLowerCase();
      console.log('Looking for blueprint:', blueprintId);

      const blueprintDoc = await admin.firestore()
        .collection('blueprints')
        .doc(blueprintId)
        .get();

      if (!blueprintDoc.exists) {
        console.error('Blueprint not found:', blueprintId);
        throw new functions.https.HttpsError('not-found', 'Exam format not found. Please check your subject and paper selection.');
      }

      const blueprint = blueprintDoc.data();
      console.log('Blueprint found:', blueprint);

      // Build query based on blueprint requirements
      let query = admin.firestore().collection('questions')
        .where('grade', '==', grade)
        .where('subject', '==', subject)
        .where('paper', '==', paper) // Use original paper format for question query
        .limit(blueprint.totalQuestions || 50);

      if (year) {
        query = query.where('year', '==', year);
      }
      if (season) {
        query = query.where('season', '==', season);
      }

      const questionSnapshot = await query.get();
      
      if (questionSnapshot.empty) {
        console.error('No questions found for query:', {
          grade, subject, paper, year, season
        });
        throw new functions.https.HttpsError('not-found', 'No questions found for the selected criteria.');
      }

      questions = questionSnapshot.docs.map(doc => {
        const questionData = doc.data();
        console.log('Raw question data from Firestore:', questionData);
        console.log('Available fields:', Object.keys(questionData));
        
        return {
          id: doc.id,
          questionText: questionData.questionText || questionData.question_text || questionData.text,
          options: questionData.options || questionData.choices || questionData.answers,
          questionType: questionData.questionType || questionData.question_type || questionData.type,
          marks: questionData.marks || questionData.mark || questionData.points || 1, // Default to 1 if not found
          // Strip sensitive data
        };
      });

    } else if (mode === 'quick_practice') {
      // Handle quick practice mode
      const questionCount = duration === 15 ? 10 : 20; // Adjust based on duration
      
      const query = admin.firestore().collection('questions')
        .where('grade', '==', grade)
        .where('subject', '==', subject)
        .limit(questionCount);

      const questionSnapshot = await query.get();
      
      if (questionSnapshot.empty) {
        throw new functions.https.HttpsError('not-found', 'No questions found for quick practice.');
      }

      questions = questionSnapshot.docs.map(doc => {
        const questionData = doc.data();
        console.log('Quick practice - Raw question data from Firestore:', questionData);
        console.log('Available fields:', Object.keys(questionData));
        
        return {
          id: doc.id,
          questionText: questionData.questionText || questionData.question_text || questionData.text,
          options: questionData.options || questionData.choices || questionData.answers,
          questionType: questionData.questionType || questionData.question_type || questionData.type,
          marks: questionData.marks || questionData.mark || questionData.points || 1,
        };
      });

    } else if (mode === 'by_topic') {
      // Handle by topic mode
      if (!topic) {
        throw new functions.https.HttpsError('invalid-argument', 'Topic is required for topic-based practice.');
      }

      const query = admin.firestore().collection('questions')
        .where('grade', '==', grade)
        .where('subject', '==', subject)
        .where('topic', '==', topic)
        .limit(20);

      const questionSnapshot = await query.get();
      
      if (questionSnapshot.empty) {
        throw new functions.https.HttpsError('not-found', `No questions found for topic: ${topic}`);
      }

      questions = questionSnapshot.docs.map(doc => {
        const questionData = doc.data();
        console.log('By topic - Raw question data from Firestore:', questionData);
        console.log('Available fields:', Object.keys(questionData));
        
        return {
          id: doc.id,
          questionText: questionData.questionText || questionData.question_text || questionData.text,
          options: questionData.options || questionData.choices || questionData.answers,
          questionType: questionData.questionType || questionData.question_type || questionData.type,
          marks: questionData.marks || questionData.mark || questionData.points || 1,
        };
      });

    } else {
      throw new functions.https.HttpsError('invalid-argument', 'Invalid test mode.');
    }

    // Strip answers and explanations before sending to client
    const sanitizedQuestions = questions.map(question => {
      const { correctAnswer, explanation, ...sanitized } = question;
      return sanitized;
    });

    console.log(`Returning ${sanitizedQuestions.length} questions for mode: ${mode}`);
    return sanitizedQuestions;

  } catch (error) {
    console.error('Error generating test:', error);
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', 'Failed to generate test. Please try again.');
  }
});

exports.gradeTest = functions.https.onCall(async (data, context) => {
  // Authentication check temporarily disabled for testing
  // if (!context.auth) {
  //   throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated.');
  // }

  // The data comes wrapped in a data object from Firebase callable functions
  const { answers, testOptions } = data.data || data;
  
  try {
    // Fetch correct answers securely from Firestore
    const questionIds = Object.keys(answers);
    const questionsSnapshot = await admin.firestore()
      .collection('questions')
      .where(admin.firestore.FieldPath.documentId(), 'in', questionIds)
      .get();

    if (questionsSnapshot.empty) {
      throw new functions.https.HttpsError('not-found', 'Questions not found for grading.');
    }

    // Calculate score
    let totalScore = 0;
    let maxPossibleScore = 0;
    const results = {};

    questionsSnapshot.forEach(doc => {
      const question = doc.data();
      const userAnswer = answers[doc.id];
      const isCorrect = userAnswer === question.correctAnswer;
      
      if (isCorrect) {
        totalScore += question.marks || 1;
      }
      
      maxPossibleScore += question.marks || 1;
      
      results[doc.id] = {
        correct: isCorrect,
        correctAnswer: question.correctAnswer,
        explanation: question.explanation,
        userAnswer: userAnswer,
        marks: question.marks || 1,
        earnedMarks: isCorrect ? question.marks || 1 : 0
      };
    });

    // Save results to user's profile (temporarily disabled during testing)
    // const userId = context.auth.uid;
    const resultData = {
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      score: totalScore,
      totalPossible: maxPossibleScore,
      percentage: (totalScore / maxPossibleScore) * 100,
      testOptions: testOptions,
      results: results
    };

    // Temporarily skip saving to user profile during testing
    // await admin.firestore()
    //   .collection('users')
    //   .doc(userId)
    //   .collection('testResults')
    //   .add(resultData);

    return {
      score: totalScore,
      totalPossible: maxPossibleScore,
      percentage: (totalScore / maxPossibleScore) * 100,
      results: results
    };

  } catch (error) {
    console.error('Error grading test:', error);
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', 'Failed to grade test. Please try again.');
  }
});