# Admin Portal Quick Start

## 🚀 Running the Admin Portal

The admin portal is a Flutter Web application for quickly inputting questions into Firestore.

### Run locally:
```bash
flutter run -d chrome -t lib/main_admin.dart
```

### Build for production:
```bash
flutter build web -t lib/main_admin.dart --web-renderer html --base-href /admin/
```

## 📝 Features (Current MVP)

### ✅ Available Now:
- **Create Standalone Questions**
  - MCQ (Multiple Choice)
  - Short Answer
  - Drag & Drop
  - True/False
  - Essay

- **Question Configuration**
  - Subject, Grade, Topic selection
  - Paper (P1, P2, P3), Year, Season
  - Marks, Cognitive Level, Difficulty
  - Mode availability (PQP, Sprint, By Topic)
  - Live preview

### 🔜 Coming Soon:
- Parent-Child question creator
- Question browser and editor
- Bulk upload from CSV
- Image upload

## 🔧 Authentication

Currently **disabled** for quick data entry. All questions are created by "admin" user.

To enable authentication later:
1. Add Firebase Auth UI
2. Configure custom claims for roles
3. Gate routes with role checks

## 📂 File Structure

```
lib/admin/
├── views/
│   ├── admin_home_view.dart          # Landing page
│   └── question_create_view.dart     # Question form
├── viewmodels/
│   └── question_create_viewmodel.dart # Form state & Firestore logic
└── widgets/
    └── (future components)
```

## 🗄️ Database Structure

Questions are saved to `questions` collection with this structure:

```javascript
{
  // Core fields
  questionText: string,
  questionType: "MCQ" | "short_answer" | "drag_drop" | "true_false" | "essay",
  correctAnswer: string,
  
  // Metadata
  subject: string,
  grade: number,
  topic: string,
  paper: "p1" | "p2" | "p3",
  year: number,
  season: "November" | "June" | "March",
  marks: number,
  cognitiveLevel: "Level 1" | "Level 2" | "Level 3" | "Level 4",
  difficulty: "easy" | "medium" | "hard",
  
  // Parent-child
  isParent: false,
  parentQuestionId: null,
  
  // Mode availability
  availableInPQP: boolean,
  availableInSprint: boolean,
  availableInByTopic: boolean,
  
  // Format-specific
  options: string[],           // MCQ only
  answerVariations: string[],  // Short answer only
  caseSensitive: boolean,      // Short answer only
  
  // Mode-specific data
  pqpData: {
    questionNumber: string,
    questionText: string,
    marks: number
  },
  sprintData: {
    hint: string,
    difficulty: string
  },
  
  // Timestamps
  createdAt: Timestamp,
  updatedAt: Timestamp,
  createdBy: string
}
```

## 🎨 UI Design

Follows "Paper & Ink" theme:
- **Ink** (#262626) - Dark elements
- **Paper** (#F5F5F5) - Backgrounds
- **Accent** (#FF7A1A) - Orange highlights

Two-column layout:
- **Left**: Form fields
- **Right**: Live preview

## 🐛 Troubleshooting

### Port already in use:
```bash
flutter run -d chrome -t lib/main_admin.dart --web-port 8081
```

### Hot reload not working:
Use `r` in terminal or Ctrl+S to trigger reload

### Firebase connection issues:
Check `lib/firebase_options.dart` is properly configured

## 📖 Next Steps

After creating questions:
1. Test in main app with test generation
2. Verify question display in all modes
3. Check grading works correctly
4. Add parent-child questions if needed
