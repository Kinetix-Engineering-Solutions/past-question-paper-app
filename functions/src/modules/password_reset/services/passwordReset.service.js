const { Resend } = require('resend');
const { HttpsError } = require('firebase-functions/v2/https');
const { admin } = require('../../../core/firebase');

function assertPasswordResetEmailConfig() {
  const requiredEnvVars = [
    'RESEND_API_KEY',
    'RESEND_FROM_EMAIL',
  ];

  const missing = requiredEnvVars.filter((key) => !process.env[key]);
  if (missing.length > 0) {
    throw new HttpsError(
      'failed-precondition',
      `Missing password reset configuration: ${missing.join(', ')}`,
    );
  }

  const continueUrl = process.env.PASSWORD_RESET_CONTINUE_URL || process.env.EMAIL_VERIFICATION_CONTINUE_URL;
  if (!continueUrl) {
    throw new HttpsError(
      'failed-precondition',
      'Missing password reset continue URL. Please contact support.',
    );
  }
}

function buildEmailHtml({ recipientName, resetLink }) {
  const logoUrl = 'https://storage.googleapis.com/vibe-code-4c59f.firebasestorage.app/public/email-assets/logo.png';

  return `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; background-color: #F5F5F5; padding: 32px 24px;">
      <div style="text-align: center; margin-bottom: 24px;">
        <img src="${logoUrl}" alt="Past Question Papers" width="80" height="80" style="display: inline-block; border-radius: 16px;" />
      </div>
      <div style="background-color: #FFFFFF; border-radius: 12px; padding: 32px 24px; border: 1px solid #E5E5E5;">
        <h2 style="margin: 0 0 16px 0; color: #262626; font-size: 22px; text-align: center;">Reset your password</h2>
        <p style="line-height: 1.6; margin-bottom: 16px; color: #262626;">Hello ${recipientName},</p>
        <p style="line-height: 1.6; margin-bottom: 24px; color: #525252;">
          We received a request to reset your password for <strong>Past Question Papers</strong>.
        </p>
        <div style="text-align: center; margin-bottom: 24px;">
          <a
            href="${resetLink}"
            style="display: inline-block; background-color: #FF7A1A; color: #FFFFFF; text-decoration: none; padding: 14px 32px; border-radius: 8px; font-weight: 600; font-size: 16px;"
          >
            Reset password
          </a>
        </div>
        <p style="line-height: 1.6; color: #525252; font-size: 13px;">
          If the button does not work, copy and paste this link into your browser:
        </p>
        <p style="margin: 0 0 8px 0;">
          <a
            href="${resetLink}"
            style="color: #FF7A1A; font-size: 13px; font-weight: 600; text-decoration: underline;"
          >
            Open password reset link
          </a>
        </p>
        <p style="line-height: 1.5; color: #A3A3A3; font-size: 12px; margin: 0;">
          If you did not request a password reset, you can safely ignore this email.
        </p>
      </div>
      <p style="text-align: center; color: #A3A3A3; font-size: 11px; margin-top: 16px;">
        &copy; ${new Date().getFullYear()} Past Question Papers &middot; Kinetix Engineering Solutions
      </p>
    </div>
  `;
}

async function sendPasswordResetEmail({ to, recipientName, resetLink }) {
  const resend = new Resend(process.env.RESEND_API_KEY);
  const fromName = process.env.RESEND_FROM_NAME || 'Past Question Papers';
  const fromEmail = process.env.RESEND_FROM_EMAIL;

  const { error } = await resend.emails.send({
    from: `${fromName} <${fromEmail}>`,
    to,
    subject: 'Reset your Past Question Papers password',
    text: `Reset your password by opening this link: ${resetLink}`,
    html: buildEmailHtml({ recipientName, resetLink }),
  });

  if (error) {
    throw new Error(`Resend error: ${error.message}`);
  }
}

async function createPasswordResetLinkAndSendEmail({ email, displayName }) {
  const continueUrl = process.env.PASSWORD_RESET_CONTINUE_URL || process.env.EMAIL_VERIFICATION_CONTINUE_URL;
  const resetLink = await admin
    .auth()
    .generatePasswordResetLink(email, { url: continueUrl });

  await sendPasswordResetEmail({
    to: email,
    recipientName: displayName || 'there',
    resetLink,
  });
}

module.exports = {
  assertPasswordResetEmailConfig,
  createPasswordResetLinkAndSendEmail,
};
