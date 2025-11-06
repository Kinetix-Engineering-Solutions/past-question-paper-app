/**
 * Delete Test Users Script
 * 
 * This script deletes test user accounts from both Firebase Auth and Firestore.
 * It removes:
 * - Firebase Authentication account
 * - User document in Firestore (users collection)
 * - Any test sessions (test_sessions collection)
 * - Any user-generated content
 * 
 * Usage:
 *   node tools/deleteTestUsers.js
 * 
 * WARNING: This action is irreversible!
 */

const admin = require('firebase-admin');
const serviceAccount = require('../../serviceAccountKey.json');

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'vibe-code-4c59f'
});

const auth = admin.auth();
const db = admin.firestore();

// ============================================
// ADD YOUR TEST USER EMAILS HERE
// ============================================
const TEST_USER_EMAILS = [
  // Example: 'test1@example.com',
  // Example: 'test2@example.com',
  // Example: 'testuser@test.com',
  'irvinsenwedi25@gmail.com',
   'irvinsenwedi10@gmail.com',
  'irvinsenwedi@gmail.com',
  'user1234@gmail.com',
  'asdfg@gmail.com',
  'user1234@gmail.com',
  'user1@gmail.com',



 ,
 

  // Add your test account emails here, one per line
];

// ============================================
// Configuration
// ============================================
const DRY_RUN = false; // Set to true to see what would be deleted without actually deleting
const DELETE_TEST_SESSIONS = true; // Delete user's test sessions
const DELETE_USER_DATA = true; // Delete user profile from Firestore

// ============================================
// Deletion Functions
// ============================================

/**
 * Delete a user's test sessions from Firestore
 */
async function deleteUserTestSessions(uid, email) {
  if (!DELETE_TEST_SESSIONS) return;

  try {
    const sessionsSnapshot = await db.collection('test_sessions')
      .where('userId', '==', uid)
      .get();

    if (sessionsSnapshot.empty) {
      console.log(`   ℹ️  No test sessions found for ${email}`);
      return;
    }

    if (DRY_RUN) {
      console.log(`   🔍 [DRY RUN] Would delete ${sessionsSnapshot.size} test session(s)`);
      return;
    }

    const batch = db.batch();
    sessionsSnapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`   ✓ Deleted ${sessionsSnapshot.size} test session(s)`);
  } catch (error) {
    console.error(`   ✗ Error deleting test sessions: ${error.message}`);
  }
}

/**
 * Delete a user's profile from Firestore
 */
async function deleteUserProfile(uid, email) {
  if (!DELETE_USER_DATA) return;

  try {
    const userDoc = await db.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      console.log(`   ℹ️  No Firestore profile found for ${email}`);
      return;
    }

    if (DRY_RUN) {
      console.log(`   🔍 [DRY RUN] Would delete Firestore profile`);
      return;
    }

    await db.collection('users').doc(uid).delete();
    console.log(`   ✓ Deleted Firestore user profile`);
  } catch (error) {
    console.error(`   ✗ Error deleting user profile: ${error.message}`);
  }
}

/**
 * Delete a user from Firebase Auth
 */
async function deleteAuthUser(uid, email) {
  try {
    if (DRY_RUN) {
      console.log(`   🔍 [DRY RUN] Would delete Firebase Auth account`);
      return;
    }

    await auth.deleteUser(uid);
    console.log(`   ✓ Deleted Firebase Auth account`);
  } catch (error) {
    console.error(`   ✗ Error deleting Auth account: ${error.message}`);
  }
}

/**
 * Delete all data for a single user
 */
async function deleteUser(email) {
  console.log(`\n📧 Processing: ${email}`);

  try {
    // Get user by email
    const userRecord = await auth.getUserByEmail(email);
    const uid = userRecord.uid;
    
    console.log(`   📝 Found user: ${uid}`);
    console.log(`   📅 Created: ${userRecord.metadata.creationTime}`);
    console.log(`   🔐 Last sign-in: ${userRecord.metadata.lastSignInTime || 'Never'}`);

    // Delete in order: sessions -> profile -> auth account
    await deleteUserTestSessions(uid, email);
    await deleteUserProfile(uid, email);
    await deleteAuthUser(uid, email);

    console.log(`   ✅ Successfully processed ${email}`);
    return { success: true, email, uid };

  } catch (error) {
    if (error.code === 'auth/user-not-found') {
      console.log(`   ⚠️  User not found in Firebase Auth`);
      return { success: false, email, error: 'User not found' };
    }
    console.error(`   ❌ Error processing user: ${error.message}`);
    return { success: false, email, error: error.message };
  }
}

/**
 * Main execution function
 */
async function main() {
  console.log('═══════════════════════════════════════════════════');
  console.log('🗑️  Firebase Test User Deletion Tool');
  console.log('═══════════════════════════════════════════════════');
  console.log(`📁 Project: ${serviceAccount.project_id}`);
  console.log(`⚙️  Mode: ${DRY_RUN ? 'DRY RUN (no changes will be made)' : 'LIVE (will delete data)'}`);
  console.log(`🎯 Users to process: ${TEST_USER_EMAILS.length}`);
  console.log('═══════════════════════════════════════════════════\n');

  if (TEST_USER_EMAILS.length === 0) {
    console.log('⚠️  No test user emails specified!');
    console.log('📝 Please edit the TEST_USER_EMAILS array in this script.');
    process.exit(0);
  }

  if (!DRY_RUN) {
    console.log('⚠️  WARNING: This will permanently delete user data!');
    console.log('⏳ Starting deletion in 5 seconds...');
    console.log('   Press Ctrl+C to cancel\n');
    await new Promise(resolve => setTimeout(resolve, 5000));
  }

  const results = [];
  for (const email of TEST_USER_EMAILS) {
    const result = await deleteUser(email);
    results.push(result);
  }

  // Summary
  console.log('\n═══════════════════════════════════════════════════');
  console.log('📊 Summary');
  console.log('═══════════════════════════════════════════════════');
  
  const successful = results.filter(r => r.success).length;
  const failed = results.filter(r => !r.success).length;

  console.log(`✅ Successful: ${successful}`);
  console.log(`❌ Failed: ${failed}`);

  if (failed > 0) {
    console.log('\n❌ Failed users:');
    results.filter(r => !r.success).forEach(r => {
      console.log(`   - ${r.email}: ${r.error}`);
    });
  }

  if (DRY_RUN) {
    console.log('\n💡 This was a dry run. Set DRY_RUN = false to actually delete users.');
  }

  console.log('\n✨ Done!');
}

// Execute
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error('\n💥 Fatal error:', error);
    process.exit(1);
  });
