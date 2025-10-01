# PQP Data and Sprint Data Explained
## Understanding Dual-Mode Question Structure

Last Updated: October 1, 2025

---

## 🎯 Overview: Why Two Data Structures?

Your application supports **two different practice modes** for students:

1. **PQP Mode** (Past Question Paper Mode) - Authentic exam simulation
2. **Sprint Mode** - Quick practice with hints and scaffolding

The same question can be used differently in each mode, so it needs **mode-specific data**.

### Visual Comparison

```
┌─────────────────────────────────────────────────────────────┐
│                    SAME BASE QUESTION                        │
│  "What is the equation of g if g(x) = f(x) + 4?"            │
└─────────────────────────────────────────────────────────────┘
                            │
            ┌───────────────┴───────────────┐
            │                               │
    ┌───────▼─────────┐         ┌──────────▼──────────┐
    │   PQP MODE      │         │   SPRINT MODE       │
    │   (Exam-like)   │         │   (Practice)        │
    └─────────────────┘         └─────────────────────┘
            │                               │
    ┌───────▼─────────┐         ┌──────────▼──────────┐
    │ Sparse context  │         │ Rich context        │
    │ 1 mark          │         │ 2 marks             │
    │ Depends on Q4.4 │         │ Self-contained      │
    │ Question 4.5    │         │ Has hints           │
    │ Part of chain   │         │ Provides f(x)       │
    └─────────────────┘         └─────────────────────┘
```

---

## 📚 PQP Data (Past Question Paper Data)

### Purpose
Stores information specific to how the question appears in an **actual past exam paper**.

### Characteristics
- ✅ **Exam-authentic**: Question wording exactly as it appeared in the paper
- ✅ **Minimal context**: Assumes student has seen previous questions
- ✅ **Question chains**: Questions depend on each other (e.g., 4.5 depends on 4.4)
- ✅ **Original numbering**: Uses actual exam question numbers (e.g., "4.5", "2.1.1")
- ✅ **Sequential**: Must be attempted in order within a chain

### Structure

```javascript
"pqpData": {
  // === Exam Metadata ===
  "paper": "p1",                    // Which paper (p1, p2, p3)
  "season": "November",             // When exam was written
  "year": 2023,                     // Year of exam
  
  // === Question Identity ===
  "questionNumber": "4.5",          // Original exam question number
  
  // === Question Relationships ===
  "dependsOn": [                    // Array of question IDs this depends on
    "math_g12_asymptote_exp_001"    // Student must have seen Q4.4 first
  ],
  "partOfChain": true,              // Is this part of a question chain?
  "chainId": "exponential_functions_nov_2023_p1",  // Chain identifier
  
  // === Content ===
  "questionText": "Write down the equation of g if it is given that g(x) = f(x) + 4",
  // ⚠️ Note: Assumes student knows what f(x) is from previous question
  
  // === Marking ===
  "marks": 1                        // Original marks allocated in exam
}
```

### Real-World Example

```javascript
// Question 4.4 (First in chain)
{
  "questionId": "math_g12_asymptote_exp_001",
  "pqpData": {
    "paper": "p1",
    "season": "November",
    "year": 2023,
    "questionNumber": "4.4",
    "questionText": "Given f(x) = 2^x - 4. Write down the equation of the asymptote of f.",
    "marks": 1,
    "partOfChain": true,
    "chainId": "exponential_functions_nov_2023_p1",
    "dependsOn": []  // First question in chain - no dependencies
  }
}

// Question 4.5 (Depends on 4.4)
{
  "questionId": "math_g12_func_transform_001",
  "pqpData": {
    "paper": "p1",
    "season": "November",
    "year": 2023,
    "questionNumber": "4.5",
    "questionText": "Write down the equation of g if g(x) = f(x) + 4",
    // ☝️ Assumes student knows f(x) = 2^x - 4 from Q4.4
    "marks": 1,
    "partOfChain": true,
    "chainId": "exponential_functions_nov_2023_p1",
    "dependsOn": ["math_g12_asymptote_exp_001"]  // Must see Q4.4 first
  }
}

// Question 4.6 (Depends on 4.5)
{
  "questionId": "math_g12_inverse_domain_002",
  "pqpData": {
    "paper": "p1",
    "season": "November",
    "year": 2023,
    "questionNumber": "4.6",
    "questionText": "Write down the domain of g^(-1).",
    // ☝️ Assumes student knows g(x) = 2^x from Q4.5
    "marks": 2,
    "partOfChain": true,
    "chainId": "exponential_functions_nov_2023_p1",
    "dependsOn": ["math_g12_func_transform_001"]  // Must see Q4.5 first
  }
}
```

### Chain Structure Visualization

```
┌──────────────────────────────────────────────────────────┐
│  Chain ID: exponential_functions_nov_2023_p1             │
└──────────────────────────────────────────────────────────┘
           │
    ┌──────┴──────┬──────────┬──────────┐
    │             │          │          │
┌───▼────┐  ┌────▼────┐  ┌──▼─────┐  ┌▼────────┐
│  4.4   │  │   4.5   │  │  4.6   │  │  4.7    │
│ (base) │─→│(uses f) │─→│(uses g)│─→│(uses g⁻¹)│
└────────┘  └─────────┘  └────────┘  └─────────┘
  1 mark      1 mark       2 marks     3 marks
```

### Use Cases for PQP Mode

1. **Full Exam Practice**
   ```javascript
   // Student selects: "November 2023 Paper 1"
   const params = {
     mode: 'pqp',
     year: 2023,
     season: 'November',
     paper: 'p1'
   };
   // Returns: Complete paper with question chains preserved
   ```

2. **Specific Chain Practice**
   ```javascript
   // Student wants to practice exponential function chains
   const params = {
     mode: 'pqp',
     chainId: 'exponential_functions_nov_2023_p1'
   };
   // Returns: Questions 4.4, 4.5, 4.6, 4.7 in order
   ```

3. **Dependency Resolution**
   ```javascript
   // When displaying Q4.6, system checks:
   if (question.pqpData.dependsOn.length > 0) {
     // Ensure previous questions in chain were answered
     // Display chain indicator in UI
     // Show: "This question depends on Q4.5"
   }
   ```

---

## 🏃 Sprint Data (Quick Practice Data)

### Purpose
Stores information for **standalone practice** with enhanced learning support.

### Characteristics
- ✅ **Self-contained**: All context provided in the question
- ✅ **Rich context**: Includes formulas, definitions, background info
- ✅ **Hints available**: Can show hints if student is stuck
- ✅ **Difficulty-based**: Tagged with easy/medium/hard
- ✅ **Time-estimated**: Suggests how long to spend
- ✅ **Randomizable**: Can be presented in any order

### Structure

```javascript
"sprintData": {
  // === Content (Self-contained) ===
  "questionText": "Given that f(x) = 2^x - 4, write down the equation of g if g(x) = f(x) + 4",
  // ☝️ Provides f(x) definition - student doesn't need previous questions
  
  // === Context Information ===
  "providedContext": {
    "f(x)": "2^x - 4",              // Given function
    "transformation": "g(x) = f(x) + 4",  // Transformation rule
    "context": "Function transformation - vertical shift"  // Conceptual hint
  },
  
  // === Learning Metadata ===
  "marks": 2,                       // May differ from PQP marks
  "difficulty": "easy",             // easy | medium | hard
  "estimatedTime": 2,               // Minutes to solve
  "canRandomize": true,             // Can appear in random order
  
  // === Categorization ===
  "tags": [                         // Multiple tags for filtering
    "function_transformations",
    "exponential_functions",
    "vertical_shifts"
  ]
}
```

### Real-World Example

```javascript
// Same question as PQP 4.5, but self-contained for Sprint
{
  "questionId": "math_g12_func_transform_001",
  "sprintData": {
    "questionText": "Given that f(x) = 2^x - 4, write down the equation of g if it is given that g(x) = f(x) + 4",
    // ☝️ Includes f(x) definition - no need for previous question
    
    "providedContext": {
      "f(x)": "2^x - 4",
      "transformation": "g(x) = f(x) + 4",
      "context": "Function transformation - vertical shift",
      "concept": "When we add a constant to f(x), we shift the graph vertically"
    },
    
    "marks": 2,  // Slightly higher marks in Sprint mode for full working
    "canRandomize": true,  // Can appear anywhere in Sprint test
    "difficulty": "easy",
    "estimatedTime": 2,  // 2 minutes
    
    "tags": [
      "function_transformations",
      "exponential_functions", 
      "vertical_shifts",
      "algebra"
    ]
  },
  
  // Also has hints (not in pqpData)
  "hints": [
    "Substitute f(x) = 2^x - 4 into g(x) = f(x) + 4",
    "Simplify the expression by combining like terms",
    "Remember: -4 + 4 = 0"
  ]
}
```

### Sprint Mode Features

```javascript
// When student is in Sprint mode and stuck:
if (isSprintMode && showHints) {
  displayHints(question.hints);  // Show progressive hints
  displayContext(question.sprintData.providedContext);  // Show context box
}

// Sprint mode UI shows:
┌─────────────────────────────────────────────────┐
│ 📝 Provided Context:                            │
│ • f(x) = 2^x - 4                                │
│ • Transformation: g(x) = f(x) + 4               │
│ • Concept: Vertical shift                       │
├─────────────────────────────────────────────────┤
│ Question:                                       │
│ Write down the equation of g...                 │
├─────────────────────────────────────────────────┤
│ Difficulty: 🟢 Easy | Time: ⏱️ 2 mins          │
│ [💡 Show Hints]                                 │
└─────────────────────────────────────────────────┘
```

### Use Cases for Sprint Mode

1. **Quick Practice by Difficulty**
   ```javascript
   // Student wants easy warm-up questions
   const params = {
     mode: 'sprint',
     difficulty: 'easy',
     limit: 10
   };
   // Returns: 10 easy questions in random order
   ```

2. **Topic-Specific Practice**
   ```javascript
   // Student struggling with function transformations
   const params = {
     mode: 'sprint',
     tags: ['function_transformations'],
     limit: 15
   };
   // Returns: All questions tagged with transformations
   ```

3. **Timed Practice Sessions**
   ```javascript
   // Student has 15 minutes
   const params = {
     mode: 'sprint',
     duration: 15  // minutes
   };
   // System calculates: Find questions where sum(estimatedTime) ≈ 15
   // Returns: Mix of questions totaling ~15 minutes
   ```

---

## 🔄 Comparison: Same Question, Two Modes

### Example: Inverse Domain Question

#### PQP Version (Exam-Authentic)
```javascript
{
  "pqpData": {
    "questionNumber": "4.6",
    "questionText": "Write down the domain of g^(-1).",
    // ⚠️ Assumes you know g(x) = 2^x from Q4.5
    "marks": 2,
    "dependsOn": ["math_g12_func_transform_001"]
  }
}
```

**Display in PQP Mode:**
```
┌────────────────────────────────────────┐
│ 🔗 Question 4.6 (depends on Q4.5)      │
├────────────────────────────────────────┤
│ Write down the domain of g^(-1).      │
│                                        │
│ Marks: [2]                             │
└────────────────────────────────────────┘
```

#### Sprint Version (Self-Contained)
```javascript
{
  "sprintData": {
    "questionText": "Given that g(x) = 2^x, write down the domain of g^(-1).",
    // ✅ Provides g(x) definition
    "providedContext": {
      "g(x)": "2^x",
      "derivedFrom": "g(x) = f(x) + 4 where f(x) = 2^x - 4",
      "concept": "Domain of inverse = Range of original function"
    },
    "marks": 3,  // More marks in Sprint for showing working
    "difficulty": "medium",
    "estimatedTime": 3,
    "tags": ["inverse_functions", "domain_range"]
  },
  "hints": [
    "Remember: Domain of g^(-1) = Range of g",
    "What values can 2^x produce?",
    "Exponential functions with base > 1 produce only positive outputs"
  ]
}
```

**Display in Sprint Mode:**
```
┌──────────────────────────────────────────────┐
│ 📋 Provided Context:                         │
│ • g(x) = 2^x                                 │
│ • Derived from: f(x) = 2^x - 4, g = f + 4   │
│ • Key concept: Domain(g⁻¹) = Range(g)       │
├──────────────────────────────────────────────┤
│ Given that g(x) = 2^x, write down the       │
│ domain of g^(-1).                            │
├──────────────────────────────────────────────┤
│ Difficulty: 🟡 Medium | ⏱️ 3 mins           │
│ Marks: [3]                                   │
│ [💡 Show Hints] [📚 Show Working Steps]     │
└──────────────────────────────────────────────┘
```

---

## 📊 Data Field Comparison Table

| Field | PQP Data | Sprint Data | Purpose |
|-------|----------|-------------|---------|
| **questionText** | Sparse context | Rich context | PQP: Exam-authentic<br>Sprint: Self-contained |
| **marks** | Original exam marks | May differ | Sprint may award more for working |
| **paper** | ✅ Yes | ❌ No | PQP tracks which paper |
| **year** | ✅ Yes | ❌ No | PQP tracks which year |
| **season** | ✅ Yes | ❌ No | PQP tracks which season |
| **questionNumber** | ✅ Yes (e.g., "4.5") | ❌ No | PQP uses original numbering |
| **dependsOn** | ✅ Yes | ❌ No | PQP has question chains |
| **partOfChain** | ✅ Yes | ❌ No | PQP tracks chain membership |
| **chainId** | ✅ Yes | ❌ No | PQP groups questions |
| **providedContext** | ❌ No | ✅ Yes | Sprint provides background |
| **difficulty** | ❌ No | ✅ Yes | Sprint categorizes by level |
| **estimatedTime** | ❌ No | ✅ Yes | Sprint estimates duration |
| **tags** | ❌ No | ✅ Yes | Sprint enables filtering |
| **canRandomize** | ❌ No | ✅ Yes | Sprint allows shuffling |

---

## 🎮 How Modes Are Selected

### In Client (Flutter App)

```dart
// test_configuration_screen.dart

// User selects mode via tabs
TabBarView(
  children: [
    _FullExamView(),      // Uses PQP mode
    _QuickPracticeView(), // Uses Sprint mode
    _ByTopicView(),       // Uses Sprint mode
  ],
)

// Full Exam = PQP Mode
void startFullExam() {
  final params = {
    'mode': 'full_exam',  // → Backend uses pqpData
    'year': _selectedYear,
    'season': _selectedSeason,
    'paper': 'p1'
  };
  generateTest(params);
}

// Quick Practice = Sprint Mode
void startQuickPractice() {
  final params = {
    'mode': 'quick_practice',  // → Backend uses sprintData
    'duration': 15,
    // No year/season - mixes all
  };
  generateTest(params);
}
```

### In Backend (Cloud Functions)

```javascript
// testService.js

async function generateTestPaper(params) {
  const { mode } = params;
  
  // Determine which data to extract from questions
  if (mode === 'full_exam' || mode === 'pqp') {
    // Use pqpData fields
    return questions.map(q => ({
      questionText: q.pqpData?.questionText || q.questionText,
      marks: q.pqpData?.marks || q.marks,
      questionNumber: q.pqpData?.questionNumber,
      chainId: q.pqpData?.chainId,
      dependsOn: q.pqpData?.dependsOn || []
    }));
  } 
  else if (mode === 'quick_practice' || mode === 'sprint') {
    // Use sprintData fields
    return questions.map(q => ({
      questionText: q.sprintData?.questionText || q.questionText,
      marks: q.sprintData?.marks || q.marks,
      difficulty: q.sprintData?.difficulty,
      providedContext: q.sprintData?.providedContext,
      hints: q.hints || []
    }));
  }
}
```

---

## 🎯 Why Have Both?

### Problem Without Mode-Specific Data

```javascript
// WITHOUT mode-specific data (bad approach):
{
  "questionText": "Write down the domain of g^(-1).",
  "marks": 2
}

// Issues:
// ❌ PQP users confused: "What is g? Was that in a previous question?"
// ❌ Sprint users confused: "I don't have enough information!"
// ❌ Can't support question chains
// ❌ Can't provide helpful context
```

### Solution With Mode-Specific Data

```javascript
// WITH mode-specific data (good approach):
{
  "availableInModes": ["pqp", "sprint"],
  
  "pqpData": {
    "questionText": "Write down the domain of g^(-1).",
    "dependsOn": ["previous_question_id"]  // Assumes context from chain
  },
  
  "sprintData": {
    "questionText": "Given g(x) = 2^x, write down the domain of g^(-1).",
    "providedContext": { "g(x)": "2^x" }  // Self-contained
  }
}

// Benefits:
// ✅ PQP users get authentic exam experience
// ✅ Sprint users get all needed information
// ✅ Same question serves two purposes
// ✅ Reduces data duplication
```

---

## 🔧 Implementation in Your Code

### Question Model (Flutter)

```dart
// lib/model/question.dart

class Question {
  final String id;
  final String questionText;  // Default/fallback text
  
  // Mode support
  final List<String>? availableInModes;  // ["pqp", "sprint"]
  final PQPData? pqpData;
  final SprintData? sprintData;
  
  // Methods to get mode-specific text
  String getPQPQuestionText() {
    return pqpData?.questionText ?? questionText;
  }
  
  String getSprintQuestionText() {
    return sprintData?.questionText ?? questionText;
  }
  
  int getPQPMarks() {
    return pqpData?.marks ?? marks;
  }
  
  int getSprintMarks() {
    return sprintData?.marks ?? marks;
  }
}

class PQPData {
  final String? paper;
  final String? season;
  final int? year;
  final String? questionNumber;
  final List<String>? dependsOn;
  final String? questionText;
  final int? marks;
  final bool? partOfChain;
  final String? chainId;
}

class SprintData {
  final String? questionText;
  final Map<String, dynamic>? providedContext;
  final int? marks;
  final bool? canRandomize;
  final String? difficulty;
  final int? estimatedTime;
  final List<String>? tags;
}
```

### Usage in UI

```dart
// practice_screen.dart

Widget build(BuildContext context) {
  return ListView(
    children: [
      // Display question text based on mode
      LatexText(
        widget.isPQPMode 
          ? widget.question.getPQPQuestionText()
          : widget.isSprintMode
            ? widget.question.getSprintQuestionText()
            : widget.question.questionText
      ),
      
      // PQP Mode: Show chain info
      if (widget.isPQPMode && widget.question.isPartOfChain)
        Container(
          child: Column(
            children: [
              Text('Question Chain: ${widget.question.pqpData?.questionNumber}'),
              Text('Depends on: ${widget.question.dependencies.join(', ')}'),
              Text('Marks: ${widget.question.getPQPMarks()}'),
            ],
          ),
        ),
      
      // Sprint Mode: Show context and hints
      if (widget.isSprintMode && widget.question.providedContext != null)
        Container(
          child: Column(
            children: [
              Text('Provided Context:'),
              ...widget.question.providedContext!.entries.map(
                (entry) => Text('${entry.key}: ${entry.value}'),
              ),
              Text('Marks: ${widget.question.getSprintMarks()}'),
              Text('Difficulty: ${widget.question.difficulty}'),
            ],
          ),
        ),
    ],
  );
}
```

---

## 📝 Best Practices

### 1. Always Provide Both Modes
```javascript
// GOOD: Question available in both modes
{
  "availableInModes": ["pqp", "sprint"],
  "pqpData": { /* PQP fields */ },
  "sprintData": { /* Sprint fields */ }
}

// BAD: Question only in one mode
{
  "availableInModes": ["pqp"],
  "pqpData": { /* PQP fields */ }
  // Missing sprintData - can't use in Sprint mode
}
```

### 2. Make Sprint Self-Contained
```javascript
// GOOD: Sprint provides all context
"sprintData": {
  "questionText": "Given f(x) = 2^x - 4, find...",
  "providedContext": {
    "f(x)": "2^x - 4"
  }
}

// BAD: Sprint assumes previous knowledge
"sprintData": {
  "questionText": "Using f from the previous question, find..."
  // Student won't know what f is
}
```

### 3. Maintain Chain Integrity in PQP
```javascript
// GOOD: Chain dependencies tracked
{
  "pqpData": {
    "questionNumber": "4.6",
    "dependsOn": ["math_g12_func_transform_001"],  // Q4.5
    "chainId": "exp_func_nov_2023_p1"
  }
}

// BAD: Missing dependency info
{
  "pqpData": {
    "questionNumber": "4.6",
    // Missing dependsOn - breaks chain logic
  }
}
```

### 4. Different Marks Are OK
```javascript
// GOOD: Different marks for different contexts
{
  "pqpData": {
    "marks": 1  // Exam gave 1 mark for final answer only
  },
  "sprintData": {
    "marks": 3  // Sprint awards marks for working steps
  }
}
```

---

## 🎓 Summary

### PQP Data (Past Question Paper Mode)
- **Purpose**: Authentic exam simulation
- **Context**: Minimal (assumes question chain context)
- **Marks**: Original exam marks
- **Ordering**: Must follow exam sequence
- **Dependencies**: Tracks question chains
- **Use Case**: "I want to practice November 2023 Paper 1"

### Sprint Data (Quick Practice Mode)
- **Purpose**: Flexible learning practice
- **Context**: Rich (self-contained)
- **Marks**: May differ (awards working steps)
- **Ordering**: Can be randomized
- **Dependencies**: None (standalone)
- **Use Case**: "I want to practice function transformations for 15 minutes"

### Key Insight
**Same question, different presentations:**
- PQP = How it appeared in the actual exam
- Sprint = How it should be presented for effective practice

This dual-mode structure allows one question database to serve two different pedagogical purposes effectively! 🎯

