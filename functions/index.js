const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Cloud Function to generate a test
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

      // Fetch the blueprint document from Firestore
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

      // Map Firestore documents to Question objects
      questions = questionSnapshot.docs.map(doc => {
        const questionData = doc.data();
        console.log('Raw question data from Firestore:', questionData);
        console.log('Available fields:', Object.keys(questionData));
        
        // Helper function to safely convert Firestore data
        const safeArray = (data) => {
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
        };
        
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
          
          // Drag and drop specific fields - safely convert Firestore objects
          dragItems: safeArray(questionData.dragItems),
          dragTargets: safeArray(questionData.dragTargets || questionData.dropTargets),
          
          // Legacy fields for backward compatibility
          correctOrder: Array.isArray(questionData.correctOrder) ? questionData.correctOrder : [],
          
          // Other fields
          points: questionData.points,
          timeAllocation: questionData.timeAllocation,
          
          // Note: correctAnswer and explanation are stripped for security
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
        
        // Helper function to safely convert Firestore data
        const safeArray = (data) => {
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
        };
        
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
          
          // Drag and drop specific fields - safely convert Firestore objects
          dragItems: safeArray(questionData.dragItems),
          dragTargets: safeArray(questionData.dragTargets || questionData.dropTargets),
          
          // Legacy fields for backward compatibility
          correctOrder: Array.isArray(questionData.correctOrder) ? questionData.correctOrder : [],
          
          // Other fields
          points: questionData.points,
          timeAllocation: questionData.timeAllocation,
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
        
        // Helper function to safely convert Firestore data
        const safeArray = (data) => {
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
        };
        
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
          
          // Drag and drop specific fields - safely convert Firestore objects
          dragItems: safeArray(questionData.dragItems),
          dragTargets: safeArray(questionData.dragTargets || questionData.dropTargets),
          
          // Legacy fields for backward compatibility
          correctOrder: Array.isArray(questionData.correctOrder) ? questionData.correctOrder : [],
          
          // Other fields
          points: questionData.points,
          timeAllocation: questionData.timeAllocation,
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
      
      // Handle different question types for grading
      let isCorrect = false;
      
      if (question.format === 'drag-and-drop' || question.questionType === 'drag-and-drop') {
        // Handle drag-and-drop grading
        isCorrect = gradeDragAndDropAnswer(userAnswer, question);
      } else {
        // Handle regular question types (MCQ, True/False, etc.)
        isCorrect = userAnswer === question.correctAnswer;
      }
      
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

    // Helper function to grade drag-and-drop answers
    function gradeDragAndDropAnswer(userAnswer, question) {
      if (!userAnswer || !question.dragTargets || !question.dragItems) {
        return false;
      }
      
      try {
        // Parse user answer format: "target1:item4,target2:item2"
        const userPairs = {};
        const pairs = userAnswer.split(',');
        
        for (const pair of pairs) {
          const parts = pair.split(':');
          if (parts.length === 2) {
            userPairs[parts[0]] = parts[1];
          }
        }
        
        // Check if all targets have correct pairs
        for (const target of question.dragTargets) {
          const userItem = userPairs[target.id];
          if (userItem !== target.correctPair) {
            return false;
          }
        }
        
        // Check if user provided answers for all targets
        return Object.keys(userPairs).length === question.dragTargets.length;
        
      } catch (error) {
        console.error('Error grading drag-and-drop answer:', error);
        return false;
      }
    }

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