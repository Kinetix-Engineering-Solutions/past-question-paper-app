# Exponential Function Chain - Database Simulation

## Overview
This document simulates the database structure and implementation for the exponential function question chain (4.5, 4.6, 4.7) based on the provided screenshots, following the PQP vs Sprint dual-mode architecture.

## Database Structure Simulation


### Question 4.5: Function Transformation
```json
{
  "questionId": "math_g12_func_transform_001",
  "availableInModes": ["pqp", "sprint"],
  
  "pqpData": {
    "paper": "p1",
    "season": "November",
    "year": 2023,
    "questionNumber": "4.5",
    "dependsOn": ["math_g12_asymptote_exp_001"], // Needs understanding of f(x)
    "questionText": "Write down the equation of g if it is given that g(x) = f(x) + 4",
    "marks": 1,
    "partOfChain": true,
    "chainId": "exponential_functions_nov_2023_p1"
  },
  
  "sprintData": {
    "questionText": "Given that f(x) = 2^x - 4, write down the equation of g if it is given that g(x) = f(x) + 4",
    "providedContext": {
      "f(x)": "2^x - 4",
      "transformation": "g(x) = f(x) + 4",
      "context": "Function transformation - vertical shift"
    },
    "marks": 2,
    "canRandomize": true,
    "difficulty": "easy",
    "estimatedTime": 2,
    "tags": ["function_transformations", "exponential_functions", "vertical_shifts"]
  },
  
  "commonData": {
    "correctAnswer": {
      "answer": "g(x) = 2^x",
      "caseSensitive": false,
      "variations": [
        "g(x) = 2^x",
        "g(x)=2^x", 
        "y = 2^x",
        "g(x) = 2^x",
        "2^x"
      ]
    },
    "answerType": "equation",
    "grade": 12,
    "subject": "mathematics",
    "topic": "exponential_functions",
    "cognitiveLevel": "Level 1",
    "workingSteps": [
      "Given: g(x) = f(x) + 4",
      "Given: f(x) = 2^x - 4", 
      "Substitute: g(x) = (2^x - 4) + 4",
      "Simplify: g(x) = 2^x - 4 + 4",
      "Therefore: g(x) = 2^x"
    ],
    "hints": [
      "Substitute f(x) = 2^x - 4 into g(x) = f(x) + 4",
      "Simplify the expression by combining like terms"
    ]
  }
}
```

### Question 4.6: Inverse Function Domain
```json
{
  "questionId": "math_g12_inverse_domain_001", 
  "availableInModes": ["pqp", "sprint"],
  
  "pqpData": {
    "paper": "p1",
    "season": "November",
    "year": 2023,
    "questionNumber": "4.6",
    "dependsOn": ["math_g12_func_transform_001"], // Needs g(x) from 4.5
    "questionText": "Write down the domain of g^(-1).",
    "marks": 2,
    "partOfChain": true,
    "chainId": "exponential_functions_nov_2023_p1"
  },
  
  "sprintData": {
    "questionText": "Given that g(x) = 2^x, write down the domain of g^(-1).",
    "providedContext": {
      "g(x)": "2^x",
      "derivedFrom": "g(x) = f(x) + 4 where f(x) = 2^x - 4",
      "concept": "Domain of inverse = Range of original function"
    },
    "marks": 3,
    "canRandomize": true,
    "difficulty": "medium",
    "estimatedTime": 3,
    "tags": ["inverse_functions", "exponential_functions", "domain_range"]
  },
  
  "commonData": {
    "correctAnswer": {
      "answer": "x ∈ (0; ∞)",
      "caseSensitive": false,
      "variations": [
        "x ∈ (0; ∞)",
        "(0; ∞)",
        "x > 0",
        "(0, ∞)",
        "0 < x < ∞",
        "x ∈ (0, ∞)",
        "{x | x > 0}"
      ]
    },
    "answerType": "domain_range",
    "grade": 12,
    "subject": "mathematics", 
    "topic": "inverse_functions",
    "cognitiveLevel": "Level 2",
    "workingSteps": [
      "From 4.5: g(x) = 2^x",
      "Domain of g^(-1) = Range of g",
      "Range of g(x) = 2^x is all positive real numbers",
      "Therefore: Domain of g^(-1) is x ∈ (0; ∞)"
    ],
    "hints": [
      "Domain of inverse function = Range of original function",
      "What values can g(x) = 2^x produce?",
      "Exponential functions with positive base have range (0; ∞)"
    ]
  }
}
```

### Question 4.7: Inverse Function Equation
```json
{
  "questionId": "math_g12_inverse_equation_001",
  "availableInModes": ["pqp", "sprint"],
  
  "pqpData": {
    "paper": "p1", 
    "season": "November",
    "year": 2023,
    "questionNumber": "4.7",
    "dependsOn": ["math_g12_func_transform_001", "math_g12_inverse_domain_001"], // Needs g(x) and understanding of inverse
    "questionText": "Write down the equation of g^(-1) in the form y = ...",
    "marks": 2,
    "partOfChain": true,
    "chainId": "exponential_functions_nov_2023_p1"
  },
  
  "sprintData": {
    "questionText": "Given that g(x) = 2^x, write down the equation of g^(-1) in the form y = ...",
    "providedContext": {
      "g(x)": "2^x",
      "domain_of_inverse": "x ∈ (0; ∞)",
      "form_required": "y = ...",
      "concept": "Inverse of exponential is logarithmic"
    },
    "marks": 3,
    "canRandomize": true,
    "difficulty": "medium", 
    "estimatedTime": 4,
    "tags": ["inverse_functions", "exponential_functions", "logarithms"]
  },
  
  "commonData": {
    "correctAnswer": {
      "answer": "y = log₂(x)",
      "caseSensitive": false,
      "variations": [
        "y = log₂(x)",
        "y = log_2(x)",
        "y=log₂(x)",
        "y = log₂x",
        "y = log_2 x",
        "g^(-1)(x) = log₂(x)",
        "f^(-1)(x) = log₂(x)"
      ]
    },
    "answerType": "equation",
    "grade": 12,
    "subject": "mathematics",
    "topic": "inverse_functions",
    "cognitiveLevel": "Level 2",
    "workingSteps": [
      "From 4.5: g(x) = 2^x",
      "To find inverse, let y = g(x)",
      "y = 2^x",
      "Solve for x: x = log₂(y)",
      "Interchange x and y: y = log₂(x)",
      "Therefore: g^(-1)(x) = log₂(x) or y = log₂(x)"
    ],
    "hints": [
      "Start with y = 2^x and solve for x",
      "Use logarithms to solve exponential equations", 
      "The inverse of 2^x is log₂(x)"
    ]
  }
}
```

## Implementation Tasks

### Phase 1: Database Setup
- [ ] **Task 1.1**: Create question chain document in Firestore
- [ ] **Task 1.2**: Create individual question documents (4.5, 4.6, 4.7)
- [ ] **Task 1.3**: Set up proper indexing for query optimization
- [ ] **Task 1.4**: Upload context image to Firebase Storage

### Phase 2: Repository Updates
- [ ] **Task 2.1**: Update QuestionRepository to handle exponential function questions
- [ ] **Task 2.2**: Implement PQP mode chain fetching for this question set
- [ ] **Task 2.3**: Implement Sprint mode individual question fetching
- [ ] **Task 2.4**: Add validation for equation and domain_range answer types

### Phase 3: Answer Validation Enhancement
- [ ] **Task 3.1**: Enhance equation validation for exponential functions
```dart
static bool _validateExponentialEquation(String userAnswer, CorrectAnswer correctAnswer) {
  // Handle g(x) = 2^x, y = 2^x, 2^x variations
  String normalized = userAnswer.replaceAll(RegExp(r'[gs]\(x\)\s*=\s*|y\s*=\s*'), '').trim();
  
  for (String variation in correctAnswer.variations) {
    String normalizedVariation = variation.replaceAll(RegExp(r'[gs]\(x\)\s*=\s*|y\s*=\s*'), '').trim();
    if (normalized.toLowerCase() == normalizedVariation.toLowerCase()) {
      return true;
    }
  }
  return false;
}
```

- [ ] **Task 3.2**: Enhance domain/range validation for interval notation
```dart
static bool _validateDomainRange(String userAnswer, CorrectAnswer correctAnswer) {
  // Handle (0; ∞), (0, ∞), x > 0, etc.
  String normalized = userAnswer
      .replaceAll(RegExp(r'x\s*∈\s*'), '')
      .replaceAll(RegExp(r'\{x\s*\|\s*|\}'), '')
      .trim();
  
  return correctAnswer.variations.any((variation) => 
      _compareIntervalNotations(normalized, variation));
}
```

- [ ] **Task 3.3**: Add logarithm validation for question 4.7
```dart
static bool _validateLogarithmEquation(String userAnswer, CorrectAnswer correctAnswer) {
  // Handle log₂(x), log_2(x), log2(x) variations
  String normalized = userAnswer
      .replaceAll('₂', '2')
      .replaceAll('_2', '2')
      .replaceAll(RegExp(r'\s'), '');
  
  return correctAnswer.variations.any((variation) => 
      normalized.toLowerCase().contains(variation.toLowerCase()));
}
```

### Phase 4: UI Implementation
- [ ] **Task 4.1**: Create shared context display widget
```dart
class SharedContextWidget extends StatelessWidget {
  final Map<String, dynamic> sharedContext;
  
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sharedContext['contextText']),
            if (sharedContext['contextImage'] != null)
              Image.network(sharedContext['contextImage']),
            // Display key functions and points
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Task 4.2**: Update question display for dependency indicators
```dart
class DependencyIndicator extends StatelessWidget {
  final List<String> dependsOn;
  final Map<String, String> previousAnswers;
  
  // Show which previous answers are needed/available
}
```

- [ ] **Task 4.3**: Implement progressive question unlocking for PQP mode
- [ ] **Task 4.4**: Add context provision display for Sprint mode

### Phase 5: Testing Scenarios

#### PQP Mode Testing
- [ ] **Test 5.1**: Load complete question chain (4.1-4.7)
- [ ] **Test 5.2**: Verify question dependencies work correctly
- [ ] **Test 5.3**: Test answer propagation from 4.5 to 4.6 and 4.7
- [ ] **Test 5.4**: Verify shared context displays properly

#### Sprint Mode Testing  
- [ ] **Test 5.5**: Load individual questions with provided context
- [ ] **Test 5.6**: Verify higher mark allocation for standalone questions
- [ ] **Test 5.7**: Test randomization doesn't break question integrity
- [ ] **Test 5.8**: Verify provided context is sufficient for solving

#### Answer Validation Testing
- [ ] **Test 5.9**: Test g(x) = 2^x variations acceptance
- [ ] **Test 5.10**: Test domain notation variations (x ∈ (0; ∞), x > 0, etc.)
- [ ] **Test 5.11**: Test logarithm notation variations (log₂(x), log_2(x), etc.)
- [ ] **Test 5.12**: Test case insensitivity and spacing tolerance

### Phase 6: Cloud Functions Update
- [ ] **Task 6.1**: Update generateTest function to handle question chains
```javascript
async function generatePQPTest({ paper, season, year }) {
  const chainDoc = await admin.firestore()
    .collection('question_chains')
    .where('paper', '==', paper)
    .where('season', '==', season)
    .where('year', '==', year)
    .limit(1)
    .get();
    
  if (chainDoc.empty) {
    throw new functions.https.HttpsError('not-found', 'Paper not found');
  }
  
  const chainData = chainDoc.docs[0].data();
  const questions = [];
  
  // Fetch questions in sequence order
  for (const questionRef of chainData.questions) {
    const questionDoc = await admin.firestore()
      .collection('questions')
      .doc(questionRef.questionId)
      .get();
      
    if (questionDoc.exists) {
      const questionData = questionDoc.data();
      questions.push({
        ...questionData.commonData,
        ...questionData.pqpData,
        questionId: questionData.questionId,
        sharedContext: chainData.sharedContext
      });
    }
  }
  
  return { questions, sharedContext: chainData.sharedContext };
}
```

- [ ] **Task 6.2**: Update Sprint mode generation to handle exponential functions
- [ ] **Task 6.3**: Add proper error handling for missing dependencies

## Expected Outcomes

After completing these tasks, the system should be able to:

1. **PQP Mode**: 
   - Display questions 4.5, 4.6, 4.7 in sequence
   - Show shared context (graph image and function definition)
   - Handle dependencies correctly (4.6 uses answer from 4.5)
   - Award standard marks as per original paper

2. **Sprint Mode**:
   - Present each question with sufficient context to solve independently
   - Award higher marks for standalone context provision
   - Allow randomized selection without breaking mathematical logic

3. **Answer Validation**:
   - Accept multiple formats for exponential equations
   - Handle various domain notation styles
   - Validate logarithmic expressions correctly

4. **User Experience**:
   - Seamless transition between question modes
   - Clear indication of provided vs required context
   - Proper mathematical notation display

## Database Size Impact
- 3 new question documents
- 1 question chain document  
- Shared image asset (~50KB)
- Total storage impact: ~5KB text + 50KB image

This simulation demonstrates how the dual-mode architecture effectively handles complex mathematical question sequences while maintaining flexibility for both exam-style and practice scenarios.