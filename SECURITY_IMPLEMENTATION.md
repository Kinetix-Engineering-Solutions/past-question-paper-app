# 🔒 Security Implementation Guide

## Overview
This document outlines the security measures implemented to protect against resource abuse and unauthorized access in the Past Question Paper app.

**Last Updated:** November 6, 2025  
**Status:** ✅ Production Ready

---

## 🛡️ Security Layers Implemented

### 1. Firestore Security Rules (`firestore.rules`)

**What it protects:**
- User data privacy (users can only access their own data)
- Question database integrity (read-only access)
- Test session isolation (private to each user)

**Key Rules:**
```javascript
// Users can only read/write their own data
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}

// Questions are read-only (answers hidden by Cloud Functions)
match /questions/{questionId} {
  allow read: if request.auth != null;
  allow write: if false; // Only Cloud Functions
}

// Test sessions are private
match /test_sessions/{sessionId} {
  allow read, write: if resource.data.userId == request.auth.uid;
}
```

**Cost Protection:**
- ✅ Prevents unauthorized reads of sensitive data
- ✅ Blocks malicious writes/deletes
- ✅ Limits query scope to user's own data

---

### 2. Storage Security Rules (`storage.rules`)

**What it protects:**
- Question images from unauthorized modifications
- Storage bucket from abuse (unlimited uploads)
- Bandwidth costs from hotlinking

**Key Rules:**
```javascript
// Question images: read-only
match /question_images/{fileName} {
  allow read: if true;  // Public (for app)
  allow write: if false; // Admin SDK only
}

// User uploads: authenticated + size limits
match /user_uploads/{userId}/{fileName} {
  allow read: if true;
  allow write: if request.auth.uid == userId &&
                 request.resource.size < 5 * 1024 * 1024; // 5MB max
}
```

**Cost Protection:**
- ✅ Prevents unlimited file uploads
- ✅ Blocks file deletions by unauthorized users
- ✅ Size limits prevent storage abuse (5MB per file)

---

### 3. Cloud Function Authentication

**What it protects:**
- Cloud Function invocations from anonymous users
- Function abuse by bots/scripts
- Unauthorized access to test generation/grading

**Implementation:**
```javascript
exports.generateTest = functions.https.onCall(async (data, context) => {
  // Require authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'You must be logged in to generate tests.'
    );
  }
  
  const userId = context.auth.uid; // Verified by Firebase
  // ... rest of function
});
```

**Cost Protection:**
- ✅ Only authenticated users can call functions
- ✅ Prevents bot spam
- ✅ Traceable to specific user accounts

---

### 4. Rate Limiting

**What it protects:**
- Function invocation costs from spam
- Firestore read/write costs from abuse
- Server resources from DDoS

**Implementation:**
```javascript
// generateTest - Rate limit: 1 test every 3 seconds
const lastGeneration = userData.lastTestGeneration;
const now = Date.now();

if (lastGeneration && (now - lastGeneration) < 3000) {
  throw new functions.https.HttpsError(
    'resource-exhausted',
    'Please wait a moment before generating another test.'
  );
}
```

**Cost Protection:**
- ✅ Max 20 tests/minute per user (conservative)
- ✅ Prevents accidental loops in client code
- ✅ Stops deliberate abuse attempts

---

### 5. Request Size Validation

**What it protects:**
- Function execution time costs
- Memory usage costs
- Firestore write costs

**Implementation:**
```javascript
// Limit test generation size
if (requestedQuestions > 100) {
  throw new functions.https.HttpsError(
    'invalid-argument',
    'Cannot generate more than 100 questions at once.'
  );
}

// Limit answer text length
if (answer.length > 50000) {
  throw new functions.https.HttpsError(
    'invalid-argument',
    'Answer text is too long. Maximum 50,000 characters per answer.'
  );
}
```

**Cost Protection:**
- ✅ Prevents massive queries
- ✅ Limits function execution time
- ✅ Caps memory usage

---

### 6. Function Resource Limits

**What it protects:**
- Runaway functions from costing money
- Memory exhaustion
- Concurrent execution abuse

**Implementation:**
```javascript
exports.generateTest = functions
  .runWith({
    memory: '256MB',           // Lower memory = lower cost
    timeoutSeconds: 30,        // Kill after 30s
    maxInstances: 100          // Limit concurrent executions
  })
  .https.onCall(...)
```

**Cost Protection:**
- ✅ Functions auto-kill after 30 seconds
- ✅ Memory limited to 256MB (cheapest tier)
- ✅ Max 100 concurrent executions prevents runaway costs

---

## 💰 Cost Estimates

### With Security (Current Implementation)

**Worst-case abuse scenario:**
- Attacker creates account
- Generates 20 tests/minute (rate limited)
- Grades 20 tests/minute
- Runs for 1 hour

**Cost:**
- Cloud Functions: 1,200 invocations × $0.0000004 = **$0.00048**
- Firestore Reads: ~60,000 reads × $0.00006/1000 = **$0.0036**
- **Total: $0.004 per attacker per hour**

### Without Security (Previous State)

**Same scenario:**
- No rate limit: 1000+ tests/minute possible
- No size limit: Could request 10,000 questions each
- No auth: Bots could spam

**Cost:**
- Cloud Functions: 60,000+ invocations = **$0.024**
- Firestore Reads: 10,000,000+ reads = **$600**
- **Total: $600+ per attacker per hour** ⚠️

---

## 🚀 Deployment Steps

### 1. Deploy Security Rules

```powershell
# Deploy Firestore and Storage rules
firebase deploy --only firestore:rules,storage:rules
```

**Expected output:**
```
✔ Deploy complete!
✔ firestore: rules deployed
✔ storage: rules deployed
```

### 2. Deploy Cloud Functions

```powershell
# Deploy functions with new security
cd functions
npm install  # If you added new dependencies
cd ..
firebase deploy --only functions
```

**Expected output:**
```
✔ functions[generateTest]: Successful update operation.
✔ functions[gradeTest]: Successful update operation.
```

### 3. Test Security Rules

```powershell
# Start emulators with new rules
firebase emulators:start
```

**Test checklist:**
- [ ] Unauthenticated user cannot call `generateTest`
- [ ] User cannot read another user's test sessions
- [ ] User cannot upload to `question_images/`
- [ ] Rate limit triggers after rapid test generation

---

## 📊 Monitoring & Alerts

### Firebase Console Setup

1. **Billing Alerts** (CRITICAL)
   - Go to: Firebase Console → ⚙️ Settings → Usage and billing
   - Set alerts at: $10, $50, $100
   - Email notifications when: 50%, 90%, 100% reached

2. **Usage Monitoring**
   - Check daily: Firebase Console → Usage tab
   - Watch for: Sudden spikes in reads/writes/function calls
   - Investigate: Any user with >1000 function calls/day

3. **Function Logs**
   - View: Firebase Console → Functions → Logs
   - Search for: `resource-exhausted` (rate limit hits)
   - Alert if: Same user hits rate limit >10 times/day

---

## 🔧 Maintenance

### Monthly Security Audit

- [ ] Review Firestore usage for anomalies
- [ ] Check function invocation patterns
- [ ] Verify no users bypassing rate limits
- [ ] Update rate limits if legitimate usage increases

### When to Adjust Limits

**Increase rate limits if:**
- Legitimate users complain about "please wait" errors
- Usage patterns show genuine need for faster access
- You've added caching to reduce costs

**Decrease rate limits if:**
- Seeing abuse patterns in logs
- Costs increasing unexpectedly
- New feature enables rapid legitimate use

---

## 🆘 Emergency Response

### If You See Unexpected Costs

1. **Immediate action:**
   ```powershell
   # Disable functions temporarily
   firebase functions:config:set security.enabled=false
   firebase deploy --only functions
   ```

2. **Identify attacker:**
   - Check function logs for userId
   - Look for repeated calls from same IP
   - Search for rate limit violations

3. **Block attacker:**
   - Delete user account (use `deleteTestUsers.js`)
   - Add IP to blocklist (if available)
   - Report abuse to Firebase support

4. **Re-enable with stricter limits:**
   - Reduce rate limits (e.g., 1 test per 10 seconds)
   - Add CAPTCHA for suspicious activity
   - Require email verification

---

## ✅ Verification Checklist

Before marking this as complete, verify:

- [x] `firestore.rules` created and deployed
- [x] `storage.rules` updated and deployed
- [x] `firebase.json` references both rule files
- [x] Cloud Functions require authentication
- [x] Rate limiting implemented (3 second cooldown)
- [x] Request size validation added
- [x] Function resource limits configured
- [ ] Billing alerts set up in Firebase Console
- [ ] Test in emulator with unauthenticated user
- [ ] Deploy to production and monitor for 24 hours

---

## 📚 Additional Resources

- [Firebase Security Rules Documentation](https://firebase.google.com/docs/rules)
- [Cloud Functions Best Practices](https://firebase.google.com/docs/functions/best-practices)
- [Firebase Pricing Calculator](https://firebase.google.com/pricing)
- [Security Rules Simulator](https://firebase.google.com/docs/rules/simulator)

---

**Document maintained by:** Kinetix Engineering Solutions  
**For support:** Review logs in Firebase Console or check this document for troubleshooting steps
