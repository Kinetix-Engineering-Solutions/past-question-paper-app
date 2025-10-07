# Admin Widgets - Question Creation Components

## 📁 Overview
This directory contains modular widget components extracted from the monolithic `question_create_view.dart` for better code organization and maintainability.

---

## 🧩 Widget Components

### 1. **basic_info_section.dart**
**Purpose:** Subject, Grade, Topic, Paper, Year, Season selection  
**State:** ConsumerWidget (watches `questionCreateViewModelProvider`)  
**Key Fields:**
- Subject dropdown (mathematics, physical sciences, life sciences)
- Grade dropdown (10, 11, 12)
- Topic dropdown (filtered by subject)
- Paper dropdown (p1, p2, p3)
- Year text field
- Season dropdown (November, June, March)

**Usage:**
```dart
const BasicInfoSection()
```

---

### 2. **question_content_section.dart**
**Purpose:** Question format selection and question text input  
**Props:** 
- `questionTextController` - TextEditingController for question text

**Key Fields:**
- Format dropdown (MCQ, Short Answer, Drag & Drop, True/False, Essay)
- Question text multi-line input (4 lines)

**Usage:**
```dart
QuestionContentSection(
  questionTextController: _questionTextController,
)
```

---

### 3. **mcq_answer_section.dart**
**Purpose:** MCQ-specific answer configuration  
**Props:**
- `optionAController` - Option A text controller
- `optionBController` - Option B text controller
- `optionCController` - Option C text controller
- `optionDController` - Option D text controller
- `explanationController` - Explanation text controller

**Key Fields:**
- 4 option text fields (A, B, C, D)
- Correct answer dropdown (A, B, C, D)
- Explanation multi-line input (3 lines, optional)

**Usage:**
```dart
MCQAnswerSection(
  optionAController: _optionAController,
  optionBController: _optionBController,
  optionCController: _optionCController,
  optionDController: _optionDController,
  explanationController: _explanationController,
)
```

---

### 4. **short_answer_section.dart**
**Purpose:** Short answer configuration with variations  
**Props:**
- `correctAnswerController` - Primary answer controller
- `variationControllers` - List of variation controllers
- `onAddVariation` - Callback to add variation
- `onRemoveVariation` - Callback to remove variation

**Key Fields:**
- Correct answer text field
- Case sensitive checkbox
- Dynamic list of answer variations
- Add/remove variation buttons

**Usage:**
```dart
ShortAnswerSection(
  correctAnswerController: _correctAnswerController,
  variationControllers: _variationControllers,
  onAddVariation: _addAnswerVariation,
  onRemoveVariation: _removeAnswerVariation,
)
```

---

### 5. **drag_drop_section.dart**
**Purpose:** Drag & drop ordering question configuration  
**Props:**
- `dragItemControllers` - List of step controllers
- `correctOrderController` - Correct order controller
- `onAddDragItem` - Callback to add step
- `onRemoveDragItem` - Callback to remove step

**Key Fields:**
- Info banner explaining drag-drop behavior
- Dynamic list of step items (numbered)
- Correct order text field (comma-separated numbers)
- Add/remove step buttons

**Usage:**
```dart
DragDropSection(
  dragItemControllers: _dragItemControllers,
  correctOrderController: _correctOrderController,
  onAddDragItem: _addDragItem,
  onRemoveDragItem: _removeDragItem,
)
```

---

### 6. **metadata_section.dart**
**Purpose:** Question metadata (marks, cognitive level, difficulty)  
**Props:**
- `marksController` - Marks text controller

**Key Fields:**
- Marks number input (validated)
- Cognitive level dropdown (Level 1-4)
- Difficulty dropdown (easy, medium, hard)

**Usage:**
```dart
MetadataSection(marksController: _marksController)
```

---

### 7. **availability_section.dart**
**Purpose:** Mode availability toggles and PQP number  
**Props:**
- `pqpNumberController` - PQP question number controller

**Key Fields:**
- PQP mode checkbox (shows PQP number field when enabled)
- Sprint mode checkbox
- By Topic mode checkbox
- PQP question number text field (conditional)

**Usage:**
```dart
AvailabilitySection(
  pqpNumberController: _pqpNumberController,
)
```

---

### 8. **question_preview_panel.dart**
**Purpose:** Live preview of current question state  
**State:** ConsumerWidget (watches `questionCreateViewModelProvider`)

**Displays:**
- Subject, Grade, Topic
- Format, Marks
- Question text
- Correct answer (if set)
- Correct order (if set)

**Usage:**
```dart
const QuestionPreviewPanel()
```

---

## 🔄 Refactoring Benefits

### Before (900+ lines monolithic file):
```
question_create_view.dart
├── _buildBasicInfoSection()
├── _buildQuestionContentSection()
├── _buildAnswerSection()
│   ├── _buildMCQAnswerSection()
│   ├── _buildShortAnswerSection()
│   └── _buildDragDropSection()
├── _buildMetadataSection()
├── _buildAvailabilitySection()
└── _buildPreviewPanel()
```

### After (modular widget files):
```
lib/admin/
├── views/
│   └── question_create_view.dart (300 lines - main coordination)
└── widgets/
    ├── basic_info_section.dart (115 lines)
    ├── question_content_section.dart (55 lines)
    ├── mcq_answer_section.dart (80 lines)
    ├── short_answer_section.dart (100 lines)
    ├── drag_drop_section.dart (140 lines)
    ├── metadata_section.dart (75 lines)
    ├── availability_section.dart (70 lines)
    └── question_preview_panel.dart (110 lines)
```

### Advantages:
✅ **Separation of Concerns** - Each widget has single responsibility  
✅ **Reusability** - Widgets can be used in other forms (e.g., edit question)  
✅ **Testability** - Easier to unit test individual widgets  
✅ **Maintainability** - Easier to locate and fix bugs  
✅ **Readability** - Smaller files, clearer structure  
✅ **Team Collaboration** - Multiple devs can work on different sections  

---

## 📝 State Management Pattern

All widgets follow **Riverpod ConsumerWidget** pattern:

```dart
class MySection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questionCreateViewModelProvider);
    final notifier = ref.read(questionCreateViewModelProvider.notifier);
    
    // Use state for reading values
    // Use notifier for updating values
  }
}
```

**Controllers** are passed from parent `QuestionCreateView` to maintain form state and validation.

---

## 🎯 Future Improvements

1. **Extract True/False Section** - Add `true_false_section.dart` when implemented
2. **Extract Essay Section** - Add `essay_section.dart` when implemented
3. **Add Widget Tests** - Unit tests for each widget
4. **Image Upload Widget** - Extract image picker to `image_upload_section.dart`
5. **Parent-Child Widget** - Create `parent_child_section.dart` for linked questions

---

## 🔧 How to Add New Section

1. Create new widget file in `lib/admin/widgets/`
2. Extend `ConsumerWidget` or `ConsumerStatefulWidget`
3. Accept required controllers/callbacks as props
4. Use `ref.watch()` for state, `ref.read().notifier` for updates
5. Import in `question_create_view.dart`
6. Add to `_buildAnswerSection()` or appropriate section

**Example:**
```dart
// lib/admin/widgets/my_new_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/viewmodels/question_create_viewmodel.dart';

class MyNewSection extends ConsumerWidget {
  final TextEditingController myController;
  
  const MyNewSection({super.key, required this.myController});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questionCreateViewModelProvider);
    return TextFormField(controller: myController);
  }
}
```

---

**Last Updated:** October 5, 2025  
**Refactored By:** Kinetix Engineering Solutions
