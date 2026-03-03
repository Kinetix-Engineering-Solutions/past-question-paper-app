const { generateTest } = require('./modules/test_generation/controller');
const { gradeTest } = require('./modules/grading/controller');
const { onUserDeleteCleanup } = require('./modules/user_lifecycle/controller');
const { createEmailVerificationLink } = require('./modules/auth_verification/controller');

module.exports = {
  generateTest,
  gradeTest,
  onUserDeleteCleanup,
  createEmailVerificationLink,
};
