const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { admin } = require('../../core/firebase');
const { validateTestParams } = require('../../helpers/validation');
const { generateTestPaper } = require('./services/test.service');

const generateTest = onCall(
  {
    memory: '256MiB',
    timeoutSeconds: 30,
    maxInstances: 100,
  },
  async (request) => {
    const context = request;
    const data = request.data;

    try {
      if (!context.auth) {
        throw new HttpsError('unauthenticated', 'You must be logged in to generate tests.');
      }

      const userId = context.auth.uid;
      console.log('Test generation request received from user:', userId);

      const userRef = admin.firestore().collection('users').doc(userId);
      const userDoc = await userRef.get();

      if (userDoc.exists) {
        const userData = userDoc.data();
        const lastGeneration = userData.lastTestGeneration;
        const now = Date.now();

        if (lastGeneration && (now - lastGeneration) < 3000) {
          throw new HttpsError(
            'resource-exhausted',
            'Please wait a moment before generating another test.',
          );
        }

        await userRef.update({
          lastTestGeneration: now,
          totalTestsGenerated: admin.firestore.FieldValue.increment(1),
        });
      }

      console.log('Test generation request received:', data);
      const params = data.data || data;

      validateTestParams(params);

      const requestedQuestions = params.numQuestions || 50;
      if (requestedQuestions > 100) {
        throw new HttpsError('invalid-argument', 'Cannot generate more than 100 questions at once.');
      }

      const testData = await generateTestPaper(params, userId);

      if ((params.mode || '').toString().toLowerCase() === 'retry_mistakes' &&
          (!testData || !Array.isArray(testData.questions) || testData.questions.length === 0)) {
        throw new HttpsError(
          'not-found',
          'No mistakes to retry yet. Complete a practice session first.',
        );
      }

      const sanitizedQuestions = testData.questions.map((question) => {
        const { correctAnswer, explanation, correctAnswers, ...sanitized } = question;
        sanitized.id = question.id;

        const format = (question.format || question.questionType || '').toLowerCase();
        if (format.includes('drag') && question.correctOrder) {
          sanitized.correctOrder = question.correctOrder;
        }
        if (format.includes('drag') && question.dragItems) {
          sanitized.dragItems = question.dragItems;
        }

        return sanitized;
      });

      console.log(`Successfully generated ${sanitizedQuestions.length} questions`);

      return {
        questions: sanitizedQuestions,
        totalQuestions: testData.totalQuestions,
        blueprint: testData.blueprint,
        generatedAt: testData.generatedAt,
      };
    } catch (error) {
      console.error('Error in generateTest:', error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError('internal', 'Failed to generate test. Please try again.');
    }
  },
);

module.exports = { generateTest };
