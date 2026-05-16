# 📚 Past Question Papers App

Flutter + Firebase learning platform for practicing exam questions through multiple modes: **Past Paper (PQP)**, **Sprint**, **By Topic**, and **Retry Mistakes**.

## 🚀 Current Features

### Student Experience
- Multi-mode practice: PQP, Sprint, By Topic, Retry Mistakes
- Question formats: MCQ (text/image), True/False, Short Answer, Essay, Drag & Drop
- LaTeX rendering for math content
- Session grading with detailed results and review
- Mistake bank tracking and retry workflows
- Past paper library and PDF viewer

### Platform & Security
- Firebase Authentication + App Check
- Cloud Firestore for questions/progress
- Cloud Functions for generation/grading
- Firebase Storage for media and paper assets

## 🛠️ Tech Stack

- **Frontend**: Flutter, Riverpod, Material 3
- **Backend**: Firebase Functions (Node 20), Firestore, Storage, Auth
- **Math Rendering**: `flutter_math_fork`

## 🏗️ Architecture (Current)

### App (`lib/`)

Feature-first layout with shared core services:

```text
lib/
├── core/
│   ├── app/
│   ├── shared/
│   └── theme/
├── features/
│   ├── auth/
│   ├── history/
│   ├── home/
│   ├── library/
│   ├── practice/
│   └── profile/
├── admin/
├── widgets/
├── Exceptions/
├── main.dart
└── main_admin.dart
```

### Functions (`functions/src`)

Modular Cloud Functions layout:

```text
functions/src/
├── app.js
├── core/
├── helpers/
└── modules/
    ├── test_generation/
    ├── grading/
    ├── user_lifecycle/
    └── shared/
```

See detailed backend map in [functions/src/README.md](functions/src/README.md).

## 🚀 Getting Started

### Prerequisites
- Flutter 3.8+
- Dart 3.8+
- Node.js 20+ (for functions)
- Firebase CLI + FlutterFire CLI

### Install

```bash
git clone https://github.com/Kinetix-Engineering-Solutions/past-question-paper-v0.01.git
cd past-question-paper-v0.01
flutter pub get
```

### Configure Firebase

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### Run App

```bash
flutter run
```

### Google Ads setup (Home + Flashcard only)

Ads are wired only into the Home topic list and Flashcard screens, and are disabled by default.

Run with ads enabled and your ad unit IDs:

```bash
flutter run \
  --dart-define=ENABLE_GOOGLE_ADS=true \
  --dart-define=ADMOB_ANDROID_HOME_BANNER_ID=ca-app-pub-xxxx/yyyy \
  --dart-define=ADMOB_ANDROID_FLASHCARD_BANNER_ID=ca-app-pub-xxxx/yyyy \
  --dart-define=ADMOB_IOS_HOME_BANNER_ID=ca-app-pub-xxxx/yyyy \
  --dart-define=ADMOB_IOS_FLASHCARD_BANNER_ID=ca-app-pub-xxxx/yyyy
```

Optional test devices:

```bash
flutter run --dart-define=ADS_TEST_DEVICE_IDS=TEST_DEVICE_ID_1,TEST_DEVICE_ID_2
```

## ☁️ Cloud Functions

```bash
cd functions
npm install
cd ..
firebase emulators:start --only functions
# or deploy
firebase deploy --only functions
```

## 🧪 Testing

```bash
flutter test
flutter test --coverage
```

## 📚 Documentation

- Product feature overview: [APP_FEATURES.md](APP_FEATURES.md)
- Security implementation notes: [SECURITY_IMPLEMENTATION.md](SECURITY_IMPLEMENTATION.md)
- Functions architecture: [functions/src/README.md](functions/src/README.md)

## 🤝 Contributing

1. Create a feature branch
2. Make focused changes with tests/docs updates
3. Open a PR against `develop`

## 👥 Team
Irvin Senwedi

**Kinetix Engineering Solutions**

- Website: https://kinetix.engineering
- GitHub: https://github.com/Kinetix-Engineering-Solutions
