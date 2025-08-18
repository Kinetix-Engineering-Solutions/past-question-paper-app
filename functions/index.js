const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.generateTest = functions.https.onCall(async (data, context) => {
  // 1. Verify user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }

  // 2. Get user request data (grade, subject, mode, etc.)
  const { grade, subject, paper, year, season, mode } = data;

  // 3. Build the Firestore query based on the request
  let query = admin.firestore().collection("questions");

  if (grade) query = query.where("grade", "==", grade);
  if (subject) query = query.where("subject", "==", subject);
  if (paper) query = query.where("paper", "==", paper);
  if (year) query = query.where("year", "==", year);
  if (season) query = query.where("season", "==", season);

  // TODO: Add advanced blueprint logic here to select questions
  // based on topic and cognitive level weightings for 'full_exam' or 'quick_practice' modes.
  // For now, we will fetch a simple limit.
  query = query.limit(20); // Placeholder limit

  const snapshot = await query.get();
  const questions = [];

  snapshot.forEach((doc) => {
    const questionData = doc.data();

    // 4. CRITICAL: Remove sensitive fields before sending to the client
    delete questionData.correctAnswer;
    delete questionData.explanation;

    questions.push({
      id: doc.id,
      ...questionData,
    });
  });

  // 5. Return the array of question objects
  return { questions };
});

exports.gradeTest = functions.https.onCall(async (data, context) => {
  // 1. Verify user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }

  const userId = context.auth.uid;
  const userAnswers = data.answers; // e.g., { "questionId1": "userAnswer1", ... }
  const questionIds = Object.keys(userAnswers);

  let score = 0;
  let totalMarks = 0;

  // 2. Securely fetch correct answers from Firestore for each question
  const questionPromises = questionIds.map((id) =>
    admin.firestore().collection("questions").doc(id).get()
  );
  const questionDocs = await Promise.all(questionPromises);

  // 3. Compare user answers to the correct answers and calculate score
  questionDocs.forEach((doc) => {
    if (doc.exists) {
      const questionData = doc.data();
      const questionId = doc.id;
      const correctAnswer = questionData.correctAnswer.toString();
      const userAnswer = userAnswers[questionId];
      const marks = questionData.marks || 0;
      totalMarks += marks;

      if (userAnswer === correctAnswer) {
        score += marks;
      }
    }
  });

  // 4. Save the result to a sub-collection in the user's document
  await admin
    .firestore()
    .collection("users")
    .doc(userId)
    .collection("testResults")
    .add({
      testDate: admin.firestore.FieldValue.serverTimestamp(),
      score: score,
      totalMarks: totalMarks,
      subject: data.subject, // Pass subject from the app
      paper: data.paper, // Pass paper from the app
    });

  // 5. Return the final score summary
  return { score, totalMarks };
});