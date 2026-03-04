const { admin } = require('../../core/firebase');

async function cleanupUserAccount(uid) {
  const firestore = admin.firestore();
  const bucket = admin.storage().bucket();
  console.log(`[UserCleanup] Starting cleanup for uid=${uid}`);

  try {
    await firestore.collection('users').doc(uid).delete();
    console.log(`[UserCleanup] Deleted users/${uid}`);
  } catch (e) {
    console.error(`[UserCleanup] Failed deleting users/${uid}`, e);
  }

  try {
    const sessionsSnap = await firestore.collection('test_sessions').where('userId', '==', uid).get();
    if (!sessionsSnap.empty) {
      const batch = firestore.batch();
      sessionsSnap.forEach((doc) => batch.delete(doc.ref));
      await batch.commit();
      console.log(`[UserCleanup] Deleted ${sessionsSnap.size} test_sessions for uid=${uid}`);
    } else {
      console.log('[UserCleanup] No test_sessions found for user');
    }
  } catch (e) {
    console.error(`[UserCleanup] Failed deleting test_sessions for ${uid}`, e);
  }

  const prefixes = [
    `user_uploads/${uid}/`,
    `profile_images/${uid}/`,
  ];

  for (const prefix of prefixes) {
    try {
      await bucket.deleteFiles({ prefix });
      console.log(`[UserCleanup] Deleted storage prefix ${prefix}`);
    } catch (e) {
      if (e && e.code !== 404) {
        console.error(`[UserCleanup] Failed deleting storage prefix ${prefix}`, e);
      }
    }
  }

  console.log(`[UserCleanup] Completed cleanup for uid=${uid}`);
}

module.exports = { cleanupUserAccount };
