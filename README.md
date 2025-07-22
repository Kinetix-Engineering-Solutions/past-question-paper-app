# Past Question Paper STEM

A Flutter application for practicing STEM examination questions with seasonal organization and time-based practice modes.

## Overview

This application provides a focused practice environment for students to work through past examination papers in Science, Technology, Engineering, and Mathematics (STEM) subjects. The app emphasizes pure practice without learning components, allowing students to test their knowledge across different seasons and topics using various time-based practice modes.

## Features

- **Practice-Focused**: Pure question practice without learning modules or explanations
- **Seasonal Organization**: Questions organized by academic seasons (Spring, Fall, Winter, Summer)
- **Time-Based Practice**: Multiple practice modes (5min, 15min, 30min, unlimited)
- **Multiple Question Types**: Support for MCQ, drag-and-drop, true/false, and other question formats
- **Topic-Based Navigation**: Hierarchical organization through subjects → topics → questions
- **Grade-Level Filtering**: Content filtered by student's grade level
- **Clean Architecture**: MVVM pattern with Riverpod state management
- **Firebase Integration**: Cloud-based data storage and retrieval
- **Cross-platform**: iOS, Android, and Web support

## App Structure

### Data Models
- **User**: Student profile with grade-level information
- **Subject**: STEM subjects (Mathematics, Physics, Chemistry, Biology, etc.)
- **Topic**: Subject subdivisions organized by season
- **Question**: Practice questions with multiple types and formats

### Navigation Flow
```
Home → Subject Selection → Topic List → Practice Mode → Question Session
```

### Practice Modes
- **Quick Practice**: 5-minute focused sessions
- **Standard Practice**: 15-minute sessions
- **Extended Practice**: 30-minute sessions  
- **Unlimited Practice**: No time restrictions

## Architecture

### MVVM Pattern
The application follows the Model-View-ViewModel architecture:

- **Models**: Data structures for User, Subject, Topic, Question
- **Views**: Flutter widgets for UI presentation
- **ViewModels**: Riverpod StateNotifiers for business logic and state management

### State Management
- **Riverpod**: Reactive state management throughout the app
- **StateNotifier**: For complex state logic in ViewModels
- **Provider**: For dependency injection and state watching

### Database Layer
- **Firebase Firestore**: Cloud database for storing questions and user data
- **Repository Pattern**: Clean separation between data access and business logic
- **Composite Indexes**: Optimized queries for subject + grade + order filtering

## Technical Stack

### Frontend
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **Riverpod**: State management
- **Material Design**: UI components and theming

### Backend
- **Firebase Firestore**: NoSQL cloud database
- **Firebase Auth**: User authentication
- **Firebase Storage**: Media file storage (future images/diagrams)

### Development Tools
- **VS Code**: Primary IDE
- **Flutter DevTools**: Performance monitoring and debugging
- **Git**: Version control

## Development

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK (included with Flutter)
- Firebase CLI
- VS Code or Android Studio
- Git

### Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/Khulow/past_question_paper_stem.git
   cd past_question_paper_stem
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Add your `google-services.json` (Android)
   - Add your `GoogleService-Info.plist` (iOS)
   - Update Firebase configuration in `firebase_options.dart`

4. Run the application:
   ```bash
   flutter run
   ```

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── model/                    # Data models
│   ├── user.dart
│   ├── subject.dart
│   ├── topic.dart
│   └── question.dart
├── viewmodels/              # Business logic
│   ├── home_viewmodel.dart
│   ├── topic_viewmodel.dart
│   └── auth_viewmodel.dart
├── views/                   # UI screens
│   ├── home_screen.dart
│   ├── subject_topics_screen.dart
│   └── auth/
├── services/               # External services
│   └── firestore_database_firebase.dart
├── utils/                  # Utilities
├── widgets/               # Reusable UI components
└── route_manager/         # Navigation
```

### Current Implementation Status
- ✅ User authentication and profile management
- ✅ Subject and grade-level organization
- ✅ Topic listing with seasonal filtering
- ✅ Firebase integration with optimized queries
- ✅ Responsive UI with clean design
- 🚧 Question model and practice sessions (in development)
- 🚧 Time-based practice modes (planned)
- 🚧 Question type strategies (planned)

## Contributing

This is a private educational project. Internal development follows:
1. Feature branches for new functionality
2. Code reviews before merging
3. Consistent coding standards and documentation
4. Testing for core functionality

## License

This project is proprietary educational software. All rights reserved.
