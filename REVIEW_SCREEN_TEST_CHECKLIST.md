# Review Screen Test Checklist

## Overview
This checklist verifies that the Question Review Screen works correctly across all three practice modes (PQP, Sprint, By Topic) and all question formats.

## Recent Changes (November 5, 2025)

### 1. Question Model Enhancement
**File**: `lib/model/question.dart`
- ✅ Added `pqpData`, `sprintData`, and `parentContext` to `toMap()` method
- **Impact**: Review screen now receives mode-specific data and parent context for all modes

### 2. Review Screen Improvements
**File**: `lib/views/question_review_screen.dart`
- ✅ Format normalization for drag-drop variants
- ✅ MCQ answer rendering using option text (A, B, C, D) instead of indices
- ✅ Parent context display for child questions
- ✅ Quick jump navigator with color-coded chips
- ✅ PQP numbering in title and chips
- ✅ Drag-and-drop ordering: Added "Your Order" and "Correct Order" summary boxes
- ✅ Robust extraction fallbacks for `correctOrder` and `userOrder`

---

## Test Matrix

### Mode 1: PQP (Past Question Paper)
**Expected Behavior**:
- ✅ Title shows PQP question number: "Question 4.2.1 • 5/10"
- ✅ Quick jump chips show PQP numbers: "4.1", "4.2.1", "4.2.2"
- ✅ Parent context displayed for sub-questions
- ✅ Parent image shown if child question uses parent's image

**Test Cases**:
1. MCQ with PQP numbering
2. Drag-drop ordering with PQP numbering
3. Short answer with parent context
4. Child question using parent's image

### Mode 2: Sprint (Quick Practice)
**Expected Behavior**:
- ✅ Title shows sequential numbering: "Question 1 of 10"
- ✅ Quick jump chips show numbers: "1", "2", "3"
- ✅ Sprint-specific hints/context displayed (if present)
- ✅ No PQP numbering

**Test Cases**:
1. MCQ with sprint hints
2. Drag-drop with randomized items
3. True/False questions
4. Mixed formats in one test

### Mode 3: By Topic
**Expected Behavior**:
- ✅ Title shows sequential numbering: "Question 1 of 10"
- ✅ Quick jump chips show numbers: "1", "2", "3"
- ✅ Questions filtered by selected topic
- ✅ Parent context displayed where applicable

**Test Cases**:
1. Topic-specific MCQs
2. Drag-drop questions from single topic
3. Mixed formats within topic

---

## Question Format Tests

### 1. Multiple Choice (MCQ)
**What to verify**:
- ✅ Options displayed as "A) Option 1", "B) Option 2"
- ✅ User answer shows option text, not index
- ✅ Correct answer shows option text
- ✅ Image options rendered correctly

**Test**:
- Answer an MCQ incorrectly
- Check review shows: "Your Answer: B) Wrong option" and "Correct Answer: C) Right option"

### 2. Drag-and-Drop Ordering
**What to verify**:
- ✅ "Your Order" box shows: "step_2, step_4, step_1, step_3"
- ✅ "Correct Order" box shows: "step_1, step_2, step_3, step_4"
- ✅ Step-by-step breakdown with correctness indicators
- ✅ Marks per step displayed

**Test**:
- Answer a drag-drop ordering question with some steps wrong
- Check both summary boxes are populated
- Verify detailed step results show which positions are correct/incorrect

### 3. Drag-and-Drop Matching
**What to verify**:
- ✅ Target-to-item mappings shown
- ✅ Each pair marked correct/incorrect
- ✅ Detailed results for each target

**Test**:
- Match items incorrectly
- Verify each target shows "Your: X" and "Correct: Y"

### 4. True/False
**What to verify**:
- ✅ Answer displayed as "True" or "False" (capitalized)
- ✅ Not shown as "true"/"false" or "TRUE"/"FALSE"

**Test**:
- Answer True/False question
- Check capitalization is correct

### 5. Short Answer
**What to verify**:
- ✅ User's text answer displayed verbatim
- ✅ Correct answer shown
- ✅ Grading explanation (if manual review required)

**Test**:
- Submit a short answer
- Verify text displays correctly (no truncation or encoding issues)

---

## Parent Context Tests

### Child Questions
**What to verify**:
- ✅ Parent context box appears above child question
- ✅ Parent text displayed with "Context:" label
- ✅ Parent image shown if child doesn't have its own image
- ✅ Fallback to parent image works (`imageUrl ?? parentContext['imageUrl']`)

**Test Scenarios**:
1. **Child with own image**: Should show child's image, parent text in context box
2. **Child without image**: Should show parent's image from context
3. **No parent context**: Context box hidden, only child question shown

---

## Navigation Tests

### Quick Jump Navigator
**What to verify**:
- ✅ Horizontal scrollable chips
- ✅ Color coding:
  - Green = Correct
  - Red = Incorrect
  - Gray = Unanswered
- ✅ Orange border on currently viewed question
- ✅ Clicking chip jumps to that question
- ✅ PQP numbers displayed in PQP mode
- ✅ Sequential numbers in Sprint/By Topic modes

**Test**:
- Complete a test with mix of correct/incorrect/unanswered
- Open review
- Click various chips to jump around
- Verify current question highlighted

### Page Navigation
**What to verify**:
- ✅ "Previous" button disabled on first question
- ✅ "Next" button disabled on last question
- ✅ Swipe left/right works
- ✅ Page indicator updates in title

**Test**:
- Navigate through all questions using buttons
- Try swiping
- Verify boundary conditions (first/last question)

---

## Data Flow Verification

### Question Data Structure
**Verify these fields are passed correctly**:
```dart
{
  'id': 'question_id',
  'questionText': 'What is 2+2?',
  'options': ['3', '4', '5', '6'],
  'correctAnswer': '1', // or 'B'
  'format': 'mcq', // or 'drag_drop_ordering', 'short_answer', etc.
  'pqpData': {
    'questionNumber': '4.2.1',
    'marks': 3,
    ...
  },
  'parentContext': {
    'questionText': 'Parent question text',
    'imageUrl': 'https://...'
  },
  ...
}
```

### Grading Result Structure
**Verify these fields for drag-drop ordering**:
```dart
{
  'questionId': 'drag_drop_001',
  'format': 'dragAndDrop',
  'subFormat': 'ordering',
  'correctOrder': ['step_1', 'step_2', 'step_3', 'step_4'],
  'userAnswers': ['step_2', 'step_4', 'step_1', 'step_3'],
  'detailedResults': [
    {
      'stepPosition': 1,
      'userAnswer': 'step_2',
      'correctAnswer': 'step_1',
      'isCorrect': false,
      ...
    },
    ...
  ],
  'isCorrect': false,
  'marksAwarded': 1.5,
  'maxMarks': 3
}
```

---

## Edge Cases to Test

### 1. Unanswered Questions
- ✅ Shows "No answer" in user answer box
- ✅ Marks awarded: 0
- ✅ Gray chip in quick navigator

### 2. Empty correctOrder Array
- ✅ Falls back to extracting from `detailedResults`
- ✅ Shows "N/A" if no data available

### 3. String vs Array userAnswers
- ✅ Handles comma-separated string: "step_1,step_2,step_3"
- ✅ Handles array format: ["step_1", "step_2", "step_3"]

### 4. Missing parentContext
- ✅ Context box hidden
- ✅ No errors thrown
- ✅ Question displays normally

### 5. Mixed Format Test
- ✅ MCQ, drag-drop, short answer in same review
- ✅ Each renders with appropriate widget
- ✅ Navigation works across different formats

---

## Performance Tests

### Large Question Sets
- Test with 50+ questions
- Verify quick navigator scrolls smoothly
- Check page transitions are smooth
- No memory leaks on repeated navigation

### Image Loading
- Questions with images load properly
- Parent images fallback works
- Error placeholder shows for broken images

---

## Accessibility Tests

### Screen Reader Support
- Labels are descriptive
- Navigation order is logical
- Action buttons have proper semantics

### Color Contrast
- Correct (green) and incorrect (red) have sufficient contrast
- Text readable on all background colors
- Orange accent meets WCAG AA standards

---

## Regression Tests

### Before Deploying
1. Run all three modes (PQP, Sprint, By Topic)
2. Test each question format
3. Verify parent context displays
4. Check drag-drop ordering shows correct answer
5. Confirm PQP numbering works
6. Test quick navigation
7. Check boundary conditions (first/last question)

### Known Issues (Historical)
- ❌ ~~Correct answer blank for drag-drop ordering~~ → **FIXED** (Nov 5, 2025)
- ❌ ~~PQP numbering not showing~~ → **FIXED** (Nov 5, 2025)
- ❌ ~~Parent context missing~~ → **FIXED** (Nov 5, 2025)

---

## Sign-off

### Developer
- [ ] All code changes reviewed
- [ ] No compiler errors
- [ ] No analyzer warnings
- [ ] Manual testing completed

### QA
- [ ] PQP mode tested
- [ ] Sprint mode tested
- [ ] By Topic mode tested
- [ ] All question formats verified
- [ ] Parent context working
- [ ] Drag-drop ordering correct answer shows

### Product Owner
- [ ] UX meets requirements
- [ ] All modes functional
- [ ] Ready for production

---

## Quick Reference: Files Modified

1. **lib/model/question.dart** - Added pqpData, sprintData, parentContext to toMap()
2. **lib/views/question_review_screen.dart** - Complete refactor with all improvements

## To Run Tests

```bash
# Run the app
flutter run

# Test PQP mode
1. Go to "Full Exam (PQP)" tab
2. Select subject, year, season
3. Complete test
4. Open review

# Test Sprint mode
1. Go to "Quick Practice" tab
2. Select subject
3. Complete test
4. Open review

# Test By Topic mode
1. Go to "By Topic" tab
2. Select subject and topic
3. Complete test
4. Open review
```

---

**Last Updated**: November 5, 2025
**Status**: ✅ All improvements implemented and ready for testing
