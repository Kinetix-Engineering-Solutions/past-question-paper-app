# Test User Deletion Guide

## Overview
This guide explains how to delete test user accounts from both Firebase Auth and Firestore.

## What Gets Deleted
The script deletes:
1. ✅ Firebase Authentication account
2. ✅ User profile in Firestore (`users` collection)
3. ✅ Test sessions (`test_sessions` collection)
4. ✅ Any associated user data

## Usage

### Step 1: Add Test User Emails
Edit `functions/tools/deleteTestUsers.js` and add your test user emails:

```javascript
const TEST_USER_EMAILS = [
  'test1@example.com',
  'test2@example.com',
  'your-test-account@gmail.com',
  // Add more emails here
];
```

### Step 2: Dry Run (Recommended First)
Run a dry run to see what would be deleted WITHOUT actually deleting:

```powershell
cd functions
node tools/deleteTestUsers.js
```

The script defaults to `DRY_RUN = false`, but you can change it to `true` temporarily.

### Step 3: Delete Users
Once you've verified the dry run, run the actual deletion:

```powershell
cd functions
node tools/deleteTestUsers.js
```

You'll see output like:
```
📧 Processing: test@example.com
   📝 Found user: abc123xyz
   📅 Created: Mon, 01 Jan 2024
   🔐 Last sign-in: Mon, 01 Jan 2024
   ✓ Deleted 5 test session(s)
   ✓ Deleted Firestore user profile
   ✓ Deleted Firebase Auth account
   ✅ Successfully processed test@example.com
```

## Configuration Options

In `deleteTestUsers.js`, you can customize:

```javascript
const DRY_RUN = false;              // Set true to preview without deleting
const DELETE_TEST_SESSIONS = true;   // Delete test sessions
const DELETE_USER_DATA = true;       // Delete user profile
```

## Alternative: Firebase Console

For a few users, you can also use the Firebase Console:

1. Go to https://console.firebase.google.com/
2. Select project: **vibe-code-4c59f**
3. Navigate to **Authentication** → **Users**
4. Find test users and click **⋮** → **Delete account**
5. Then manually delete Firestore data:
   - Go to **Firestore Database**
   - Navigate to `users` collection
   - Find and delete user documents
   - Navigate to `test_sessions` collection
   - Delete associated sessions

## Safety Features

- ⏳ 5-second countdown before deletion
- 📊 Detailed summary of successful/failed deletions
- 🔍 Dry run mode to preview changes
- ⚠️ Clear warnings before irreversible actions

## Troubleshooting

### "User not found in Firebase Auth"
- User email is incorrect, or user was already deleted
- Check the email spelling

### "Permission denied"
- Ensure `serviceAccountKey.json` is valid and has admin permissions
- Check that you're in the correct Firebase project

### "No test sessions found"
- This is normal if the user never took any tests
- The script will still delete the Auth account and profile

## Warning

⚠️ **THIS ACTION IS IRREVERSIBLE!**

Once deleted:
- Users cannot log in with these accounts
- All test history is permanently lost
- User profiles are permanently removed
- There is NO undo option

Always run a dry run first to verify you're deleting the correct users.
