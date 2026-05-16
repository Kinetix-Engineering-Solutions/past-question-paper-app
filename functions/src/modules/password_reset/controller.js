const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { admin } = require('../../core/firebase');
const {
  assertPasswordResetEmailConfig,
  createPasswordResetLinkAndSendEmail,
} = require('./services/passwordReset.service');

function mapPasswordResetError(error) {
  if (error instanceof HttpsError) {
    return error;
  }

  const errorCode = (error && error.code ? String(error.code) : '').toLowerCase();
  const smtpCode = (error && error.code ? String(error.code) : '').toUpperCase();
  const responseCode = error && error.responseCode ? Number(error.responseCode) : null;

  if (errorCode === 'auth/invalid-email') {
    return new HttpsError('invalid-argument', 'The email address is not valid.');
  }

  if (
    errorCode === 'auth/invalid-continue-uri' ||
    errorCode === 'auth/missing-continue-uri' ||
    errorCode === 'auth/unauthorized-continue-uri'
  ) {
    return new HttpsError(
      'failed-precondition',
      'Password reset continue URL is misconfigured. Please contact support.',
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

  console.error('Unhandled error while sending password reset email:', {
    message: error && error.message,
    code: error && error.code,
    responseCode: error && error.responseCode,
    command: error && error.command,
    stack: error && error.stack,
  });
  return new HttpsError('internal', `Failed to send password reset email: ${error && error.message}`);
}

const createPasswordResetLink = onCall(
  {
    memory: '256MiB',
    timeoutSeconds: 30,
    maxInstances: 100,
  },
  async (request) => {
    try {
      assertPasswordResetEmailConfig();

      const email = (request.data && request.data.email ? String(request.data.email) : '').trim();
      if (!email) {
        throw new HttpsError('invalid-argument', 'Email is required.');
      }

      let authUser = null;
      try {
        authUser = await admin.auth().getUserByEmail(email);
      } catch (error) {
        const code = (error && error.code ? String(error.code) : '').toLowerCase();
        if (code === 'auth/user-not-found') {
          return {
            success: true,
            sent: false,
            message: 'If an account exists for this email, a reset link has been sent.',
          };
        }
        throw error;
      }

      await createPasswordResetLinkAndSendEmail({
        email,
        displayName: authUser.displayName || undefined,
      });

      return {
        success: true,
        sent: true,
        message: 'Password reset email sent successfully.',
      };
    } catch (error) {
      throw mapPasswordResetError(error);
    }
  },
);

module.exports = { createPasswordResetLink };
