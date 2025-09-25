# Firebase Functions Integration Documentation

## Overview

This document describes how Firebase Cloud Functions work in the Past Question Paper application and how they integrate with the Flutter frontend. The functions serve as the backend API for test generation and grading services.

## Architecture

```
Flutter App (Frontend)
    ↓ HTTPS Calls
Firebase Cloud Functions (Backend API)
    ↓ Firestore Queries
Firebase Firestore Database
```

## Available Functions

### 1. `generateTest` Function

**Location:** `functions/index.js:17-54`

**Purpose:** Generates customized test papers based on user parameters and exam blueprints.

#### Input Parameters
- `grade` (number, required): Student grade level (e.g., 10, 11, 12)
- `subject` (string, required): Subject code (e.g., "mathematics", "physics")
- `paper` (string, optional): Paper type (e.g., "p1", "p2")
- `year` (number, optional): Examination year
- `season` (string, optional): Exam season ("February", "May", "November")
- `topic` (string, optional): Specific topic for topic-based tests
- `mode` (string, optional): Test generation mode ("by_topic", "blueprint")

#### Response Format
```javascript
{
  questions: [
    {
      id: "question_id",
      questionText: "Question content...",
      format: "multipleChoice", // or "trueFalse", "dragAndDrop", etc.
      options: ["A", "B", "C", "D"], // for MCQ
      maxMarks: 2,
      questionNumber: 1,
      // ... other fields (correctAnswer excluded for security)
    }
  ],
  totalQuestions: 20,
  blueprint: { /* blueprint data */ },
  generatedAt: "2024-01-01T00:00:00.000Z"
}
```

#### Flutter Integration
**File:** `lib/repositories/question_repository.dart:30-103`

```dart
// Called from Flutter
final questions = await _questionRepository.generateTest({
  'grade': 12,
  'subject': 'mathematics',
  'paper': 'p1',
  'mode': 'blueprint'
});
```

**Usage in ViewModels:**
- `lib/viewmodels/testconfiguration_viewmodel.dart:40`
- `lib/views/test_configuration_screen.dart:45`

### 2. `gradeTest` Function

**Location:** `functions/index.js:60-97`

**Purpose:** Evaluates student answers and provides detailed grading results with statistics.

#### Input Parameters
- `submissions` (object, required): User answers keyed by question ID
- `userId` (string, optional): Authenticated user ID for result storage

#### Request Format
```javascript
{
  submissions: {
    "question_id_1": {
      answer: "A" // For MCQ
    },
    "question_id_2": {
      answers: ["step1", "step2", "step3"] // For drag-and-drop ordering
    }
  },
  userId: "user_authentication_id"
}
```

#### Response Format
```javascript
{
  results: [
    {
      questionId: "question_id",
      format: "multipleChoice",
      userAnswer: "A",
      correctAnswer: "B",
      isCorrect: false,
      marksAwarded: 0,
      maxMarks: 2
    }
  ],
  statistics: {
    totalQuestions: 20,
    correctQuestions: 15,
    totalMarks: 40,
    marksAwarded: 30,
    percentage: 75,
    grade: "B",
    accuracy: 75
  },
  gradedAt: "2024-01-01T00:00:00.000Z"
}
```

#### Flutter Integration
**File:** `lib/repositories/question_repository.dart:108-151`

```dart
// Called from Flutter
final gradingResults = await _questionRepository.gradeTest(
  userAnswers: userSubmissions,
  subject: 'mathematics',
  paper: 'p1'
);
```

**Usage in ViewModels:**
- `lib/viewmodels/practice_viewmodel.dart:129-133`

## Service Architecture

### Core Services

#### 1. Test Service (`functions/src/services/testService.js`)

**Key Functions:**
- `generateTestPaper()`: Main orchestrator for test generation
- `generateTopicBasedTest()`: Specialized for topic-focused tests
- `selectRandomQuestions()`: Implements seeded randomization
- `processQuestionsForFormat()`: Format-specific question processing

**Features:**
- Blueprint-compliant generation
- Fallback to legacy generation
- Topic-based filtering
- Seeded randomization for consistent results
- Format-specific processing (drag-and-drop, MCQ, etc.)

#### 2. Enhanced Test Service (`functions/src/services/enhancedTestService.js`)

**Advanced Features:**
- Knapsack-style question selection for precise marks allocation
- Topic-based marks distribution
- Cognitive level balancing
- Blueprint compliance reporting

#### 3. Grading Service (`functions/src/services/gradingService.js`)

**Supported Question Types:**

1. **Multiple Choice Questions**
   - Binary correct/incorrect marking
   - Standard marks allocation

2. **True/False Questions**
   - Boolean answer validation
   - Typically 1 mark per question

3. **Drag-and-Drop Questions**
   - **Matching Format**: Validates item-to-target mappings
   - **Ordering Format**: Implements South African step-based marking
     - Each correct step receives proportional marks
     - 50% threshold for overall correctness

4. **Fill-in-the-Blanks**
   - Multiple answer validation
   - Proportional marking per blank

**Step-Based Marking Example:**
```javascript
// For a 4-step ordering question worth 4 marks
// User gets steps 1, 3, 4 correct out of 4
{
  correctCount: 3,
  totalSteps: 4,
  marksPerStep: 1.0,
  marksAwarded: 3.0,
  percentage: 0.75,
  isCorrect: true // >= 50% threshold
}
```

#### 4. Database Service (`functions/src/services/databaseService.js`)

**Core Functions:**
- `buildQuestionQuery()`: Constructs Firestore queries
- `fetchBlueprint()`: Retrieves exam blueprints
- `executeQuestionQuery()`: Executes queries with validation
- `fetchQuestionsForGrading()`: Retrieves questions for grading
- `saveUserTestResults()`: Stores user test history

### Helper Services

#### 1. Validation (`functions/src/helpers/validation.js`)

**Functions:**
- `validateTestParams()`: Validates test generation parameters
- `validateGradingParams()`: Validates grading request data

#### 2. Data Helpers (`functions/src/helpers/dataHelpers.js`)

**Utility Functions:**
- `safeArray()`: Ensures array format with fallbacks
- `mapQuestionData()`: Transforms Firestore documents to question objects
- `normalizePaperFormat()`: Standardizes paper format strings

## Flutter-Functions Integration Flow

### Test Generation Flow

1. **User Input** → `TestConfigurationScreen`
2. **Parameters** → `TestConfigurationViewModel.generateTest()`
3. **Repository Call** → `QuestionRepository.generateTest()`
4. **Firebase Functions** → `generateTest` Cloud Function
5. **Database Query** → Firestore questions collection
6. **Blueprint Processing** → Question selection and formatting
7. **Response** → Sanitized questions (no correct answers)
8. **Navigation** → `PracticeScreen` with generated questions

### Test Grading Flow

1. **User Submission** → `PracticeScreen.submitTest()`
2. **Answer Collection** → `PracticeViewModel.submitTest()`
3. **Repository Call** → `QuestionRepository.gradeTest()`
4. **Firebase Functions** → `gradeTest` Cloud Function
5. **Question Retrieval** → Fetch original questions from Firestore
6. **Answer Validation** → Format-specific grading logic
7. **Statistics Calculation** → Overall performance metrics
8. **Response** → Detailed grading results and statistics
9. **Navigation** → `PracticeResultsScreen` with results

## Authentication & Security

### Authentication Requirements

- **generateTest**: Authentication temporarily disabled for testing
- **gradeTest**: Requires Firebase Authentication
- User ID automatically extracted from authentication context

### Security Measures

1. **Answer Sanitization**: Correct answers removed from test generation responses
2. **Input Validation**: All parameters validated before processing
3. **Error Handling**: Comprehensive error handling with user-friendly messages
4. **Rate Limiting**: Implicit through Firebase Functions quotas

## Error Handling

### Common Error Types

1. **`invalid-argument`**: Missing or invalid parameters
2. **`not-found`**: Blueprint or questions not found
3. **`unauthenticated`**: Authentication required but missing
4. **`internal`**: Unexpected server errors

### Flutter Error Handling

```dart
try {
  final questions = await generateTest(params);
} on FirebaseFunctionsException catch (e) {
  if (e.code == 'unauthenticated') {
    // Handle authentication error
  } else if (e.code == 'not-found') {
    // Handle missing data
  }
  // Display user-friendly error message
}
```

## Development & Testing

### Local Development

1. **Firebase Emulator**: Functions can run locally using Firebase emulator
2. **Local Testing**: `QuestionRepository.loadLocalTestQuestions()` for offline testing
3. **Debug Mode**: Extensive console logging for debugging

### Testing Features

- **PQP Mode**: Special question chains for Past Question Paper format
- **Sprint Mode**: Timed individual question practice
- **Local JSON**: Test questions loaded from `test_questions_firestore.json`

## Performance Considerations

### Optimization Strategies

1. **Query Limits**: Default 50 questions limit with pool expansion
2. **Caching**: Firestore native caching for frequently accessed data
3. **Efficient Queries**: Indexed fields for fast filtering
4. **Knapsack Selection**: Optimized question selection algorithms
5. **Batch Operations**: Multiple questions processed in single calls

### Monitoring

- Console logging for debugging and monitoring
- User test results stored for analytics
- Error tracking through Firebase Functions logs

## Blueprint System

### Blueprint Structure

```javascript
{
  id: "mathematics_p1_gr12",
  totalMarks: 100,
  totalQuestions: 25,
  formats: [
    {
      format: "multipleChoice",
      questionCount: 15,
      marksPerQuestion: 2
    },
    {
      format: "dragAndDrop",
      questionCount: 5,
      marksPerQuestion: 4
    }
  ],
  topicDistribution: {
    "algebra": { marks: 30, percentage: 30 },
    "calculus": { marks: 40, percentage: 40 },
    "geometry": { marks: 30, percentage: 30 }
  }
}
```

### Blueprint Compliance

- Questions selected according to blueprint specifications
- Marks distribution validated
- Topic coverage ensured
- Format requirements met
- Compliance reporting generated

## Future Enhancements

### Planned Features

1. **AI-Powered Question Generation**: Automatic question creation
2. **Adaptive Testing**: Difficulty adjustment based on performance
3. **Enhanced Analytics**: Detailed performance tracking
4. **Collaboration Features**: Shared tests and results
5. **Offline Support**: Local question storage and sync

### Scalability Considerations

1. **Database Sharding**: Questions partitioned by subject/grade
2. **CDN Integration**: Image and media content delivery
3. **Caching Layers**: Redis for frequently accessed data
4. **Load Balancing**: Multiple function instances
5. **Background Processing**: Queue-based heavy operations

---

*This documentation reflects the current state of the Firebase Functions integration. For the most up-to-date information, refer to the source code in the functions directory.*