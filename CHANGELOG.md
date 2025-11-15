# Changelog - Past Question Paper App

## Version 0.1.5 (In Progress) - 2025-11-15

### UI/UX Improvements

#### 1. Password Visibility & Security Enhancement
**Files Modified:**
- `lib/views/login.dart`
- `lib/views/signup_screen.dart`

**Changes:**
- Added password visibility toggle to login screen
  - Eye icon button to show/hide password
  - State variable `_obscurePassword` to control visibility
- Enhanced signup screen with:
  - Password visibility toggle for both password fields
  - Confirm password field with validation
  - Real-time password strength indicator (Weak/Medium/Strong)
  - Color-coded strength display (Red/Orange/Green)
  - Validation prevents signup with weak passwords

**Password Strength Criteria:**
- **Weak**: < 3 criteria met
- **Medium**: 3-4 criteria met
- **Strong**: 5+ criteria met

Criteria checked:
- Length >= 8 characters
- Length >= 12 characters
- Contains uppercase letters
- Contains lowercase letters
- Contains numbers
- Contains special characters

#### 2. Mobile Navigation Fix
**File Modified:** `lib/views/practice_screen.dart`

**Changes:**
- Fixed next/previous buttons being hidden under phone navigation bars
- Added `MediaQuery.of(context).padding.bottom` to `_buildBottomControls`
- Dynamic padding calculation: `EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0 + bottomPadding)`
- Ensures buttons remain accessible on all devices with system navigation bars

#### 3. Improved Drag-and-Drop UX
**Files Modified:**
- `lib/widgets/question_formats/drag_and_drop_widget.dart`
- `lib/widgets/question_formats/drag_and_drop_ordering_widget.dart`

**Changes:**
- Replaced `Draggable` with `LongPressDraggable` for better mobile experience
- Added haptic feedback on drag start
- 200ms delay before dragging activates (prevents accidental drags)
- Added instructional banners at top of questions:
  - **Drag-and-Drop Matching**: "Drag items from below to the correct drop zones above"
  - **Drag-and-Drop Ordering**: "Arrange steps in the correct order"
  - Tip: "Press and hold an item for a moment before dragging"
- Added visual touch icon indicator on draggable items
- Enhanced visual feedback during drag operation

### Timed Practice Mode Features

#### 4. Timer Implementation
**File Modified:** `lib/views/practice_screen.dart`

**Changes:**
- Added `dart:async` import for Timer functionality
- Implemented countdown timer for Sprint mode
- Timer display in AppBar with MM:SS format
- Color-coded timer warning system:
  - **Blue**: > 5 minutes remaining
  - **Orange**: < 5 minutes remaining
  - **Red**: < 1 minute remaining
- Auto-submit when time expires
- Proper cleanup in dispose to prevent memory leaks

#### 5. Duration-Based Question Scaling
**File Modified:** `functions/src/services/enhancedTestService.js`

**Changes:**
- Fixed Sprint mode to recognize both `'sprint'` and `'quick_practice'` mode parameters
- Corrected baseline calculation:
  - **Before**: Used 180 minutes as baseline
  - **After**: Uses 150 minutes to match actual exam papers (150 marks in 150 minutes)
- Proportional scaling formula: `(duration / 150) × 150 marks`
- Examples:
  - 15 min → 15 marks
  - 30 min → 30 marks
  - 60 min → 60 marks
- Added comprehensive logging for debugging

### Question Review & Results

#### 6. Review Screen Numbering Fix
**Files Modified:**
- `lib/views/practice_screen.dart` (lines 192-193)
- `lib/views/practice_results_screen.dart` (added isPQPMode, isSprintMode parameters)
- `lib/views/question_review_screen.dart` (conditional numbering logic)

**Changes:**
- Added mode flags (`isPQPMode`, `isSprintMode`) throughout navigation chain
- Conditional numbering display:
  - **PQP Mode**: Shows exam paper numbering (e.g., "Question 1.1.1", "1.1.2")
  - **Sprint Mode**: Shows sequential numbering (1, 2, 3...)
  - **By Topic Mode**: Shows sequential numbering (1, 2, 3...)
- Updated `_questionLabel` and `_buildTitle` methods to respect mode flags

#### 7. Removed Explanation Section
**File Modified:** `lib/views/question_review_screen.dart`

**Changes:**
- Removed explanation display section from review screen (lines 354-385)
- Cleaned up conditional rendering logic
- Users can now focus purely on their answers and results without explanation clutter

### Backend Grading Improvements (PENDING DEPLOYMENT)

#### 8. Duration-Based Question Scaling (Cloud Functions)
**File Modified:** `functions/src/services/enhancedTestService.js`

**Changes:**
- Fixed Sprint mode to recognize both `'sprint'` and `'quick_practice'` mode parameters
- Corrected baseline calculation from 180 minutes to 150 minutes (matches actual exam papers)
- Implemented proportional scaling: `(duration / 150) × 150 marks`
- Examples:
  - 5 min → 5 marks (5% of full paper)
  - 15 min → 15 marks (10% of full paper)
  - 30 min → 30 marks (20% of full paper)
  - 60 min → 60 marks (40% of full paper)
- Added comprehensive logging for debugging

**Why This Matters:**
Previously, the duration slider would generate inconsistent numbers of questions. Users selecting different time durations now get appropriately scaled question sets that maintain the same marks-per-minute ratio as full exam papers.

#### 9. Enhanced Answer Comparison Logic
**File Modified:** `functions/src/services/gradingService.js`

**Critical Fixes:**
1. **MCQ Answer Comparison** (Line 15-32)
   - **Before**: Strict equality (`===`) - case and whitespace sensitive
   - **After**: Normalized comparison with `.trim().toUpperCase()`
   - **Impact**: Prevents incorrect marking due to whitespace or case differences
   - Example: `"A"`, `" A "`, and `"a"` all now match correctly

2. **True/False Answer Comparison** (Line 40-57)
   - **Before**: Strict equality
   - **After**: Normalized comparison with `.trim().toLowerCase()`
   - **Impact**: Handles both boolean values and string representations correctly

3. **Drag-and-Drop Ordering** (Line 123-141)
   - **Before**: Strict equality for step IDs
   - **After**: Normalized comparison with `.trim()`
   - **Impact**: Prevents marking errors from trailing spaces in step IDs
   - Example: `"step_1"` and `"step_1 "` now match correctly

4. **Drag-and-Drop Matching** (Line 207-226)
   - **Before**: Strict equality for item IDs
   - **After**: Normalized comparison with `.trim()`
   - **Impact**: Consistent handling of whitespace in drag items

**Why This Matters:**
These changes address the core issue where correct answers were being marked as incorrect due to:
- Whitespace differences (leading/trailing spaces)
- Case sensitivity in MCQ options
- String vs boolean type mismatches in True/False questions
- Data formatting inconsistencies from the frontend

### Mode Flag Propagation

**Navigation Chain:**
```
TestConfigurationScreen (sets flags)
    ↓
PracticeScreen (receives & passes flags)
    ↓
PracticeResultsScreen (receives & passes flags)
    ↓
QuestionReviewScreen (uses flags for display)
```

**Mode Identification:**
- `isPQPMode = true`: Full exam mode with authentic numbering
- `isSprintMode = true`: Quick practice with sequential numbering
- Both `false`: By Topic mode with sequential numbering

### Known Issues & Limitations

1. **Cloud Functions Not Deployed**: Grading improvements in `gradingService.js` need deployment
2. **Short Answer Multi-Value**: Numerical extraction only gets first number from text
3. **Firebase Compatibility**: `runWith()` syntax needs updating for firebase-functions v6.x

## Pending Deployment

### Cloud Functions (CRITICAL - 2 Files)
**Files Modified:**
1. `functions/src/services/gradingService.js` - Enhanced grading logic
2. `functions/src/services/enhancedTestService.js` - Duration-based scaling fix

**Deployment Command:**
```bash
cd functions
firebase deploy --only functions
```

**What Will Be Deployed:**

**1. Enhanced Grading Logic (gradingService.js):**
- MCQ: Case-insensitive, whitespace-trimmed comparison
- True/False: Handles both strings and booleans
- Drag-and-Drop: Normalized whitespace handling for step IDs
- More reliable answer matching across all question types

**2. Duration-Based Scaling (enhancedTestService.js):**
- Sprint mode now uses correct 150-minute baseline
- Proportional question generation based on selected duration
- Recognizes both 'sprint' and 'quick_practice' mode parameters
- Consistent marks-per-minute ratio across all durations

**Expected Impact:**
- **Grading**: Reduce false negatives where correct answers are marked wrong
- **Scaling**: Appropriate number of questions for selected time duration
- **User Experience**: Improved satisfaction and grading accuracy
- **Data Handling**: Gracefully handle common input variations

## Testing Recommendations

### Before Deployment
1. Test MCQ questions with:
   - Lowercase answers (a, b, c, d)
   - Answers with trailing spaces
   - Mixed case answers
2. Test drag-and-drop with:
   - Items that have trailing whitespace
   - Different ordering sequences
3. Test True/False with:
   - String values ("true", "false")
   - Boolean values (true, false)
   - Mixed case ("True", "FALSE")

### After Deployment
1. Verify grading accuracy across all question types
2. Check that previously failed tests now pass
3. Monitor Cloud Functions logs for errors
4. Test edge cases with special characters

## Migration Notes

### For Developers
- All password fields now use visibility toggles - ensure new auth screens follow this pattern
- Mode flags must be passed through entire navigation chain for correct display
- Use `LongPressDraggable` for all future drag-and-drop implementations
- Always normalize answers before comparison in grading logic

### For Database Administrators
- No schema changes required
- Existing questions work with new grading logic
- No data migration needed

## Version History

- **v0.1.4+6**: Bug fixes and UI improvements
- **v0.1.5** (Current): Enhanced UX, grading fixes, timer implementation
