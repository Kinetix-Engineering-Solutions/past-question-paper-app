# 🚀 Staging to Production (Master) Checklist

**Purpose:** Clean up development code before merging `develop` → `staging` → `master` for Play Store release.

**Created:** October 18, 2025  
**Target:** v0.1.3+4 Production Release

---

## 📋 Pre-Merge Checklist

### 1. ✅ Version & Configuration
- [x] Version updated to `0.1.3+4` (higher than Play Store)
- [x] Application ID changed to `com.kinetix.past_question_paper`
- [x] Upload keystore configured
- [x] Firebase project configured (vibe-code-4c59f)
- [ ] Remove `.env` file from staging (if exists)
- [ ] Verify `.gitignore` includes sensitive files

### 2. 🧹 Code Cleanup Tasks

#### A. Remove Debug Print Statements
**Found 50+ print/debugPrint statements** - Decision needed:

**Option 1: Remove ALL (Recommended for Production)**
- Cleaner logs
- Smaller app size
- Better performance
- Professional appearance

**Option 2: Convert to Conditional Debugging**
```dart
// Instead of: print('Debug message');
// Use:
if (kDebugMode) {
  debugPrint('Debug message');
}
```

**Option 3: Keep Critical Error Logging**
- Remove debugging prints (🔍, ✅, 🚀 emojis)
- Keep error handling prints
- Convert important logs to proper error reporting

**Files with Heavy Debug Output:**
- `lib/viewmodels/practice_viewmodel.dart` (30+ prints)
- `lib/viewmodels/session_history_viewmodel.dart` (10+ prints)
- `lib/repositories/question_repository.dart` (3 debug prints)
- `lib/widgets/firebase_image.dart` (4 error prints)
- `lib/utils/clear_user_subjects.dart` (6 status prints)

#### B. Remove Temporary Code
**Files to Review:**

1. **`lib/widgets/question_formats/drag_and_drop_widget.dart` (Line 70)**
   ```dart
   // TEMPORARY: Skip validation check for debugging
   ```
   ⚠️ **CRITICAL:** Remove this temporary validation bypass!

2. **`lib/repositories/question_repository.dart`**
   - Commented debug prints (lines 49, 56)
   - Active debug prints (lines 61, 74, 75)

#### C. Remove Development Utilities
**Files to DELETE before production:**
- ❌ `lib/utils/clear_user_subjects.dart` - Development testing utility
- ⚠️ Consider: `lib/firebase_options_template.dart` (keep for team reference)

#### D. Clean Comments
**Already Clean:** Most code has proper documentation comments.  
**Action:** Quick scan for "TODO", "FIXME", "HACK" - None found ✅

### 3. 🔒 Security Review
- [ ] No API keys or secrets in code (check!)
- [ ] `key.properties` in `.gitignore` ✅
- [ ] `upload-keystore.jks` in `.gitignore` ✅
- [ ] `serviceAccountKey.json` in `.gitignore` ✅
- [ ] No hardcoded credentials in Cloud Functions

### 4. 🧪 Testing Before Merge
- [ ] Run all tests: `flutter test`
- [ ] Build debug APK successfully: `flutter build apk --debug`
- [ ] Build release AAB successfully: `flutter build appbundle --release`
- [ ] Test release AAB on physical device
- [ ] Verify app works without debug statements
- [ ] Check app size (should be 20-80MB)

### 5. 📝 Documentation
- [x] README.md updated
- [x] AI instructions (`.github/copilot-instructions.md`) updated
- [x] Unnecessary MD files deleted
- [ ] CHANGELOG.md created (optional but recommended)
- [ ] Add release notes for Play Store

### 6. 🔀 Git Workflow
```bash
# 1. Create staging branch from develop
git checkout develop
git pull origin develop
git checkout -b staging

# 2. Apply cleanup changes (following this checklist)
# ... make changes ...

# 3. Commit cleanup
git add .
git commit -m "chore: Production cleanup for v0.1.3+4

- Remove debug print statements
- Remove temporary validation bypass in drag_and_drop_widget
- Delete development utilities (clear_user_subjects)
- Clean up debug comments in repositories
- Verify security (no secrets committed)"

# 4. Test thoroughly
flutter test
flutter build appbundle --release

# 5. Merge staging to master
git checkout master
git merge staging --no-ff -m "Release v0.1.3+4 - MVP Mathematics Grade 12"

# 6. Tag the release
git tag -a v0.1.3+4 -m "Production release: Mathematics Grade 12 MVP"

# 7. Push everything
git push origin master
git push origin staging
git push origin develop
git push origin --tags
```

---

## 🎯 Recommended Cleanup Strategy

### **Minimal Cleanup (1-2 hours)**
✅ Best for urgent release

1. Remove TEMPORARY validation bypass (drag_and_drop_widget.dart line 70)
2. Delete `lib/utils/clear_user_subjects.dart`
3. Convert main error prints to proper error handling
4. Test and ship

### **Standard Cleanup (2-4 hours)**
✅ **Recommended for professional release**

1. All Minimal tasks above
2. Remove all debug print statements with emojis (🔍, ✅, 🚀, etc.)
3. Keep only critical error logging with proper formatting
4. Clean up commented debug code
5. Run full test suite
6. Test release build thoroughly

### **Thorough Cleanup (4-8 hours)**
⚠️ Only if time permits

1. All Standard tasks above
2. Add proper logging framework (e.g., `logger` package)
3. Replace all prints with structured logging
4. Add Firebase Crashlytics for production error tracking
5. Performance profiling
6. Code quality review with `flutter analyze --strict`

---

## 📊 Impact Analysis

### Print Statement Removal
**Pros:**
- ✅ Cleaner production logs
- ✅ Slightly better performance
- ✅ Smaller app size (~100KB saved)
- ✅ Professional appearance

**Cons:**
- ❌ Harder to debug production issues (mitigate with proper error reporting)
- ❌ Need structured logging for future debugging

### Recommendation
**Remove debug prints, keep error handling:**
```dart
// ❌ Remove these:
print('🔍 Fetching parent context...');
print('✅ Cached parent question...');

// ✅ Keep these (but improve formatting):
try {
  // ... code ...
} catch (e) {
  debugPrint('Error loading Firebase image: $e');
  // Consider adding Firebase Crashlytics reporting here
}
```

---

## 🚨 Critical Items (Must Fix Before Production)

1. **TEMPORARY validation bypass** in `drag_and_drop_widget.dart` - **MUST REMOVE**
2. **Development utility** `clear_user_subjects.dart` - **MUST DELETE**
3. **Excessive debug logging** in `practice_viewmodel.dart` - **SHOULD CLEAN**
4. **Test release build** - **MUST PASS**

---

## 📞 Decision Points

**Team needs to decide:**

1. **Debug Print Strategy:**
   - [ ] Option A: Remove all (cleanest)
   - [ ] Option B: Keep error logs only (balanced)
   - [ ] Option C: Wrap in kDebugMode (safe but verbose)

2. **Testing Scope:**
   - [ ] Quick smoke test (30 min)
   - [ ] Full regression test (2-3 hours)
   - [ ] Beta testing with small group (1-2 days)

3. **Timeline:**
   - [ ] Ship today (minimal cleanup)
   - [ ] Ship tomorrow (standard cleanup)
   - [ ] Ship next week (thorough cleanup + testing)

---

## ✅ Sign-Off Checklist

Before merging to master:

- [ ] All critical items fixed
- [ ] Tests passing
- [ ] Release build successful
- [ ] App tested on physical device
- [ ] Team review completed
- [ ] Release notes written
- [ ] Git tags prepared

**Approved by:** _______________  
**Date:** _______________

---

## 📚 Reference Files

- Build guide: `README.md`
- AI instructions: `.github/copilot-instructions.md`
- Functions docs: `functions/README.md`
- Git workflow: `scripts/git-workflow.bat`

---

**Last Updated:** October 18, 2025  
**Next Review:** Before next production release
