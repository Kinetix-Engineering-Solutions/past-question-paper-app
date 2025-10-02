# AI Coding Agent Instructions - Past Question Papers App

## 🎯 Project Overview
This is a **Flutter + Firebase** educational app for practicing past exam questions across multiple subjects. The system supports three practice modes: **Full Exam (PQP)**, **Quick Practice (Sprint)**, and **By Topic**, with specialized question formats (MCQ, drag-drop, short answer) and Cloud Functions for test generation/grading.

---

## 🏗️ Architecture Essentials

### MVVM + Riverpod Pattern
- **ViewModels** (`lib/viewmodels/`) extend `StateNotifier<State>` with Riverpod providers
- **Services** (`lib/services/`) handle Firebase operations (auth, Firestore, storage)
- **Repositories** (`lib/repositories/`) provide data abstraction layer (minimal usage currently)
- **Views** (`lib/views/`) are `ConsumerWidget` or `ConsumerStatefulWidget` that watch providers

**Example pattern:**
```dart
// ViewModel with provider
final practiceViewModelProvider = StateNotifierProvider<PracticeViewModel, PracticeState>(...);

// View consuming state
class PracticeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(practiceViewModelProvider);
    // Use state.questions, state.currentIndex, etc.
  }
}
```

### Three Practice Modes (Critical Design Decision)
The app uses **mode flags** (`isPQPMode`, `isSprintMode`, `isByTopicMode`) passed through navigation, NOT separate data structures:
- **PQP (Past Question Paper)**: Exam-authentic mode with actual question numbering (e.g., "Question 4.2.1")
- **Sprint (Quick Practice)**: Mixed questions with hints, sequential numbering
- **By Topic**: Filtered questions by specific topic

**Key files:**
- `lib/views/test_configuration_screen.dart` - Three-tab configuration UI
- `lib/views/practice_screen.dart` - Unified practice interface for all modes
- `lib/model/question.dart` - Question model with `pqpData`/`sprintData` for mode-specific overrides

### Question Numbering System
**PQP mode displays actual exam paper numbering** (e.g., "4.2.1" not "Question 1 of 10"):
```dart
// AppBar in practice_screen.dart
String _getQuestionTitle(List<Question> questions) {
  final question = questions[_currentPage];
  if (widget.isPQPMode && question.pqpData?.questionNumber != null) {
    return 'Question ${question.pqpData!.questionNumber}'; // "Question 4.2.1"
  }
  return 'Question ${_currentPage + 1} of ${questions.length}'; // "Question 1 of 10"
}
```
See `QUESTION_NUMBERING_ISSUE_ANALYSIS.md` for full context on why this matters.

---

## 🎨 Design System - "Paper & Ink" Theme

### Color Palette (`lib/utils/app_colors.dart`)
**Monochrome + Single Accent:**
- `AppColors.ink` (#262626) - Primary text, dark elements
- `AppColors.paper` (#F5F5F5) - Background
- `AppColors.accent` (#FF7A1A) - Orange for CTAs and highlights
- `AppColors.neutralCard` (#FFFFFF) - Card backgrounds

**DO NOT** introduce new colors without team approval. This is a deliberate minimal palette.

### Theme Implementation
- `AppTheme.paperAndInkTheme` in `lib/utils/app_theme.dart` defines global theme
- Use `AppColors` constants directly, NOT hardcoded hex values
- Material 3 design with custom color scheme

---

## 📝 Question Format Widgets

### Self-Contained Widget Pattern
Each question type has a dedicated widget in `lib/widgets/question_formats/`:
- `mcq_text_widget.dart` - Multiple choice with text options
- `mcq_image_widget.dart` - MCQ with image-based options
- `drag_and_drop_widget.dart` - Interactive drag-and-drop matching
- `short_answer_widget.dart` - Text input for short answers
- `essay_widget.dart` - Long-form text responses
- `true_false_widget.dart` - Binary choice questions

**Answer Storage Pattern:**
```dart
ref.read(practiceViewModelProvider.notifier).answerQuestion(question.id, userAnswer);
```

**Format Selection Logic** (in `practice_screen.dart`):
```dart
switch (question.questionType.toLowerCase()) {
  case 'mcq':
    return question.hasImageOptions 
      ? MCQImageWidget(question: question, selectedOption: selectedOption)
      : MCQTextWidget(question: question, selectedOption: selectedOption);
  case 'drag_drop_ordering':
    return DragAndDropOrderingWidget(question: question, currentAnswers: answers);
  // ... other formats
}
```

### LaTeX Support
- Use `flutter_math_fork` package for mathematical expressions
- Wrap math expressions in `LatexText` widget (from `lib/widgets/latex_text.dart`)
- LaTeX is automatically rendered in question text and options

---

## 🔥 Firebase Integration

### Critical Setup Files
- `lib/firebase_options.dart` - **Auto-generated**, DO NOT edit manually (use `flutterfire configure`)
- `firebase.json` - Hosting and emulator configuration
- `firestore.rules` / `storage.rules` - Security rules (deploy separately)

### Cloud Functions (Node.js)
Located in `functions/` directory with modular architecture:
```
functions/
├── index.js                 # HTTP endpoints (generateTest, gradeTest)
└── src/
    ├── services/           # Business logic
    │   ├── testService.js
    │   ├── gradingService.js
    │   └── databaseService.js
    └── helpers/            # Utilities
```

**Test Generation Flow:**
1. Client calls `generateTest` Cloud Function with params (subject, year, season, mode)
2. Function fetches blueprint from `blueprints` collection
3. Queries `questions` collection with filters
4. Returns sanitized questions (answers stripped for client)

**Grading Flow:**
1. Client submits answers to `gradeTest` function
2. Function fetches correct answers from Firestore
3. Grades by question type (MCQ, drag-drop, short answer)
4. Returns results with score, percentage, detailed breakdown

### Firestore Collections
- `questions/` - Question documents (MCQ, drag-drop as individual docs; short answers in single doc "short_answer")
- `blueprints/` - Subject-specific test generation blueprints
- `users/` - User profiles and progress
- `test_sessions/` - Active test sessions

**Known Issue:** Short answers stored in single mega-document instead of individual docs (see `FIRESTORE_STRUCTURE_EXAMPLES.md` for proposed migration).

---

## 🔧 Development Workflows

### Running the App
```bash
flutter run                    # Default device
flutter run -d chrome          # Web browser
flutter run -d windows         # Windows desktop
flutter run --release          # Release mode
```

### Firebase Emulator (Local Development)
```bash
firebase emulators:start       # Start all emulators
firebase emulators:start --only firestore,functions
```

### Deploying Functions
```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

### Testing
```bash
flutter test                   # Run all tests
flutter test --coverage        # With coverage report
flutter test test/model/question_test.dart  # Specific file
```

### Code Generation (if using freezed/json_serializable in future)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🚨 Critical Conventions

### 1. Question Model Access Pattern
**ALWAYS** use mode-specific getters for question data:
```dart
// ✅ CORRECT
final text = question.getPQPQuestionText();  // or getSprintQuestionText()
final marks = question.getPQPMarks();

// ❌ WRONG
final text = question.pqpData?.questionText ?? question.questionText;
```

### 2. State Management Rules
- **NEVER** call `setState` in `ConsumerWidget` - use `ref.read().notifier` to update state
- **ALWAYS** use `ref.watch()` for reactive state, `ref.read()` for one-time reads
- ViewModels should be **immutable** - use `copyWith` pattern for state updates

### 3. Navigation
- Use `NavigationService.navigatorKey` for programmatic navigation (not `BuildContext`)
- Named routes defined in `main.dart` (`/login`, `/home`, `/onboarding`)
- Pass mode flags through `Navigator.push` arguments, not global state

### 4. Error Handling
- Use custom exceptions from `lib/Exceptions/` (e.g., `AuthException`, `DatabaseException`)
- Show user-friendly errors with `SnackBar` or dialog, log technical details
- Wrap Firebase calls in try-catch with specific error types

### 5. Asset References
- Images: `assets/images/` (configured in `pubspec.yaml`)
- Environment variables: `.env` file (gitignored, use `.env.example` template)

---

## 📚 Key Documentation Files

- `README.md` - General setup and features overview
- `FIREBASE_SETUP.md` - Detailed Firebase configuration steps
- `QUESTION_NUMBERING_ISSUE_ANALYSIS.md` - Why PQP mode uses exam paper numbering
- `FIRESTORE_STRUCTURE_EXAMPLES.md` - Database schema with real examples
- `PROPOSED_FIRESTORE_STRUCTURE.md` - Future hierarchical question structure
- `functions/README.md` - Cloud Functions architecture and API reference

---

## 🐛 Common Pitfalls

1. **Forgetting to configure Firebase** - Run `flutterfire configure` before first run
2. **Using wrong question text** - Remember `getPQPQuestionText()` vs `getSprintQuestionText()`
3. **Breaking the monochrome theme** - Only use `AppColors` constants
4. **Modifying auto-generated files** - `firebase_options.dart`, `.freezed.dart`, `.g.dart` are generated
5. **Not handling null safety** - All question data fields are nullable, check before access
6. **Mixing mode logic** - Don't hardcode mode checks, use passed `isPQPMode`/`isSprintMode` flags

---

## 🎓 Team-Specific Patterns

### Dual-Mode Data (PQPData/SprintData)
Questions have optional `pqpData` and `sprintData` for mode-specific overrides:
```dart
class Question {
  final String questionText;        // Base text
  final PQPData? pqpData;          // PQP-specific overrides
  final SprintData? sprintData;    // Sprint-specific overrides
}
```
**Use case:** PQP shows exam paper numbering ("4.2.1"), Sprint shows hints.
See `PQP_AND_SPRINT_DATA_EXPLAINED.md` for full explanation.

### Test Configuration Flow
1. User selects mode in `test_configuration_screen.dart` (3 tabs)
2. User picks subject, year, season (for PQP), or topic (for By Topic)
3. Calls Cloud Function `generateTest` with parameters
4. Navigation to `practice_screen.dart` with questions + mode flags
5. Practice screen adapts UI based on mode (numbering, hints, chains)

### Image Question Handling
Questions with images reference `imageUrl` field:
- **Current Issue:** Sub-questions duplicate the image URL (e.g., 4.1.1, 4.1.2 both store same image)
- **Future Fix:** Parent question structure with single image (see `PROPOSED_FIRESTORE_STRUCTURE.md`)

---

## 💡 Quick Reference

**Import Aliases:**
```dart
import 'package:past_question_paper_v1/...' // Main app package
```

**Firebase Project ID:** `vibe-code-4c59f` (check `firebase.json`)

**Minimum SDK:** Dart 3.8.0, Flutter 3.8+

**State Provider Pattern:**
```dart
final myProvider = StateNotifierProvider<MyViewModel, MyState>((ref) => MyViewModel());
```

**Widget Test Boilerplate:**
```dart
testWidgets('description', (WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: MyWidget())),
  );
  // assertions
});
```

---

## 🤝 Contributing Guidelines

- Follow Dart style guide (use `dart format` and `flutter analyze`)
- Update relevant `.md` docs when changing architecture patterns
- Add tests for new ViewModels and critical business logic
- Keep color palette minimal (paper, ink, orange accent only)
- Document non-obvious "why" decisions in code comments or markdown files

---

**Last Updated:** October 2, 2025
**Maintained by:** Kinetix Engineering Solutions

