# Short Answer Questions Documentation

## Overview

The Past Question Paper application features a sophisticated short answer question system with dual-mode support (PQP and Sprint modes), advanced validation, and flexible grading capabilities. Short answer questions are text-based questions that require students to provide written responses ranging from single words to mathematical expressions.

## Database Structure

### JSON Schema (test_questions_firestore.json)

Short answer questions follow a comprehensive structure with dual-mode support:

```json
{
  "answerType": "equation",
  "availableInModes": ["pqp", "sprint"],
  "correctAnswer": {
    "answer": "g(x) = 2^x",
    "caseSensitive": false,
    "variations": [
      "g(x) = 2^x",
      "g(x)=2^x",
      "y = 2^x",
      "2^x"
    ]
  },
  "format": "short_answer",
  "grade": 12,
  "subject": "mathematics",
  "topic": "exponential_functions",
  "tolerance": 0.01,
  "hints": [
    "Substitute f(x) = 2^x - 4 into g(x) = f(x) + 4",
    "Simplify the expression by combining like terms"
  ],
  "workingSteps": [
    "Given: g(x) = f(x) + 4",
    "Given: f(x) = 2^x - 4",
    "Substitute: g(x) = (2^x - 4) + 4",
    "Simplify: g(x) = 2^x - 4 + 4",
    "Therefore: g(x) = 2^x"
  ],
  "pqpData": {
    "chainId": "exponential_functions_nov_2023_p1",
    "dependsOn": ["math_g12_asymptote_exp_001"],
    "marks": 1,
    "paper": "p1",
    "partOfChain": true,
    "questionImage": null,
    "questionNumber": "4.5",
    "questionText": "Write down the equation of g if it is given that g(x) = f(x) + 4",
    "season": "November",
    "year": 2023
  },
  "sprintData": {
    "canRandomize": true,
    "difficulty": "easy",
    "estimatedTime": 2,
    "marks": 2,
    "providedContext": {
      "f(x)": "2^x - 4",
      "context": "Function transformation - vertical shift",
      "transformation": "g(x) = f(x) + 4"
    },
    "questionImage": null,
    "questionText": "Given that f(x) = 2^x - 4, write down the equation of g if it is given that g(x) = f(x) + 4"
  }
}
```

### Key Fields Explained

#### Core Question Data
- **`questionId`**: Unique identifier following the pattern `{subject}_g{grade}_{topic}_{sequence}`
- **`questionType`** & **`format`**: Both set to `"short_answer"` for consistency
- **`availableInModes`**: Array indicating supported modes (`["pqp", "sprint"]`)

#### Answer Validation System
- **`correctAnswer`**: The primary correct answer
- **`answerVariations`**: Array of acceptable answer formats and variations
- **`caseSensitive`**: Boolean flag for case sensitivity (typically `false`)
- **`answerType`**: Classification of answer type:
  - `"equation"` - Mathematical equations (e.g., "g(x) = 2^x")
  - `"domain_range"` - Domain/range expressions (e.g., "x ∈ (0; ∞)")
  - `"coordinates"` - Coordinate points (e.g., "(3; 8)")
  - `"numerical"` - Numeric values (e.g., "1")
  - `"algebraic"` - Algebraic expressions

#### Enhanced Features
- **`tolerance`**: Numerical tolerance for approximate answers (for numerical types)
- **`units`**: Expected units for scientific/physics answers
- **`workingSteps`**: Step-by-step solution breakdown
- **`hints`**: Contextual hints for student assistance
- **`showWorking`**: Boolean indicating if working steps should be displayed

## Dual Mode System

### Mode Detection Algorithm

The system uses a sophisticated algorithm to distinguish between modes:

```dart
// From lib/model/question.dart:570-577
String getPQPQuestionText() {
  return pqpData?.questionText ?? questionText;
}

String getSprintQuestionText() {
  return sprintData?.questionText ?? questionText;
}
```

### PQP Mode (Past Question Papers)

**Characteristics:**
- **Chain Dependencies**: Questions are part of interconnected chains
- **Context-Dependent**: Relies on previous questions in the chain
- **Authentic Format**: Mirrors actual exam paper structure
- **Sequential Numbering**: Uses original question numbers (e.g., "4.5", "4.6")

**Key Fields:**
```json
"pqpData": {
  "paper": "p1",                    // Paper type (p1, p2, etc.)
  "season": "November",             // Exam session
  "year": 2023,                     // Exam year
  "questionNumber": "4.5",          // Original question number
  "dependsOn": ["previous_q_id"],   // Dependencies
  "partOfChain": true,              // Chain membership
  "chainId": "function_chain_id",   // Chain identifier
  "marks": 1                        // PQP-specific marks
}
```

**Context Resolution:**
- Questions reference answers from previous chain questions
- Minimal context provided (authentic exam experience)
- Dependencies tracked for proper question sequencing

### Sprint Mode (Practice Mode)

**Characteristics:**
- **Self-Contained**: Each question includes full context
- **Enhanced Context**: Additional explanations and setup
- **Flexible Timing**: Estimated completion times
- **Randomizable**: Can be shuffled and reused
- **Tagged**: Categorized for targeted practice

**Key Fields:**
```json
"sprintData": {
  "questionText": "Full self-contained question...",
  "providedContext": {
    "f(x)": "2^x - 4",              // Function definition
    "transformation": "g(x) = f(x) + 4",  // Operation
    "context": "Function transformation"    // Conceptual context
  },
  "marks": 2,                       // Sprint-specific marks
  "canRandomize": true,             // Randomization flag
  "difficulty": "easy",             // Difficulty level
  "estimatedTime": 2,               // Minutes
  "tags": ["transformations", "exponential"]  // Practice tags
}
```

**Context Enhancement:**
- All necessary information provided within the question
- `providedContext` object supplies missing background
- Enhanced explanations for standalone practice

## User Interface Implementation

### Short Answer Widget (`lib/widgets/question_formats/short_answer_widget.dart`)

**Features:**
- **Multi-line Text Input**: 3-line text field for extended answers
- **Real-time Validation**: Input updates stored immediately
- **Clear Functionality**: Quick clear button when text is present
- **Visual Feedback**: Color-coded borders and icons
- **Mark Display**: Shows question marks and guidance text

**Key Components:**
```dart
TextField(
  controller: _controller,
  maxLines: 3,
  minLines: 3,
  onChanged: (value) {
    ref.read(practiceViewModelProvider.notifier)
       .answerQuestion(widget.question.id, value);
  }
)
```

### Mode-Aware Display

The practice screen dynamically switches between modes:

```dart
// From lib/views/practice_screen.dart:354-357
LatexText(widget.isPQPMode
  ? widget.question.getPQPQuestionText()
  : widget.isSprintMode
    ? widget.question.getSprintQuestionText()
    : widget.question.questionText)
```

## Answer Processing & Validation

### Current State

**Important Note**: The Firebase Functions grading service (`functions/src/services/gradingService.js:284-309`) currently **does not have specific short answer grading logic implemented**. Short answer questions fall back to multiple choice grading, which is not suitable for text-based answers.

### Planned Grading Algorithm

Based on the database structure, the intended grading algorithm would include:

#### 1. Text Normalization
```javascript
function normalizeAnswer(answer, caseSensitive = false) {
  let normalized = answer.trim();
  if (!caseSensitive) {
    normalized = normalized.toLowerCase();
  }
  // Remove extra whitespace
  normalized = normalized.replace(/\s+/g, ' ');
  return normalized;
}
```

#### 2. Variation Matching
```javascript
function checkAnswerVariations(userAnswer, question) {
  const normalized = normalizeAnswer(userAnswer, question.caseSensitive);
  const variations = question.answerVariations || [question.correctAnswer];

  for (const variation of variations) {
    const normalizedVariation = normalizeAnswer(variation, question.caseSensitive);
    if (normalized === normalizedVariation) {
      return true;
    }
  }
  return false;
}
```

#### 3. Type-Specific Validation

**Numerical Answers:**
```javascript
function gradeNumerical(userAnswer, correctAnswer, tolerance = 0) {
  const userNum = parseFloat(userAnswer);
  const correctNum = parseFloat(correctAnswer);
  if (tolerance > 0) {
    return Math.abs(userNum - correctNum) <= tolerance;
  }
  return userNum === correctNum;
}
```

**Coordinate Answers:**
```javascript
function gradeCoordinates(userAnswer, correctAnswer) {
  // Extract coordinates from formats like "(3; 8)", "(3, 8)", "3, 8"
  const coordRegex = /\(?([+-]?\d+(?:\.\d+)?)[,;]\s*([+-]?\d+(?:\.\d+)?)\)?/;
  const userMatch = userAnswer.match(coordRegex);
  const correctMatch = correctAnswer.match(coordRegex);

  if (!userMatch || !correctMatch) return false;
  return userMatch[1] === correctMatch[1] && userMatch[2] === correctMatch[2];
}
```

## Question Loading & Repository Pattern

### Local Testing (`lib/repositories/question_repository.dart`)

The system supports three loading modes:

#### 1. General Questions
```dart
Future<List<Question>> loadLocalTestQuestions()
```
- Loads all questions from test_questions_firestore.json
- Converts JSON structure to Question objects
- Handles both mode data structures

#### 2. PQP Mode Filtering
```dart
Future<List<Question>> loadPQPQuestions({
  String? paper,
  String? season,
  int? year,
  String? chainId,
})
```
- Filters questions by `availableInModes` containing "pqp"
- Validates presence of `pqpData`
- Sorts by chain dependencies and question numbers
- Validates question chain integrity

#### 3. Sprint Mode Filtering
```dart
Future<List<Question>> loadSprintQuestions({
  String? difficulty,
  List<String>? tags,
})
```
- Filters questions by `availableInModes` containing "sprint"
- Validates presence of `sprintData`
- Applies difficulty and tag filters
- No dependency sorting (standalone questions)

### Question Chain Validation

For PQP mode, the system validates question dependencies:

```dart
void _validatePQPQuestionChains(List<Question> questions) {
  for (final question in questions) {
    if (question.dependencies.isNotEmpty) {
      for (final dependency in question.dependencies) {
        final dependentQuestion = questions.firstWhere(
          (q) => q.id == dependency,
          orElse: () => questions.first,
        );
        // Validation logic...
      }
    }
  }
}
```

## Answer Type Classification

### Supported Answer Types

1. **Equation** (`"equation"`)
   - Mathematical functions: `g(x) = 2^x`
   - Algebraic expressions: `y = mx + c`
   - Variations handle spacing and notation differences

2. **Domain/Range** (`"domain_range"`)
   - Interval notation: `x ∈ (0; ∞)`, `(0, ∞)`
   - Inequality format: `x > 0`
   - Set notation: `{x | x > 0}`

3. **Coordinates** (`"coordinates"`)
   - Point notation: `(3; 8)`, `(3, 8)`
   - Coordinate pairs: `3; 8`, `3, 8`
   - Named coordinates: `x = 3, y = 8`

4. **Numerical** (`"numerical"`)
   - Pure numbers: `1`, `3.14`
   - Scientific notation: `2.5e-3`
   - Tolerance-based matching for approximations

5. **Algebraic** (`"algebraic"`)
   - Complex expressions: `4(3x² + 2x - 1)³(6x + 2)`
   - Factored forms and equivalent representations
   - Order-independent matching

## Learning Support Features

### Working Steps
Each question includes detailed solution steps:
```json
"workingSteps": [
  "Given: g(x) = f(x) + 4",
  "Given: f(x) = 2^x - 4",
  "Substitute: g(x) = (2^x - 4) + 4",
  "Simplify: g(x) = 2^x - 4 + 4",
  "Therefore: g(x) = 2^x"
]
```

### Context-Aware Hints
Sprint mode provides intelligent hints based on question content:

```dart
// From lib/views/practice_screen.dart:475-501
List<String> _getHintsForQuestion() {
  if (widget.question.format.toLowerCase().contains('short')) {
    if (widget.question.questionText.toLowerCase().contains('equation')) {
      return [
        'Substitute the given function into the transformation equation',
        'Simplify by combining like terms',
        'Write your final answer in the form g(x) = ...',
      ];
    }
    // Additional hint logic for different question types...
  }
}
```

## Performance & Scalability

### Optimization Features

1. **Lazy Loading**: Questions loaded on-demand
2. **Mode Filtering**: Pre-filters questions by availability
3. **Efficient Parsing**: JSON structure optimized for quick access
4. **Caching**: Question objects cached in memory during sessions

### Storage Efficiency

- Shared base data with mode-specific overrides
- Compact JSON structure with minimal redundancy
- Efficient string storage for variations and hints

## Future Enhancements

### Planned Features

1. **Enhanced Grading Service**
   - Complete short answer grading implementation
   - Fuzzy matching for similar answers
   - Partial credit for partially correct answers

2. **AI-Powered Validation**
   - Semantic answer matching
   - Mathematical equivalence checking
   - Natural language processing for explanation grading

3. **Advanced Answer Types**
   - Chemical formulas
   - Programming code snippets
   - Mathematical proofs

4. **Adaptive Difficulty**
   - Dynamic hint adjustment based on performance
   - Progressive complexity in question chains

### Technical Debt

1. **Missing Grading Logic**: Short answer grading service needs implementation
2. **Answer Normalization**: Standardized text processing pipeline needed
3. **Unit Testing**: Comprehensive test coverage for answer validation
4. **Performance Optimization**: Large question set loading improvements

---

*The short answer system represents a sophisticated dual-mode question framework designed for authentic exam preparation and flexible practice. While the frontend implementation is complete, the backend grading service requires development to fully support text-based answer validation.*