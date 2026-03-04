const { Resend } = require('resend');
const { HttpsError } = require('firebase-functions/v2/https');
const { admin } = require('../../../core/firebase');

function assertVerificationEmailConfig() {
  const requiredEnvVars = [
    'RESEND_API_KEY',
    'RESEND_FROM_EMAIL',
  ];

  const missing = requiredEnvVars.filter((key) => !process.env[key]);
  if (missing.length > 0) {
    throw new HttpsError(
      'failed-precondition',
      `Missing email verification configuration: ${missing.join(', ')}`,
    );
  }
}

function buildEmailHtml({ recipientName, verificationLink }) {
  const logoUrl = 'https://storage.googleapis.com/vibe-code-4c59f.firebasestorage.app/public/email-assets/logo.png';

  return `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; background-color: #F5F5F5; padding: 32px 24px;">
      <div style="text-align: center; margin-bottom: 24px;">
        <img src="${logoUrl}" alt="Past Question Papers" width="80" height="80" style="display: inline-block; border-radius: 16px;" />
      </div>
      <div style="background-color: #FFFFFF; border-radius: 12px; padding: 32px 24px; border: 1px solid #E5E5E5;">
        <h2 style="margin: 0 0 16px 0; color: #262626; font-size: 22px; text-align: center;">Verify your email</h2>
        <p style="line-height: 1.6; margin-bottom: 16px; color: #262626;">Hello ${recipientName},</p>
        <p style="line-height: 1.6; margin-bottom: 24px; color: #525252;">
          Thanks for signing up for <strong>Past Question Papers</strong>. Please verify your email address to get started.
        </p>
        <div style="text-align: center; margin-bottom: 24px;">
          <a
            href="${verificationLink}"
            style="display: inline-block; background-color: #FF7A1A; color: #FFFFFF; text-decoration: none; padding: 14px 32px; border-radius: 8px; font-weight: 600; font-size: 16px;"
          >
            Verify email
          </a>
        </div>
        <p style="line-height: 1.6; color: #525252; font-size: 13px;">
          If the button does not work, copy and paste this link into your browser:
        </p>
        <p style="margin: 0 0 8px 0;">
          <a
            href="${verificationLink}"
            style="color: #FF7A1A; font-size: 13px; font-weight: 600; text-decoration: underline;"
          >
            Open verification link
          </a>
        </p>
        <p style="line-height: 1.5; color: #A3A3A3; font-size: 12px; margin: 0;">
          You can also long-press or right-click the link above and open it in your browser.
        </p>
        <hr style="border: none; border-top: 1px solid #E5E5E5; margin: 24px 0;" />
        <p style="line-height: 1.5; color: #A3A3A3; font-size: 12px; text-align: center;">
          If you did not create this account, you can safely ignore this email.
        </p>
      </div>
      <p style="text-align: center; color: #A3A3A3; font-size: 11px; margin-top: 16px;">
        &copy; ${new Date().getFullYear()} Past Question Papers &middot; Kinetix Engineering Solutions
      </p>
    </div>
  `;
}

async function sendVerificationEmail({ to, recipientName, verificationLink }) {
  const resend = new Resend(process.env.RESEND_API_KEY);
  const fromName = process.env.RESEND_FROM_NAME || 'Past Question Papers';
  const fromEmail = process.env.RESEND_FROM_EMAIL;

  const { error } = await resend.emails.send({
    from: `${fromName} <${fromEmail}>`,
    to,
    subject: 'Verify your email address',
    text: `Verify your email by opening this link: ${verificationLink}`,
    html: buildEmailHtml({ recipientName, verificationLink }),
  });

  if (error) {
    throw new Error(`Resend error: ${error.message}`);
  }
}

async function createVerificationLinkAndSendEmail({ email, displayName }) {
  const verificationLink = await admin
    .auth()
    .generateEmailVerificationLink(email);

  await sendVerificationEmail({
    to: email,
    recipientName: displayName || 'there',
    verificationLink,
  });
}

module.exports = {
  createVerificationLinkAndSendEmail,
  assertVerificationEmailConfig,
};
