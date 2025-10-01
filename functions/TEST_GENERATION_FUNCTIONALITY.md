# Test Generation Functionality Overview

## 📋 Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Entry Points](#entry-points)
3. [Test Generation Flow](#test-generation-flow)
4. [Blueprint System](#blueprint-system)
5. [Generation Strategies](#generation-strategies)
6. [Question Selection Logic](#question-selection-logic)
7. [Key Functions Explained](#key-functions-explained)
8. [Common Issues & Solutions](#common-issues--solutions)

---

## 🏗️ Architecture Overview

### File Structure
```
functions/
├── index.js                           # Main entry point (Cloud Functions)
└── src/
    ├── services/
    │   ├── testService.js             # Main orchestrator
    │   ├── enhancedTestService.js     # Blueprint-compliant generation
    │   ├── shortAnswerTestService.js  # Short answer specific logic
    │   ├── databaseService.js         # Firestore queries
    │   └── gradingService.js          # Grading logic
    └── helpers/
        ├── validation.js              # Parameter validation
        └── dataHelpers.js             # Data transformation utilities
```

---

## 🚪 Entry Points

### 1. Cloud Function: `generateTest`
**Location:** `functions/index.js`

**Purpose:** HTTP callable function that generates test papers based on parameters

**Flow:**
```javascript
Client Request
    ↓
generateTest (index.js)
    ↓
validateTestParams (validation.js)
    ↓
generateTestPaper (testService.js)
    ↓
[Various generation strategies]
    ↓
Sanitize & Return Questions
```

**Request Parameters:**
- `subject`: Subject name (e.g., "Mathematics")
- `paper`: Paper number (e.g., "Paper 1", "P1")
- `grade`: Grade level (e.g., 12)
- `year`: Optional year filter
- `season`: Optional season filter
- `topic`: Optional topic filter
- `mode`: Generation mode (`'by_topic'`, `'pqp'`, `'sprint'`)
- `format`: Question format (`'short_answer'`, `'MCQ'`, etc.)
- `questionCount`: Number of questions needed
- `seed`: Optional seed for deterministic randomness
- `excludeIds`: Array of question IDs to exclude
- `poolFactor`: Multiplier for sampling pool (default: 5)

**Response:**
```javascript
{
  questions: [...],        // Sanitized questions (no answers)
  totalQuestions: 20,
  blueprint: {...},        // Blueprint metadata
  generatedAt: "ISO-timestamp"
}
```

---

## 🔄 Test Generation Flow

### Main Decision Tree

```
generateTestPaper()
    │
    ├─── Is Short Answer? ──→ generateShortAnswerTest()
    │
    ├─── Is Topic-Based? ──→ generateTopicBasedTest()
    │
    └─── Blueprint-Based
            │
            ├─── Try Enhanced ──→ generateBlueprintCompliantTest()
            │        │
            │        ├── Success ──→ Return
            │        └── Failure ──→ Fallback
            │
            └─── Fallback ──→ generateLegacyTestPaper()
```

---

## 📐 Blueprint System

### Blueprint Structure

Blueprints define the structure and requirements for test papers.

**Location:** Firestore `blueprints` collection

**Document ID Format:**
```
{subject}_{paper}_gr{grade}

Examples:
- mathematics_paper_1_gr12
- physical_sciences_p1_gr12
```

**Blueprint Schema:**

#### New Format (Recommended):
```javascript
{
  subject: "Mathematics",
  paper: "Paper 1",
  grade: 12,
  totalMarks: 150,
  totalQuestions: 33,
  
  // Format-based structure
  formats: [
    {
      format: "MCQ",           // Question format
      questionCount: 20,       // How many questions
      marksPerQuestion: 2      // Marks per question
    },
    {
      format: "shortAnswer",
      questionCount: 10,
      marksPerQuestion: 5
    },
    {
      format: "dragAndDrop",
      questionCount: 3,
      marksPerQuestion: 10
    }
  ],
  
  // Topic distribution (for enhanced generation)
  topicDistribution: {
    "Algebra": {
      marks: 40,
      percentage: 26.67
    },
    "Calculus": {
      marks: 50,
      percentage: 33.33
    },
    // ...
  },
  
  // Cognitive level distribution
  cognitiveLevels: {
    "Level 1": 30,  // % of questions
    "Level 2": 40,
    "Level 3": 20,
    "Level 4": 10
  }
}
```

#### Legacy Format:
```javascript
{
  subject: "Mathematics",
  paper: "Paper 1",
  grade: 12,
  totalMarks: 150,
  totalQuestions: 33
  // No formats array - generates questions directly
}
```

---

## 🎯 Generation Strategies

### 1. **Enhanced Blueprint-Compliant Generation**
**File:** `enhancedTestService.js`

**When Used:**
- Default strategy for all blueprint-based tests
- Optimizes for topic and cognitive level distribution

**Key Features:**
- ✅ Respects blueprint topic distribution
- ✅ Maintains cognitive level balance
- ✅ Uses knapsack algorithm for marks optimization
- ✅ Provides compliance report

**Process:**
1. Fetch blueprint
2. For each topic in blueprint:
   - Calculate marks needed
   - Query questions for that topic
   - Use knapsack selection for precise marks
3. Balance cognitive levels across all topics
4. Validate compliance with blueprint
5. Generate compliance report

**Example:**
```javascript
// Blueprint says: Algebra needs 40 marks
// Algorithm:
// 1. Query 50 algebra questions (pool)
// 2. Select combination that totals ~40 marks (±15% tolerance)
// 3. Ensure variety in cognitive levels
// 4. Return selected questions
```

---

### 2. **Topic-Based Generation**
**File:** `testService.js` → `generateTopicBasedTest()`

**When Used:**
- `mode: 'by_topic'` parameter
- No blueprint required
- For focused topic practice

**Key Features:**
- ✅ No blueprint dependency
- ✅ Supports `excludeIds` (avoid repeating questions)
- ✅ Supports `seed` (deterministic randomness)
- ✅ Uses `poolFactor` for better sampling

**Process:**
1. Build query filtered by topic
2. Fetch questions (count × poolFactor)
3. Exclude previously seen questions
4. Random selection (with optional seed)
5. Return numbered questions

**Example:**
```javascript
// Request: Practice "Algebra" topic
// Parameters:
{
  subject: "Mathematics",
  grade: 12,
  paper: "Paper 1",
  mode: "by_topic",
  topic: "Algebra",
  questionCount: 10,
  excludeIds: ["q1", "q2"],  // Already seen
  poolFactor: 5,             // Sample from 50 questions
  seed: "user123_session5"   // Consistent shuffle
}
```

---

### 3. **Short Answer Generation**
**File:** `shortAnswerTestService.js`

**When Used:**
- `format: 'short_answer'` parameter
- Handles text/numeric answer validation

**Modes:**
- **PQP Mode:** Past paper practice with year/season
- **Sprint Mode:** Topic-focused practice

**Key Features:**
- ✅ Answer variation support
- ✅ Case sensitivity options
- ✅ Numeric tolerance handling
- ✅ Special grading logic

---

### 4. **Legacy Generation (Fallback)**
**File:** `testService.js` → `generateLegacyTestPaper()`

**When Used:**
- Enhanced generation fails
- Old blueprint format detected
- Simpler requirements

**Process:**
1. Fetch blueprint
2. Check if blueprint has `formats` array
   - **Yes:** Generate per format
   - **No:** Generate total questions directly
3. Random selection from query pool
4. Return numbered questions

---

## 🎲 Question Selection Logic

### Random Selection with Seeding

**Function:** `selectRandomQuestions(questionDocs, requiredCount, options)`

**Purpose:** Select N random questions from a pool

**Features:**
- Deterministic shuffle when seed provided
- Fisher-Yates shuffle algorithm
- Supports string or number seeds

**Example:**
```javascript
// Without seed (pure random)
const questions = selectRandomQuestions(pool, 10);

// With seed (deterministic - same seed = same order)
const questions = selectRandomQuestions(pool, 10, { 
  seed: "user123_topic_algebra" 
});
```

**Seed Behavior:**
```javascript
// Same seed always produces same selection
seed: "test123" → [Q5, Q12, Q3, Q8, ...]  // Always this order
seed: "test123" → [Q5, Q12, Q3, Q8, ...]  // Same again
seed: "test456" → [Q9, Q2, Q15, Q1, ...]  // Different order
```

---

### Knapsack-Style Selection

**Function:** `selectQuestionsKnapsackStyle(availableQuestions, targetMarks, tolerance)`

**Purpose:** Select questions to hit target marks precisely

**Algorithm:**
1. **Greedy Phase:** Pick questions until close to target
2. **Optimization Phase:** Swap questions to minimize deviation

**Example:**
```javascript
// Target: 40 marks (±15% tolerance = 34-46 marks)
// Available: [2m, 3m, 5m, 5m, 8m, 10m, 12m, 15m]
// 
// Greedy picks: [15m, 12m, 10m, 5m] = 42 marks ✓
// Within tolerance (34-46), so return this set
```

**Tolerance Handling:**
```javascript
tolerance: 0.15 (15%)
target: 40 marks

Acceptable range:
  min = 40 - (40 × 0.15) = 34 marks
  max = 40 + (40 × 0.15) = 46 marks
```

---

## 🔑 Key Functions Explained

### 1. `generateTestPaper(params)`
**Location:** `testService.js`

**Purpose:** Main orchestrator - routes to appropriate generation strategy

**Decision Logic:**
```javascript
if (format === 'short_answer') {
  return generateShortAnswerTest(params);
}

if (mode === 'by_topic' && topic) {
  return generateTopicBasedTest(params);
}

try {
  return generateBlueprintCompliantTest(params);
} catch (error) {
  return generateLegacyTestPaper(params);
}
```

---

### 2. `buildQuestionQuery(params)`
**Location:** `databaseService.js`

**Purpose:** Construct Firestore query with filters

**Filters Applied:**
- ✅ Grade (required)
- ✅ Subject (required)
- ✅ Paper (optional)
- ✅ Year (optional)
- ✅ Season (optional)
- ✅ Topic (optional)
- ✅ Limit (default: 50)

**Example Query:**
```javascript
firestore.collection('questions')
  .where('grade', '==', 12)
  .where('subject', '==', 'Mathematics')
  .where('paper', '==', 'Paper 1')
  .where('topic', '==', 'Algebra')
  .limit(50)
```

---

### 3. `processQuestionsForFormat(questions, format)`
**Location:** `testService.js`

**Purpose:** Ensure format-specific data is complete

**Format Handling:**

#### Drag & Drop:
```javascript
if (format === 'dragAndDrop') {
  question.dragItems = safeArray(question.dragItems);
  question.dropTargets = safeArray(question.dropTargets);
  question.dragTargets = safeArray(question.dragTargets);
}
```

#### Short Answer:
```javascript
if (format === 'shortAnswer') {
  question.answerType = question.answerType || 'text';
  question.caseSensitive = question.caseSensitive || false;
  question.tolerance = question.tolerance || 0;
  question.answerVariations = [...];
}
```

---

### 4. `selectQuestionsForTopic(topicName, marksNeeded, params, tolerance)`
**Location:** `enhancedTestService.js`

**Purpose:** Select questions for a specific topic with precise marks

**Process:**
1. Query 50 questions for topic (large pool)
2. Use knapsack algorithm to hit marks target
3. Return optimal selection

**Example:**
```javascript
// Need 40 marks for "Algebra"
const questions = await selectQuestionsForTopic(
  "Algebra", 
  40, 
  { grade: 12, subject: "Mathematics" },
  0.15  // ±15% tolerance
);
// Returns: questions totaling 38-46 marks
```

---

## 🚨 Common Issues & Solutions

### Issue 1: "Blueprint not found"

**Symptom:** Error when generating test

**Cause:** Blueprint ID format mismatch

**Solution:**
```javascript
// Blueprint ID format must match exactly:
{subject}_{paper}_gr{grade}

// Paper normalization:
"Paper 1" → "paper_1"
"P1" → "paper_1"
"Paper1" → "paper_1"

// Check normalizePaperFormat() in dataHelpers.js
```

**Debug:**
```javascript
// Log available blueprints
const blueprints = await firestore.collection('blueprints').get();
blueprints.docs.forEach(doc => console.log(doc.id));
```

---

### Issue 2: "No questions found"

**Symptom:** Empty result set

**Causes:**
1. No questions match all filters
2. Topic name mismatch
3. Paper format mismatch

**Solution:**
```javascript
// Reduce filters incrementally:
// 1. Remove year/season
// 2. Remove topic
// 3. Check grade/subject/paper only

// Verify topic names match exactly
firestore.collection('questions')
  .where('subject', '==', 'Mathematics')
  .where('grade', '==', 12)
  .get()
  .then(snap => {
    const topics = new Set();
    snap.docs.forEach(doc => topics.add(doc.data().topic));
    console.log('Available topics:', [...topics]);
  });
```

---

### Issue 3: Insufficient marks in blueprint generation

**Symptom:** Not enough questions to meet blueprint marks

**Cause:** Limited question pool for specific topics

**Solution:**
```javascript
// Increase tolerance in enhancedTestService.js
const tolerance = 0.20; // Allow ±20% instead of ±15%

// Or reduce marks requirement in blueprint
topicDistribution: {
  "Algebra": { marks: 30 } // Reduced from 40
}
```

---

### Issue 4: Drag & Drop questions missing data

**Symptom:** `dragItems` or `dropTargets` undefined

**Cause:** Questions not processed for format

**Solution:**
```javascript
// Ensure processQuestionsForFormat() is called
const processedQuestions = processQuestionsForFormat(
  questions, 
  'dragAndDrop'
);

// Or check question document has required fields:
{
  format: "drag_and_drop_ordering",
  dragItems: [...],
  correctOrder: [...]
}
```

---

## 🔧 Configuration

### Adjustable Parameters

**In `testService.js`:**
```javascript
// Question pool multiplier for topic tests
const poolFactor = Number(params.poolFactor || 5);

// Default question count for topic practice
const defaultQuestionCount = 10;
```

**In `enhancedTestService.js`:**
```javascript
// Marks tolerance (default ±15%)
const tolerance = 0.15;

// Question pool size per topic
limit: 50
```

---

## 📊 Response Structure

### Successful Generation:
```javascript
{
  questions: [
    {
      id: "abc123",
      questionNumber: 1,
      subject: "Mathematics",
      grade: 12,
      topic: "Algebra",
      format: "MCQ",
      questionText: "Solve for x...",
      options: ["A", "B", "C", "D"],
      marks: 2,
      maxMarks: 2,
      cognitiveLevel: "Level 2"
      // Note: correctAnswer removed (sanitized)
    },
    // ... more questions
  ],
  totalQuestions: 20,
  blueprint: { ... },
  generatedAt: "2025-10-01T12:00:00.000Z",
  
  // Enhanced generation includes:
  complianceReport: {
    topicsMatched: 8,
    topicsInBlueprint: 8,
    marksDeviation: 2.5,
    // ...
  }
}
```

---

## 🎓 Best Practices

### For Blueprint Design:
1. ✅ Use consistent topic names across questions and blueprints
2. ✅ Ensure sufficient questions exist for each topic
3. ✅ Set realistic marks distribution
4. ✅ Use new `formats` structure for better control

### For Question Documents:
1. ✅ Include all required fields (`grade`, `subject`, `paper`, `topic`)
2. ✅ Normalize paper format (`Paper 1` vs `P1`)
3. ✅ Add `cognitiveLevel` for better distribution
4. ✅ Include format-specific data (`dragItems`, `answerVariations`)

### For Client Requests:
1. ✅ Use `excludeIds` to avoid question repetition
2. ✅ Use `seed` for consistent test variants
3. ✅ Set appropriate `poolFactor` for randomness
4. ✅ Handle "not-found" errors gracefully

---

## 📝 Summary

**Current test generation supports:**
- ✅ Blueprint-based generation (enhanced & legacy)
- ✅ Topic-based practice (no blueprint needed)
- ✅ Short answer tests (PQP & Sprint modes)
- ✅ Deterministic randomness (seeded shuffle)
- ✅ Question exclusion (avoid repeats)
- ✅ Cognitive level balancing
- ✅ Knapsack marks optimization
- ✅ Multiple question formats (MCQ, Short Answer, Drag & Drop, etc.)

**Main entry point:** `functions/index.js` → `generateTest`

**Core logic:** `functions/src/services/testService.js`

**Enhancement:** `functions/src/services/enhancedTestService.js`

---

*Document last updated: October 1, 2025*
