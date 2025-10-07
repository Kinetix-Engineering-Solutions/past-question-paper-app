# Question Browser/List View - Feature Documentation

## 🎯 Overview
The Question Browser is a comprehensive data table interface for viewing, searching, filtering, and managing all questions in the database. It provides quick access to question details, editing, and deletion capabilities.

---

## ✨ Features Implemented

### 1. **Question List Table** 📊
- Paginated data table (50 items per page)
- Columns:
  - **ID** - First 8 characters of document ID
  - **Question** - Truncated question text (100 chars)
  - **Subject** - Mathematics, Physical Sciences, Life Sciences
  - **Grade** - 10, 11, 12
  - **Topic** - Topic name
  - **Format** - Color-coded badge (MCQ, Short Answer, etc.)
  - **Marks** - Question marks
  - **PQP #** - PQP question number (e.g., 4.1.1)
  - **Actions** - Preview, Edit, Delete buttons

### 2. **Filter Sidebar** 🔍
- **Subject Filter** - Filter by subject
- **Grade Filter** - Filter by grade
- **Format Filter** - Filter by question type
- **Topic Filter** - Shows only when subject is selected
- **Clear All** - Reset all filters at once
- Filters persist during pagination

### 3. **Search Bar** 🔎
- Real-time search as you type
- Searches in:
  - Question text
  - Topic name
  - Question ID
- Clear button to reset search
- Total question count display

### 4. **Quick Preview** 👁️
- Modal dialog with full question details
- Shows:
  - Metadata badges (Subject, Grade, Topic, Format, Marks)
  - Full question text
  - **For MCQ**: All options with correct answer highlighted
  - **For Short Answer**: Correct answer + variations + case sensitivity
  - **For Drag & Drop**: All drag items + correct order
  - Additional info (Paper, Year, Season, Cognitive Level, Difficulty, Created date)

### 5. **Delete Functionality** 🗑️
- Delete button with confirmation dialog
- Shows question preview in confirmation
- Success/error feedback via SnackBar
- Automatically refreshes list after deletion

### 6. **Pagination** ⏭️
- 50 questions per page
- Previous/Next buttons
- Current page indicator (Page X of Y)
- Disabled navigation when on first/last page

### 7. **Responsive Layout** 📱
- Horizontal scrolling for wide table
- Fixed sidebar for filters
- Responsive to different screen sizes

---

## 📁 File Structure

```
lib/admin/
├── views/
│   ├── admin_home_view.dart           (Updated - Added navigation)
│   └── question_list_view.dart        (NEW - 520 lines)
├── viewmodels/
│   └── question_list_viewmodel.dart   (NEW - 270 lines)
└── widgets/
    └── question_preview_dialog.dart   (NEW - 460 lines)
```

---

## 🔄 State Management

### QuestionListState
```dart
class QuestionListState {
  final List<QuestionListItem> questions;     // Loaded questions
  final bool isLoading;                       // Loading indicator
  final String? errorMessage;                 // Error message
  final String searchQuery;                   // Search text
  final String? filterSubject;                // Subject filter
  final int? filterGrade;                     // Grade filter
  final String? filterFormat;                 // Format filter
  final String? filterTopic;                  // Topic filter
  final int currentPage;                      // Current page number
  final int itemsPerPage;                     // Items per page (50)
  final int totalItems;                       // Total question count
}
```

### ViewModel Methods
- `loadQuestions()` - Load questions with filters
- `updateSearchQuery(String)` - Update search and reload
- `updateSubjectFilter(String?)` - Update subject filter
- `updateGradeFilter(int?)` - Update grade filter
- `updateFormatFilter(String?)` - Update format filter
- `updateTopicFilter(String?)` - Update topic filter
- `clearFilters()` - Reset all filters
- `goToPage(int)` - Navigate to specific page
- `nextPage()` - Go to next page
- `previousPage()` - Go to previous page
- `deleteQuestion(String)` - Delete question by ID
- `refresh()` - Reload current view

---

## 🎨 UI Components

### Color-Coded Format Badges
- **MCQ** - Blue
- **Short Answer** - Green
- **Drag & Drop** - Orange
- **True/False** - Purple
- **Essay** - Pink

### Action Buttons
- **👁️ Preview** - Opens preview dialog
- **✏️ Edit** - Navigates to edit view (coming soon)
- **🗑️ Delete** - Shows confirmation dialog

---

## 🚀 How to Use

### 1. Access Question Browser
```bash
# Run admin portal
flutter run -d chrome -t lib/main_admin.dart

# Navigate to "View Questions" from home page
```

### 2. Search for Questions
1. Type in search bar at top
2. Search updates in real-time
3. Click clear (X) button to reset

### 3. Filter Questions
1. Use sidebar filters:
   - Select Subject
   - Select Grade
   - Select Format
   - Select Topic (after selecting subject)
2. Click "Clear All" to reset filters

### 4. Preview Question
1. Click 👁️ (eye) icon in Actions column
2. Modal dialog shows full question details
3. Click X or outside to close

### 5. Delete Question
1. Click 🗑️ (delete) icon in Actions column
2. Confirm deletion in dialog
3. Question is removed from Firestore
4. List automatically refreshes

### 6. Navigate Pages
- Use ◀️ Previous / Next ▶️ buttons at bottom
- Current page shown as "Page X of Y"

---

## 🔧 Firestore Queries

### Load Questions Query
```javascript
// Base query
collection('questions')
  .where('subject', '==', selectedSubject)      // Optional
  .where('grade', '==', selectedGrade)          // Optional
  .where('questionType', '==', selectedFormat)  // Optional
  .where('topic', '==', selectedTopic)          // Optional
  .orderBy('createdAt', descending: true)
  .limit(50)
```

### Delete Question
```javascript
collection('questions')
  .doc(questionId)
  .delete()
```

---

## 🎯 Future Enhancements

### Phase 1 (Next):
1. ✅ **Edit Question** - Navigate to edit form with pre-populated data
2. ✅ **Bulk Select** - Checkboxes for selecting multiple questions
3. ✅ **Bulk Delete** - Delete multiple questions at once
4. ✅ **Export to CSV** - Download filtered questions as CSV

### Phase 2:
1. ✅ **Advanced Sorting** - Click column headers to sort
2. ✅ **Column Visibility** - Show/hide columns
3. ✅ **Saved Filters** - Save common filter combinations
4. ✅ **Quick Filters** - "My Questions", "Recent", "Errors"

### Phase 3:
1. ✅ **Bulk Edit** - Update multiple questions at once
2. ✅ **Duplicate Question** - Clone question with modifications
3. ✅ **Question History** - View edit history
4. ✅ **Advanced Search** - Search by multiple criteria

---

## 🐛 Known Limitations

### Current Implementation:
1. **Client-Side Search** - Search is done client-side (not optimal for large datasets)
   - **Future**: Implement Algolia or Firestore full-text search
   
2. **Simple Pagination** - Loads all questions for current page
   - **Future**: Implement cursor-based pagination for better performance
   
3. **No Bulk Operations** - Can only delete one question at a time
   - **Future**: Add checkboxes and bulk action toolbar

4. **Edit Button Not Functional** - Shows "Coming Soon" message
   - **Next**: Implement edit feature with pre-populated form

---

## 📊 Performance Considerations

### Current Performance:
- ✅ Loads 50 questions per request
- ✅ Filters applied at Firestore level (efficient)
- ⚠️ Search applied client-side (inefficient for large datasets)
- ✅ Preview loads single document on-demand

### Optimization Strategies:
1. **Pagination**: Cursor-based for large datasets
2. **Search**: Algolia integration for full-text search
3. **Caching**: Cache recent queries in memory
4. **Lazy Loading**: Load additional data only when needed

---

## 🧪 Testing Checklist

- [x] Load questions successfully
- [x] Apply subject filter
- [x] Apply grade filter
- [x] Apply format filter
- [x] Apply topic filter (when subject selected)
- [x] Clear all filters
- [x] Search by question text
- [x] Search by topic
- [x] Search by ID
- [x] Preview MCQ question
- [x] Preview short answer question
- [x] Preview drag & drop question
- [x] Delete question with confirmation
- [x] Navigate to next page
- [x] Navigate to previous page
- [x] Handle empty state (no questions)
- [x] Handle error state (Firestore error)
- [x] Refresh questions

---

## 💡 Usage Tips

### For Content Managers:
1. **Find Recent Questions**: Use default view (sorted by creation date)
2. **Find Subject Questions**: Filter by subject + grade
3. **Find Errors**: Search for "TODO" or common error patterns
4. **Quick Preview**: Hover and click eye icon instead of opening edit form

### For Administrators:
1. **Quality Control**: Use format filter to review specific question types
2. **Topic Coverage**: Filter by topic to check question distribution
3. **Bulk Cleanup**: Use search + delete for removing test questions

---

## 🔗 Related Files

### Dependencies:
- `question_create_view.dart` - Create new questions
- `question_create_viewmodel.dart` - Form state management
- `app_colors.dart` - Color constants
- `app_constants.dart` - Subjects, grades, topics

### Future Integration:
- `question_edit_view.dart` - Edit existing questions (coming soon)
- `bulk_operations_service.dart` - Bulk actions (coming soon)

---

**Feature Completed:** October 5, 2025  
**Status:** ✅ Ready for Production  
**Lines of Code:** ~1,250 lines (3 new files)  
**Estimated Time to Build:** 4-6 hours
