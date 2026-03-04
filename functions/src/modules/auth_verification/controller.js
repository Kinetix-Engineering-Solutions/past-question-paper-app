const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { admin } = require('../../core/firebase');
const {
  createVerificationLinkAndSendEmail,
  assertVerificationEmailConfig,
} = require('./services/emailVerification.service');

const RESEND_COOLDOWN_MS = 60 * 1000;

function mapVerificationError(error) {
  if (error instanceof HttpsError) {
    return error;
  }

  const errorCode = (error && error.code ? String(error.code) : '').toLowerCase();
  const smtpCode = (error && error.code ? String(error.code) : '').toUpperCase();
  const responseCode = error && error.responseCode ? Number(error.responseCode) : null;

  if (
    errorCode === 'auth/invalid-continue-uri' ||
    errorCode === 'auth/missing-continue-uri' ||
    errorCode === 'auth/unauthorized-continue-uri'
  ) {
    return new HttpsError(
      'failed-precondition',
      'Email verification continue URL is misconfigured. Please contact support.',
    );
  }

  if (smtpCode === 'EAUTH' || responseCode === 535) {
    return new HttpsError(
      'failed-precondition',
      'Email provider authentication failed. Please contact support.',
    );
  }

  if (smtpCode === 'ECONNECTION' || smtpCode === 'ETIMEDOUT' || smtpCode === 'ESOCKET') {
    return new HttpsError(
      'unavailable',
      'Email service is temporarily unavailable. Please try again shortly.',
    );
  }

  console.error('Unhandled error while sending verification email:', {
    message: error && error.message,
    code: error && error.code,
    responseCode: error && error.responseCode,
    command: error && error.command,
    stack: error && error.stack,
  });
  return new HttpsError('internal', `Failed to send verification email: ${error && error.message}`);
}

const createEmailVerificationLink = onCall(
  {
    memory: '256MiB',
    timeoutSeconds: 30,
    maxInstances: 100,
  },
  async (request) => {
    try {
      if (!request.auth) {
        throw new HttpsError('unauthenticated', 'You must be logged in to request email verification.');
      }

      assertVerificationEmailConfig();

      const userId = request.auth.uid;
      const authUser = await admin.auth().getUser(userId);
      const email = authUser.email;

      if (!email) {
        throw new HttpsError('failed-precondition', 'No email address is available for this account.');
      }

      if (authUser.emailVerified) {
        return {
          success: true,
          alreadyVerified: true,
          message: 'Email is already verified.',
        };
      }

      const userRef = admin.firestore().collection('users').doc(userId);
      const userDoc = await userRef.get();
      const userData = userDoc.data() || {};
      const now = Date.now();
      const lastSentAt = userData.lastVerificationEmailSentAt || 0;

      if (lastSentAt && (now - lastSentAt) < RESEND_COOLDOWN_MS) {
        const secondsRemaining = Math.ceil((RESEND_COOLDOWN_MS - (now - lastSentAt)) / 1000);
        throw new HttpsError(
          'resource-exhausted',
          `Please wait ${secondsRemaining} seconds before requesting another verification email.`,
        );
      }

      console.log(`[createEmailVerificationLink] Generating link for uid=${userId} email=${email}`);
      await createVerificationLinkAndSendEmail({
        email,
        displayName: authUser.displayName || undefined,
      });
      console.log(`[createEmailVerificationLink] Email sent successfully to ${email}`);

      await userRef.set({
        lastVerificationEmailSentAt: now,
        totalVerificationEmailsSent: admin.firestore.FieldValue.increment(1),
      }, { merge: true });

      return {
        success: true,
        alreadyVerified: false,
        message: 'Verification email sent successfully.',
        cooldownSeconds: Math.floor(RESEND_COOLDOWN_MS / 1000),
      };
    } catch (error) {
      throw mapVerificationError(error);
    }
  },
);

module.exports = { createEmailVerificationLink };
