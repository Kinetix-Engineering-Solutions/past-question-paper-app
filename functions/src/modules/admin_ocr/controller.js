const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { extractDraftFromMathpix } = require('./services/ocrDraft.service');

const extractQuestionDraftFromImage = onCall(
  {
    memory: '512MiB',
    timeoutSeconds: 30,
    maxInstances: 20,
  },
  async (request) => {
    try {
      if (!request.auth) {
        throw new HttpsError('unauthenticated', 'You must be logged in to extract OCR drafts.');
      }

      const params = request.data?.data || request.data || {};
      const imageUrl = params.imageUrl;

      if (!imageUrl || typeof imageUrl !== 'string') {
        throw new HttpsError('invalid-argument', 'imageUrl is required.');
      }

      if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
        throw new HttpsError('invalid-argument', 'imageUrl must be a valid HTTP(S) URL.');
      }

      if (imageUrl.length > 5000) {
        throw new HttpsError('invalid-argument', 'imageUrl is too long.');
      }

      const draft = await extractDraftFromMathpix(imageUrl);

      return {
        draft,
        provider: 'mathpix',
      };
    } catch (error) {
      console.error('Error in extractQuestionDraftFromImage:', error);
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError('internal', error.message || 'Failed to extract OCR draft.');
    }
  },
);

module.exports = { extractQuestionDraftFromImage };
