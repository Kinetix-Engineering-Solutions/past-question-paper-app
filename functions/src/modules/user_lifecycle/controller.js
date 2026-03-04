const functionsV1 = require('firebase-functions/v1');
const { cleanupUserAccount } = require('./cleanup.service');

const onUserDeleteCleanup = functionsV1.auth.user().onDelete(async (user) => {
  const uid = user.uid;
  try {
    await cleanupUserAccount(uid);
  } catch (e) {
    console.error(`[UserCleanup] Unexpected error during cleanup for ${uid}`, e);
  }
});

module.exports = { onUserDeleteCleanup };
