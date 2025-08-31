# Question Format Widgets

This directory contains specialized widgets for rendering different types of questions in the practice screen.

## Available Question Format Widgets

### 1. **MCQTextWidget** (`mcq_text_widget.dart`)
- **Purpose**: Renders multiple-choice questions with text-based options
- **Features**: 
  - LaTeX text support
  - Visual selection indicators
  - Check mark for selected options
- **Used For**: Standard MCQ questions with text options

### 2. **MCQImageWidget** (`mcq_image_widget.dart`)  
- **Purpose**: Renders multiple-choice questions with image-based options
- **Features**:
  - Grid layout for image options
  - Loading indicators
  - Error handling for failed images
  - Visual selection feedback with check marks
- **Used For**: Questions where options are images (graphs, diagrams, etc.)

### 3. **TrueFalseWidget** (`true_false_widget.dart`)
- **Purpose**: Renders true/false questions with two large buttons  
- **Features**:
  - Large True/False buttons with icons
  - Visual feedback for selection
  - Confirmation message showing selected answer
- **Used For**: Binary choice questions

### 4. **ShortAnswerWidget** (`short_answer_widget.dart`)
- **Purpose**: Renders questions requiring short text input
- **Features**:
  - Multi-line text input (3 lines)
  - Clear button when text is entered
  - Instructions and marks display
  - Helpful tips
- **Used For**: Questions requiring brief written responses

### 5. **EssayWidget** (`essay_widget.dart`)
- **Purpose**: Renders essay questions requiring longer text responses
- **Features**:
  - Large text area (8+ lines)
  - Live word count
  - Detailed instructions and tips
  - Marks display
  - Writing guidelines
- **Used For**: Extended writing questions

### 6. **DragAndDropWidget** (`drag_and_drop_widget.dart`)
- **Purpose**: Renders interactive drag-and-drop questions
- **Features**:
  - Draggable items with visual feedback
  - Drop zones with validation
  - Progress indicator
  - Support for text and image items
  - Remove items from drop zones
  - LaTeX support for mathematical expressions
- **Used For**: Matching, ordering, and categorization questions

## Usage in Practice Screen

Each widget is automatically selected based on the `question.format` field:

```dart
switch (question.format.toLowerCase()) {
  case 'mcq':
    return question.hasImageOptions 
      ? MCQImageWidget(question: question, selectedOption: selectedOption)
      : MCQTextWidget(question: question, selectedOption: selectedOption);
  case 'drag-and-drop':
    return DragAndDropWidget(question: question, currentAnswers: parsedAnswers);
  case 'true_false':
    return TrueFalseWidget(question: question, selectedOption: selectedOption);
  case 'short_answer':
    return ShortAnswerWidget(question: question, initialAnswer: selectedOption);
  case 'essay':
    return EssayWidget(question: question, initialAnswer: selectedOption);
  default:
    return MCQTextWidget(question: question, selectedOption: selectedOption);
}
```

## Answer Storage

Each widget saves answers through the `PracticeViewModel`:

```dart
ref.read(practiceViewModelProvider.notifier)
   .answerQuestion(question.id, userAnswer);
```

- **MCQ/True-False**: Stores selected option as string
- **Short Answer/Essay**: Stores text input as string  
- **Drag-and-Drop**: Stores assignments as "targetId:dragItemId,targetId2:dragItemId2"

## Design Features

All widgets follow consistent design patterns:
- **App Colors**: Using the unified `AppColors` theme
- **Responsive**: Adapting to different screen sizes
- **Accessible**: Clear visual feedback and appropriate contrast
- **Error Handling**: Graceful fallbacks for missing data
- **LaTeX Support**: Mathematical expressions where needed

## Adding New Question Formats

To add a new question format:

1. Create new widget file in this directory
2. Follow the established pattern with `question` and answer parameters
3. Implement the `ConsumerWidget` or `ConsumerStatefulWidget`
4. Add the format case to `practice_screen.dart`
5. Update the `Question` model if new fields are needed

Each widget is self-contained and handles its own UI state and user interactions.
