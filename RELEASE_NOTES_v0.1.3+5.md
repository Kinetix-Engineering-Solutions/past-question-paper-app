# Release Notes - Version 0.1.3 (Build 5)

**Release Date:** November 5, 2025  
**Platform:** Android  
**Build Type:** Production Release

---

## 🎨 UI/UX Improvements

### Authentication Screens (Login & Sign Up)
- **Complete redesign** with modern, clean light theme
- Replaced gradients with solid backgrounds for better performance and accessibility
- Updated to use **Poppins font** for headings (more friendly and approachable)
- Added **splash logo** instead of generic icons for better branding
- Improved navigation with `pushReplacement` to prevent stack buildup
- Enhanced form validation - errors only show after user interaction
- Added keyboard dismissal when tapping outside form fields
- Optimized color scheme:
  - Light paper background for better readability
  - Orange accent (`#FF7A1A`) for CTAs and focus states
  - High contrast text for accessibility
  - Cleaner input fields with subtle borders

### Onboarding Experience
- **Added availability indicators** for grades and subjects
- Grade 12 is unlocked; Grades 10-11 show "Coming Soon" badges
- Mathematics is unlocked; other subjects show "Coming Soon" badges
- Lock icons clearly indicate unavailable content
- Disabled interaction for locked items with visual feedback

---

## 🔧 Bug Fixes

### Sprint Mode - Drag & Drop Questions
- Fixed drag-and-drop ordering questions not displaying correct answers in review screen
- Fixed format detection in grading service (dragdrop vs multipleChoice)
- Enhanced question data preservation in Cloud Functions
- Implemented comprehensive LaTeX rendering throughout review screen
- Fixed question data flow to preserve dragItems for meaningful step content display

### Grading System
- Fixed unanswered questions not being included in total marks calculation
- Corrected marks calculation to use proper question.marks field
- Improved empty string vs null handling for unanswered questions
- Enhanced grading accuracy across all question types

---

## 🎯 Technical Improvements

### Typography
- Switched from Montserrat to **Poppins** for all headings
- Maintained Inter for body text (excellent readability)
- Reduced heading font sizes (28px → 24px) for better balance
- Font scale optimized at 94% for tighter, denser UI

### Code Quality
- Improved state management in authentication flows
- Enhanced navigation service usage
- Better error handling with user-friendly messages
- Cleaner code organization and naming conventions

---

## 📝 Current Feature Set

### Available Content
✅ **Grade 12 Mathematics** - Full access  
✅ **Three Practice Modes:**
- PQP Mode (Past Question Paper) - Exam-authentic with actual numbering
- Sprint Mode (Quick Practice) - Mixed questions with hints
- By Topic Mode - Filtered practice by specific topics

✅ **Question Types:**
- Multiple Choice (Text & Image options)
- Drag & Drop Ordering
- Short Answer
- Essay Questions
- True/False

✅ **Features:**
- Comprehensive review screen with explanations
- LaTeX rendering for mathematical expressions
- Progress tracking
- Score calculation and breakdown
- User authentication and profiles

### Coming Soon
🔒 Grades 10 & 11  
🔒 Physics, Chemistry, Biology, and other STEM subjects

---

## 🔒 Security & Performance

- Firebase App Check enabled for API protection
- Secure authentication with email/password
- Cloud Functions for server-side grading
- Optimized asset loading and tree-shaking
- Reduced APK size with efficient resource management

---

## 📱 Build Information

- **Version Name:** 0.1.3
- **Version Code:** 5
- **APK Size:** ~58 MB
- **Target SDK:** Android 34
- **Minimum SDK:** Android 23 (Android 6.0)

---

## 🐛 Known Issues

- One unit test failing in `pqp_mode_test.dart` (non-critical)
- Java 8 deprecation warnings from Gradle (does not affect functionality)

---

## 🚀 Deployment Notes

This build is signed with production keystore and ready for Play Store distribution.

---

## 📧 Support

For issues or feedback, contact: support@kinetix.co.za

---

**Built with ❤️ by Kinetix Engineering Solutions**
