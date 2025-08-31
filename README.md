# 📚 Past Question Papers App

A comprehensive Flutter application for past question papers and practice tests across all academic subjects. This app helps students access, practice, and improve their performance on various subjects through interactive question formats and detailed analytics.

## 🚀 Features

### 📖 Core Features
- **Multi-format Questions**: MCQ (text/image), True/False, Short Answer, Essay, and Drag & Drop questions
- **LaTeX Support**: Mathematical equations and formulas rendered beautifully
- **Practice Sessions**: Timed practice tests with configurable parameters
- **Subject Management**: Organized by different academic subjects and topics
- **User Authentication**: Secure Firebase-based authentication with email/password and email links
- **Progress Tracking**: Detailed analytics and performance insights
- **Offline Capability**: Practice questions even without internet connection

### 🎯 Question Types Supported
- **Multiple Choice (Text)**: Standard MCQ with text-based options
- **Multiple Choice (Image)**: MCQ with image-based questions and options  
- **True/False**: Boolean-type questions
- **Short Answer**: Brief text responses
- **Essay Questions**: Long-form written responses
- **Drag & Drop**: Interactive drag-and-drop matching questions

### 📚 Subject Coverage
- **STEM Subjects**: Mathematics, Physics, Chemistry, Biology, Computer Science
- **Humanities**: History, Geography, Literature, Philosophy
- **Social Sciences**: Economics, Political Science, Sociology, Psychology
- **Languages**: English, Foreign Languages, Linguistics
- **Professional Studies**: Business, Law, Medicine, Engineering
- **And Many More**: Customizable for any academic subject

### 🔐 Security & Authentication
- Firebase Authentication with email/password
- Email link authentication for passwordless login
- App Check integration for API security
- Secure user data management with Firestore

## 🛠️ Technology Stack

### Frontend
- **Flutter**: Cross-platform mobile development
- **Riverpod**: State management solution
- **Go Router**: Navigation and routing
- **Flutter Math Fork**: LaTeX mathematical equation rendering
- **Lottie**: Animations and micro-interactions

### Backend & Services
- **Firebase Core**: Core Firebase functionality
- **Firebase Authentication**: User authentication
- **Cloud Firestore**: NoSQL database for questions and user data
- **Cloud Functions**: Serverless backend logic
- **Firebase Storage**: File and image storage
- **Firebase App Check**: API abuse protection

### Development Tools
- **Flutter 3.8+**: Latest Flutter framework
- **Dart**: Programming language
- **FlutterFire CLI**: Firebase configuration management

## 📱 Platform Support

- ✅ **Android**: Full support with Material Design
- ✅ **iOS**: Native iOS experience
- ✅ **Web**: Progressive Web App capabilities
- ✅ **Windows**: Desktop application
- ✅ **macOS**: Desktop application  
- ✅ **Linux**: Desktop application

## 🏗️ Project Structure

```
lib/
├── Exceptions/           # Custom exception classes
├── model/               # Data models and entities
│   ├── drag_and_drop_models/  # Drag & drop specific models
│   ├── practice_mode.dart
│   ├── question.dart
│   ├── user.dart
│   └── ...
├── providers/           # Riverpod state providers
├── repositories/        # Data repository pattern
├── services/           # Business logic and API services
│   ├── auth_service_firebase.dart
│   ├── firestore_database_firebase.dart
│   └── ...
├── utils/              # Utility classes and constants
│   ├── app_colors.dart
│   ├── app_theme.dart
│   └── ...
├── viewmodels/         # MVVM architecture view models
├── views/              # UI screens and pages
│   ├── home_screen.dart
│   ├── practice_screen.dart
│   └── ...
├── widgets/            # Reusable UI components
│   ├── question_formats/  # Question type specific widgets
│   ├── latex_text.dart
│   └── ...
└── main.dart           # Application entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.0 or higher
- Dart SDK 3.0.0 or higher
- Firebase project with enabled services
- Platform-specific development tools (Android Studio/Xcode)

### 1. Clone Repository
```bash
git clone https://github.com/Kinetix-Engineering-Solutions/past-question-paper-v0.01.git
cd past-question-paper-v0.01
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup
**⚠️ IMPORTANT**: This project requires Firebase configuration. See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed setup instructions.

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

### 4. Environment Configuration
```bash
# Copy environment template
cp .env.example .env

# Edit .env with your configuration values
# Note: .env file is gitignored for security
```

### 5. Run the Application
```bash
# Debug mode
flutter run

# Release mode  
flutter run --release

# Specific platform
flutter run -d chrome    # Web
flutter run -d android   # Android
flutter run -d ios       # iOS
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/model/question_test.dart
```

## 📦 Build for Production

### Android
```bash
flutter build apk --release                    # APK
flutter build appbundle --release             # AAB (recommended)
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### Desktop
```bash
flutter build windows --release               # Windows
flutter build macos --release                # macOS  
flutter build linux --release                # Linux
```

## 🔧 Configuration

### Firebase Services Required
- **Authentication**: Email/password, email links
- **Firestore Database**: Question storage, user data
- **Cloud Functions**: Backend logic (optional)
- **Storage**: Image and file uploads
- **App Check**: API protection (recommended)

### Environment Variables
See `.env.example` for all configurable environment variables.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Dart/Flutter style guidelines
- Write tests for new features
- Update documentation as needed
- Ensure all CI checks pass

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support & Documentation

- **Setup Guide**: [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
- **Security Guide**: [FIREBASE_SECURITY.md](FIREBASE_SECURITY.md)
- **API Documentation**: Generated in `doc/api/`
- **Issue Tracker**: [GitHub Issues](https://github.com/Kinetix-Engineering-Solutions/past-question-paper-v0.01/issues)

## 👥 Team

**Kinetix Engineering Solutions**
- 🌐 Website: [https://kinetix.engineering](https://kinetix.engineering)
- 📧 Email: contact@kinetix.engineering
- 🐙 GitHub: [@Kinetix-Engineering-Solutions](https://github.com/Kinetix-Engineering-Solutions)

## 🔄 Version History

- **v0.01**: Initial release with core functionality
- **Latest**: Enhanced security, improved documentation, package fixes

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for backend services  
- Contributors to open-source packages used
- Educational community for feedback and testing

---

**📱 Download the app and start practicing questions from any subject today!**
