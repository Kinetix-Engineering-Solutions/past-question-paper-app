# Past Question Paper STEM

A Flutter application for managing STEM past examination papers with support for multiple question types and interactive learning.

## Overview

This application provides an interface for students and educators to access, study, and practice with past examination papers in Science, Technology, Engineering, and Mathematics (STEM) subjects. The application uses the Strategy Pattern to support multiple question types, and Riverpod for state management.

## Features

- **Multiple Question Types**: Support for MCQ, drag-and-drop, and true/false questions
- **Interactive Learning**: Explanations, visual feedback, and progress tracking
- **Media Support**: Images for questions and answer options
- **Topic Organization**: Hierarchical navigation through subjects, exam types, and topics
- **Clean Architecture**: Separation of concerns using the Strategy and Factory patterns
- **Reactive UI**: State management with Riverpod
- **Cross-platform compatibility**: iOS, Android, Web

## Architecture

### Strategy Pattern

The app uses the Strategy Pattern to encapsulate question type-specific behaviors:

- `QuestionStrategy` (abstract class): Defines the interface for all question type strategies
- Concrete strategies:
  - `MultipleChoiceStrategy`: Handles multiple choice questions
  - `DragAndDropStrategy`: Handles drag-and-drop ordering questions
  - `TrueFalseStrategy`: Handles true/false questions

### Factory Pattern

`QuestionStrategyFactory` creates appropriate strategies based on question type, providing a clean way to instantiate strategies for different question types.

## Development

### Prerequisites
- Flutter SDK
- Dart SDK
- Your preferred IDE (VS Code, Android Studio, etc.)

### Setup
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## License

This project is proprietary software.
