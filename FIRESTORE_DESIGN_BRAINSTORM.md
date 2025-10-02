# Firestore Structure Design - Brainstorming Session
## Current State Analysis & Improvement Suggestions

**Date:** October 2, 2025  
**Status:** Active Brainstorming

---

## 🔍 Current Firestore Structure

### Collections Overview
```
firestore-root/
├── questions/           # Main questions collection (FLAT structure)
├── blueprints/          # Subject/exam blueprints
├── users/              # User profiles
└── test_sessions/      # (Assumed) Active test sessions
```

---

## 📊 Current Questions Collection Design

### Structure Type: **FLAT** (All questions at same level)

```javascript
// Document: questions/{questionId}
{
  // Identity
  "id": "mcq_math_001",
  "questionType": "mcq",              // mcq, short_answer, drag_drop, etc.
  
  // Content
  "questionText": "Solve for x: 2x + 5 = 15",
  "imageUrl": null,                    // Optional image
  "options": ["3", "5", "7", "10"],   // For MCQ
  "correctAnswer": "5",
  "marks": 2,
  
  // Classification
  "subject": "Mathematics",
  "topic": "Algebra",
  "subtopic": "Linear Equations",
  "grade": 12,
  "paper": "Paper 1",
  "year": 2023,
  "season": "November",
  "difficulty": "easy",
  
  // Mode-specific data (NESTED objects)
  "pqpData": {
    "questionNumber": "1.1",          // Exam paper numbering
    "marks": 2,
    "chainId": "q1",
    "partOfChain": true
  },
  "sprintData": {
    "hints": ["Subtract 5", "Divide by 2"],
    "explanation": "..."
  }
}
```

### Query Patterns Used
```javascript
// From databaseService.js
collection('questions')
  .where('grade', '==', grade)
  .where('subject', '==', subject)
  .where('paper', '==', paper)      // Optional
  .where('year', '==', year)        // Optional
  .where('season', '==', season)    // Optional
  .where('topic', '==', topic)      // Optional
  .limit(50)
```

---

## ⚠️ Current Issues & Pain Points

### 1. **Image Duplication Problem**
**Issue:** Sub-questions (4.1.1, 4.1.2, 4.2.1) all store the same image URL

```javascript
// Current: 3 separate documents with SAME image
questions/q4_1_1: { imageUrl: "graph.png", questionNumber: "4.1.1" }
questions/q4_1_2: { imageUrl: "graph.png", questionNumber: "4.1.2" }  // ❌ Duplicate
questions/q4_2_1: { imageUrl: "graph.png", questionNumber: "4.2.1" }  // ❌ Duplicate
```

**Impact:**
- Wasted storage
- Update complexity (change image = update 3+ docs)
- Inconsistency risk

### 2. **Short Answers Single Document**
**Issue:** All short answer questions stored in ONE document

```javascript
// Current: questions/short_answer (MEGA-DOCUMENT)
{
  "questions": [
    { id: "sa_001", questionText: "...", correctAnswer: "..." },
    { id: "sa_002", questionText: "...", correctAnswer: "..." },
    // ... 100+ questions in ONE document
  ]
}
```

**Impact:**
- Document size limit risk (1MB Firestore limit)
- Can't query individual questions
- Must fetch ALL short answers to get one
- No direct document references

### 3. **No Question Hierarchy**
**Issue:** Parent-child relationships exist conceptually but not in structure

```javascript
// Question 4 has sub-questions 4.1.1, 4.1.2, 4.2.1, 4.2.2
// But they're stored as flat, unrelated documents
```

**Impact:**
- Can't fetch "Question 4 with all sub-questions" efficiently
- Can't show parent context when displaying sub-questions
- Navigation between sub-questions is manual

### 4. **Query Limitations**
**Issue:** Firestore compound query limitations

```javascript
// Can only use ONE inequality filter per query
// Can only order by fields used in where()
// Requires composite indexes for complex queries
```

**Current workaround:** Limit to simple equality filters

---

## 🎯 Design Options - Pros & Cons

### **Option 1: Keep Current Flat Structure** ✅ (Status Quo)

**Structure:**
```
questions/
├── mcq_math_001
├── mcq_math_002
├── sa_math_001          # Individual short answer docs
├── q4_1_1               # Sub-question (flat)
└── q4_1_2               # Sub-question (flat)
```

**Pros:**
- ✅ Simple to understand
- ✅ Easy to query by filters
- ✅ Works with current code
- ✅ Fast for "get all questions" queries

**Cons:**
- ❌ Image duplication for sub-questions
- ❌ No question hierarchy
- ❌ Can't fetch parent + children in one query
- ❌ Manual relationship management

**Best For:** Current MVP, simple question browsing

---

### **Option 2: Hierarchical with Subcollections** 🌳

**Structure:**
```
questions/
├── mcq_math_001
├── parent_q4/                    # Parent question document
│   ├── (data: mainText, image)
│   └── subQuestions/             # Subcollection
│       ├── 4_1_1
│       ├── 4_1_2
│       └── 4_2_1
└── sa_math_001
```

**Document Example:**
```javascript
// questions/parent_q4
{
  "questionNumber": "4",
  "mainQuestionText": "Study the graph...",
  "imageUrl": "graph.png",        // ✅ ONE image
  "totalMarks": 10,
  "subject": "Mathematics",
  "year": 2023
}

// questions/parent_q4/subQuestions/4_1_1
{
  "questionNumber": "4.1.1",
  "questionText": "Write down asymptote",
  "correctAnswer": "y = -4",
  "marks": 1
}
```

**Pros:**
- ✅ Image stored once at parent level
- ✅ Clear parent-child hierarchy
- ✅ Can query parent OR children separately
- ✅ Logical structure matches exam papers

**Cons:**
- ❌ Can't query across subcollections easily
- ❌ Can't get "all questions regardless of hierarchy" in one query
- ❌ More complex data fetching logic
- ❌ Collection Group queries needed for deep queries

**Best For:** When question hierarchy is critical, complex exam structures

---

### **Option 3: Flat with References** 🔗

**Structure:**
```
questions/
├── parent_q4              # Parent with array of child IDs
├── q4_1_1                 # Child with parentId reference
├── q4_1_2                 # Child with parentId reference
└── q4_2_1                 # Child with parentId reference
```

**Document Example:**
```javascript
// questions/parent_q4
{
  "questionNumber": "4",
  "isParent": true,
  "imageUrl": "graph.png",        // ✅ ONE image
  "childQuestionIds": [            // Reference array
    "q4_1_1",
    "q4_1_2", 
    "q4_2_1"
  ]
}

// questions/q4_1_1
{
  "questionNumber": "4.1.1",
  "parentQuestionId": "parent_q4",  // Bidirectional reference
  "questionText": "Write down asymptote",
  "marks": 1
}
```

**Pros:**
- ✅ Image stored once
- ✅ Can still query all questions flat
- ✅ Parent-child relationship preserved
- ✅ Flexible queries (can ignore parents if needed)

**Cons:**
- ❌ Need multiple reads to get full hierarchy
- ❌ Manual reference management
- ❌ Potential inconsistency if references break
- ❌ No atomic parent+children fetches

**Best For:** Hybrid approach - maintain queryability + hierarchy

---

### **Option 4: Separate Collections by Type** 📁

**Structure:**
```
mcq_questions/
├── mcq_math_001
└── mcq_physics_002

short_answer_questions/
├── sa_math_001
└── sa_physics_001

parent_questions/
├── parent_q4
│   └── (children array or subcollection)
└── parent_q1
```

**Pros:**
- ✅ Type-specific queries are faster
- ✅ Each collection has optimized indexes
- ✅ Easier to apply type-specific rules
- ✅ Clear separation of concerns

**Cons:**
- ❌ Can't query "all questions" across types easily
- ❌ Need Collection Group queries for cross-type
- ❌ More complex code (type-specific handlers)
- ❌ Harder to maintain consistency

**Best For:** Large scale with millions of questions per type

---

### **Option 5: Flat + Array of Sub-questions** 📦

**Structure:**
```
questions/
├── mcq_math_001
├── parent_q4              # ONE document with embedded children
└── sa_math_001
```

**Document Example:**
```javascript
// questions/parent_q4
{
  "questionNumber": "4",
  "mainQuestionText": "Study the graph...",
  "imageUrl": "graph.png",        // ✅ ONE image
  "totalMarks": 10,
  
  "subQuestions": [               // ✅ Array of sub-questions
    {
      "id": "4.1.1",
      "questionText": "Write asymptote",
      "correctAnswer": "y = -4",
      "marks": 1
    },
    {
      "id": "4.1.2",
      "questionText": "Calculate intercept",
      "correctAnswer": "-3",
      "marks": 2
    }
  ]
}
```

**Pros:**
- ✅ ONE read gets parent + all children
- ✅ Image stored once
- ✅ Atomic updates (all or nothing)
- ✅ Simple to query top-level questions
- ✅ No reference management

**Cons:**
- ❌ Can't query individual sub-questions directly
- ❌ Document size grows with sub-questions
- ❌ All-or-nothing reads (can't fetch just one sub-question)
- ❌ Harder to update individual sub-questions

**Best For:** Questions with small number of sub-questions (< 20)

---

## 💡 Recommended Hybrid Approach

### **Suggested: Option 3 (Flat with References) + Short Answer Fix**

**Rationale:**
1. ✅ Maintains current query patterns (minimal code changes)
2. ✅ Fixes image duplication
3. ✅ Fixes short answer mega-document
4. ✅ Preserves flexibility for future changes
5. ✅ Incremental migration path

### Implementation Plan

#### Phase 1: Fix Short Answers (HIGH PRIORITY)
```javascript
// BEFORE: questions/short_answer (single doc)
// AFTER: Individual documents

questions/sa_math_001: {
  id: "sa_math_001",
  questionText: "Calculate discriminant...",
  correctAnswer: "1",
  // ... all standard fields
}
```

**Migration:**
```javascript
// Pseudo-code
const shortAnswerDoc = await db.collection('questions').doc('short_answer').get();
const questions = shortAnswerDoc.data().questions;

for (const q of questions) {
  await db.collection('questions').doc(q.id).set(q);
}
```

#### Phase 2: Add Parent References (MEDIUM PRIORITY)
```javascript
// Add to existing sub-question docs

questions/q4_1_1: {
  // ... existing fields
  parentQuestionId: "parent_q4",    // NEW
  usesParentImage: true             // NEW
}

// Create parent documents

questions/parent_q4: {
  questionNumber: "4",
  isParent: true,
  imageUrl: "graph.png",
  mainQuestionText: "...",
  childQuestionIds: ["q4_1_1", "q4_1_2", "q4_2_1"]
}
```

#### Phase 3: Update Client Code (MEDIUM PRIORITY)
```dart
// Add method to fetch parent + children

Future<ParentWithChildren> getQuestionFamily(String parentId) async {
  final parent = await getQuestion(parentId);
  final childIds = parent.childQuestionIds;
  final children = await Future.wait(
    childIds.map((id) => getQuestion(id))
  );
  return ParentWithChildren(parent, children);
}
```

---

## 📋 Query Optimization Strategies

### Required Composite Indexes

```javascript
// Collection: questions
// For Full Exam Mode queries
{
  fields: [
    { fieldPath: "subject", order: "ASCENDING" },
    { fieldPath: "year", order: "ASCENDING" },
    { fieldPath: "season", order: "ASCENDING" },
    { fieldPath: "paper", order: "ASCENDING" }
  ]
}

// For By Topic queries
{
  fields: [
    { fieldPath: "subject", order: "ASCENDING" },
    { fieldPath: "topic", order: "ASCENDING" },
    { fieldPath: "difficulty", order: "ASCENDING" }
  ]
}
```

### Caching Strategy
```javascript
// Client-side
- Cache blueprints (rarely change)
- Cache user's recent questions (10-minute TTL)
- Prefetch next question while user answers current

// Functions-side
- Cache blueprint lookups (Firebase hosting cache)
- Use Cloud Functions memory for session data
```

---

## 🎯 Decision Matrix

| Criteria | Option 1 (Current) | Option 3 (Flat+Refs) | Option 5 (Arrays) |
|----------|-------------------|---------------------|-------------------|
| **Image Duplication** | ❌ Yes | ✅ No | ✅ No |
| **Query Simplicity** | ✅ Simple | ✅ Simple | ✅ Simple |
| **Hierarchy Support** | ❌ Manual | ✅ References | ✅ Embedded |
| **Individual Sub-Q Access** | ✅ Easy | ✅ Easy | ❌ Hard |
| **Migration Effort** | - | 🟡 Medium | 🔴 High |
| **Atomic Reads** | ✅ Yes | ❌ Multiple | ✅ Yes |
| **Document Size** | ✅ Small | ✅ Small | 🟡 Medium |
| **Future Flexibility** | 🟡 Limited | ✅ High | 🟡 Medium |

**Winner:** **Option 3 (Flat with References)** ⭐

---

## 🚀 Next Steps

### Immediate (This Sprint)
1. ✅ **Migrate short answers** to individual documents
   - Write migration script
   - Test with sample data
   - Deploy to production
   - Update Cloud Functions

2. ✅ **Add parent question documents** for image questions
   - Identify all questions with images
   - Create parent documents
   - Add `parentQuestionId` field to children
   - Keep existing structure intact (non-breaking)

### Short-term (Next Sprint)
3. 🔄 **Update Flutter app** to use parent references
   - Add `ParentQuestion` model
   - Update `practice_screen.dart` to fetch parent
   - Show parent context + image once
   - Navigation respects parent-child relationships

4. 🔄 **Update Cloud Functions** to return parent data
   - Include parent info in test generation
   - Optimize queries to fetch families

### Long-term (Future)
5. 📅 **Consider subcollections** if hierarchy becomes more complex
6. 📅 **Add caching layer** (Redis/Memorystore)
7. 📅 **Implement pagination** for large result sets

---

## 🤔 Open Questions for Discussion

1. **Short Answer Migration Timing:**
   - Migrate in off-hours? (low user traffic)
   - Staged rollout or all-at-once?
   - Backup strategy?

2. **Parent Question Creation:**
   - Auto-detect from `questionNumber` pattern?
   - Manual curation by admin?
   - Bulk import tool?

3. **Query Performance:**
   - What's the 95th percentile query time currently?
   - How many questions per test on average?
   - Peak concurrent users?

4. **Future Features:**
   - Will we need question versioning?
   - Multi-language support?
   - AI-generated questions?

---

## 📊 Estimated Impact

### Storage Savings
- Current: ~500 questions × 3 sub-questions × 100KB image refs = ~150MB duplicated
- After: ~500 parent docs × 100KB = ~50MB
- **Savings: ~100MB (67% reduction)**

### Query Performance
- Current: Fetch 10 questions = 10 reads
- After: Fetch 10 questions + parents = 10-15 reads (depending on parent reuse)
- **Impact: Minimal (cached parents help)**

### Development Effort
- Phase 1 (Short Answer): **4-6 hours**
- Phase 2 (Parent Refs): **8-12 hours**
- Phase 3 (Client Update): **12-16 hours**
- **Total: 1-2 weeks** (with testing)

---

**Let's discuss and decide on the path forward!** 🎯

