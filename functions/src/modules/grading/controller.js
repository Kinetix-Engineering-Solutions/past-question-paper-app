const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { validateGradingParams } = require('../../helpers/validation');
const { gradeTestSubmission } = require('./services/grading.service');

const gradeTest = onCall(
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
        throw new HttpsError('unauthenticated', 'You must be logged in to submit tests for grading.');
      }

      const userId = context.auth.uid;
      console.log('🎯 Grading request received from user:', userId);

      const params = data.data || data;
      const {
        submissions,
        answers,
        subject,
        paper,
        mode,
        totalQuestions,
        durationMinutes,
        sessionDurationSeconds,
        sessionMetadata,
        flags,
      } = params;

      const submissionsData = submissions || answers;
      const submissionCount = Object.keys(submissionsData || {}).length;

      if (submissionCount > 100) {
        throw new HttpsError('invalid-argument', 'Cannot grade more than 100 questions at once.');
      }

      for (const [, answer] of Object.entries(submissionsData || {})) {
        if (typeof answer === 'string' && answer.length > 50000) {
          throw new HttpsError(
            'invalid-argument',
            'Answer text is too long. Maximum 50,000 characters per answer.',
          );
        }
      }

      console.log('📋 Received parameters:', {
        hasSubmissions: !!submissions || !!answers,
        contextAuthUid: context.auth?.uid,
        subject,
        paper,
        mode,
        totalQuestions,
        durationMinutes,
      });

      validateGradingParams({ submissions: submissionsData });

      const finalUserId = context.auth.uid;
      console.log('✅ Final userId for storage:', finalUserId || '⚠️ WARNING: No userId available');
      console.log('   - Received userId param:', userId);
      console.log('   - Context auth uid:', context.auth?.uid);
      console.log('   - Using:', finalUserId);

      const metadata = {
        subject: subject || sessionMetadata?.subject || null,
        paper: paper || sessionMetadata?.paper || sessionMetadata?.selectedPaper || null,
        mode: mode || sessionMetadata?.modeKey || 'Practice',
        totalQuestions:
          totalQuestions || sessionMetadata?.totalQuestions ||
          (submissionsData ? Object.keys(submissionsData).length : null),
        durationMinutes:
          durationMinutes ?? sessionMetadata?.configuredDurationMinutes ?? sessionMetadata?.duration ?? null,
        sessionDurationSeconds: sessionDurationSeconds ?? sessionMetadata?.sessionDurationSeconds ?? null,
        flags: flags || {},
        sessionMetadata: sessionMetadata || {},
        submittedAt: params.submittedAt || new Date().toISOString(),
      };

      const gradingResult = await gradeTestSubmission({
        submissions: submissionsData,
        userId: finalUserId,
        metadata,
      });

      console.log('✅ Grading completed successfully');

      return {
        results: gradingResult.results,
        statistics: gradingResult.statistics,
        gradedAt: gradingResult.gradedAt,
      };
    } catch (error) {
      console.error('❌ Error in gradeTest:', error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError('internal', 'Failed to grade test. Please try again.');
    }
  },
);

module.exports = { gradeTest };
