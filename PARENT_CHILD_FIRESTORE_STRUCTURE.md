# Parent-Child Question Structure in Firestore

## 📚 Overview

The parent-child structure (Option 3) allows multiple sub-questions to share common context (text, diagrams, scenarios). This eliminates data duplication and provides a better user experience.

---

## 🏗️ Architecture Concept

### **Parent = Context Document (NOT an answerable question)**
- Provides shared context (text, images, diagrams)
- Acts as a "scenario holder" or "diagram container"
- **Never displayed as a standalone question**
- **Never has a format or questionType field**
- Children reference the parent to inherit context

### **Children = Answerable Questions**
- Each child is a complete, answerable question
- Has `format` field (MCQ, short_answer, drag_drop, etc.)
- References parent via `parentQuestionId`
- Inherits parent's image via `usesParentImage: true` flag
- Can optionally override parent context with own text/image

---

## 📋 Firestore Document Structure

### **Parent Document Fields**

#### ✅ **Required Fields:**
```javascript
{
  // Identity
  id: 'parent_func_001',                    // Unique identifier
  isParent: true,                            // Flag to identify as parent
  type: 'context',                           // Document type (NOT a question format)
  
  // Context Information (shared by all children)
  questionText: 'The scenario description...', // Full context text
  imageUrl: 'https://...',                   // Shared diagram/image URL
  
  // Metadata (inherited by children for filtering/querying)
  subject: 'mathematics',
  grade: 12,
  topic: 'Functions & Graphs',              // Must match blueprint topics
  paper: 'p1',                               // p1, p2, or p3
  year: 2023,
  season: 'November',                        // November, June, March
  
  // Parent-specific Fields
  childQuestionIds: [                        // Array of child IDs
    'child_func_001_1',
    'child_func_001_2',
    'child_func_001_3'
  ],
  totalMarks: 13,                            // Sum of all children's marks
  
  // Availability
  availableInModes: ['pqp', 'sprint', 'by_topic'],
  
  // PQP Data (parent-level metadata)
  pqpData: {
    questionNumber: '4.1',                   // Parent number (e.g., 4.1)
    year: 2023,
    season: 'November',
    paper: 'p1',
    marks: 13,                               // Total marks
    isParent: true
  },
  
  // Timestamps
  createdAt: serverTimestamp,
  updatedAt: serverTimestamp
}
```

#### ❌ **Fields NOT Allowed on Parents:**
- `format` - Parents are not answerable questions
- `questionType` - Parents don't have question types
- `correctAnswer` - Parents don't have answers
- `options` - Parents don't have MCQ options
- `marks` - Use `totalMarks` instead
- `cognitiveLevel` - Applies to individual children
- `difficulty` - Applies to individual children
- `sprintData` - Children have individual hints
- `caseSensitive`, `tolerance` - Answer-specific fields

---

### **Child Document Fields**

#### ✅ **Required Fields:**
```javascript
{
  // Identity
  id: 'child_func_001_1',                    // Unique identifier
  
  // Format (children ARE answerable questions)
  format: 'short_answer',                    // MCQ, short_answer, drag_drop, etc.
  questionType: 'short_answer',              // Same as format
  answerType: 'coordinates',                 // For short_answer: text, number, coordinates, equation
  
  // Question Content
  questionText: 'Calculate the coordinates...', // Child-specific question text
  
  // Parent Relationship
  parentQuestionId: 'parent_func_001',       // Reference to parent
  usesParentImage: true,                     // Flag: uses parent's image
  
  // Answer Data (required for answerable questions)
  correctAnswer: {
    value: '(1, -4)',                        // Main correct answer
    variations: [                            // Acceptable variations
      '(1;-4)',
      '(1, -4)',
      'D(1, -4)'
    ]
  },
  marks: 4,                                  // Individual child marks
  
  // Metadata (must match parent for proper querying)
  subject: 'mathematics',
  grade: 12,
  topic: 'Functions & Graphs',              // MUST match parent topic
  paper: 'p1',
  year: 2023,
  season: 'November',
  cognitiveLevel: 'Level 3',                // Level 1, 2, 3, or 4
  difficulty: 'medium',                      // easy, medium, hard
  
  // Availability
  availableInModes: ['pqp', 'sprint', 'by_topic'],
  
  // PQP Data (child-specific)
  pqpData: {
    questionNumber: '4.1.1',                 // Child numbering (4.1.1, 4.1.2, etc.)
    year: 2023,
    season: 'November',
    paper: 'p1',
    marks: 4,
    showWithParent: true                     // UI flag to display parent context
  },
  
  // Sprint Data (child-specific hints)
  sprintData: {
    hint: 'The turning point x-coordinate...',
    timeEstimate: 3,                         // Minutes
    providedContext: {                       // Additional hints
      'x-intercepts': 'A(-1, 0) and B(3, 0)'
    }
  },
  
  // Short Answer Specific Fields (if applicable)
  caseSensitive: false,
  tolerance: 0,                              // For numeric answers
  
  // MCQ Specific Fields (if applicable)
  // options: ['A', 'B', 'C', 'D'],
  // correctAnswer: 'B',
  
  // Timestamps
  createdAt: serverTimestamp,
  updatedAt: serverTimestamp
}
```

#### ⚠️ **Important Child Rules:**
- **Topic must exactly match parent topic** (for filtering to work)
- If `usesParentImage: true`, do NOT include `imageUrl` field
- If child needs own image, set `usesParentImage: false` and add `imageUrl`
- `parentQuestionId` must reference an existing parent document

---

## 🎯 Parent-Child Relationship Flow

```
┌─────────────────────────────────────────┐
│  PARENT DOCUMENT (Context Provider)     │
│  ID: parent_func_001                    │
│  Type: context                          │
│  Image: graph.png                       │
│  Text: "The sketch shows..."            │
│  Total Marks: 13                        │
└─────────────────────────────────────────┘
              │
              ├──────────────┬──────────────┬──────────────┐
              ▼              ▼              ▼              ▼
    ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
    │  CHILD 1    │  │  CHILD 2    │  │  CHILD 3    │
    │  4.1.1      │  │  4.1.2      │  │  4.1.3      │
    │  4 marks    │  │  4 marks    │  │  5 marks    │
    │  Uses       │  │  Uses       │  │  Uses       │
    │  parent     │  │  parent     │  │  parent     │
    │  image      │  │  image      │  │  image      │
    └─────────────┘  └─────────────┘  └─────────────┘
```

---

## 🔍 Querying Strategy

### **By Topic Mode:**
1. Query: `questions` collection where `topic == 'Functions & Graphs'`
2. Filter: Exclude parents (`isParent != true`)
3. Backend enriches children with `parentContext` data
4. Frontend displays parent context card + child question

### **PQP Mode (Full Exam):**
1. Query: `questions` where `paper == 'p1' AND year == 2023 AND season == 'November'`
2. Filter: Exclude parents (`isParent != true`)
3. Sort by `pqpData.questionNumber` (natural sort: 4.1.1, 4.1.2, 4.1.3)
4. Backend enriches children with parent context
5. Frontend groups children under parent context

### **Sprint Mode (Quick Practice):**
1. Query: `questions` where `availableInModes` contains 'sprint'
2. Filter: Exclude parents
3. Backend enriches with parent context
4. Frontend shows simplified view with hints from `sprintData`

---

## 📝 Data Input Plan

### **Phase 1: Manual Upload Script (Current)**
**Tool:** `functions/tools/upload-parent-child-corrected.js`

**Process:**
1. Create JavaScript objects for parent and children
2. Validate structure (no `format` on parent, all children have `format`)
3. Use Firebase Admin SDK batch write
4. Run: `node functions/tools/upload-parent-child-corrected.js`

**Advantages:**
- ✅ Full control over data structure
- ✅ Can validate before upload
- ✅ Good for initial data population

**Disadvantages:**
- ❌ Requires coding knowledge
- ❌ Time-consuming for large datasets
- ❌ Not scalable for content teams

---

### **Phase 2: Spreadsheet Import Tool (Recommended)**
**Tool:** Create `functions/tools/import-from-spreadsheet.js`

**CSV/Excel Format:**

#### **Parents Sheet:**
```csv
id,type,questionText,imageUrl,subject,grade,topic,paper,year,season,totalMarks,pqpQuestionNumber
parent_func_001,context,"The sketch shows...",https://...,mathematics,12,Functions & Graphs,p1,2023,November,13,4.1
```

#### **Children Sheet:**
```csv
id,parentId,format,questionText,correctAnswer,answerVariations,marks,cognitiveLevel,difficulty,pqpQuestionNumber,sprintHint
child_func_001_1,parent_func_001,short_answer,"Calculate coordinates...",(1;-4),"(1, -4)|(1;-4)|D(1;-4)",4,Level 3,medium,4.1.1,"Use x = (x₁ + x₂)/2"
child_func_001_2,parent_func_001,short_answer,"Determine equation...",f(x)=x²-2x-3,"f(x)=x²-2x-3|y=x²-2x-3",4,Level 3,medium,4.1.2,"Use factored form"
```

**Implementation Steps:**
1. Content team fills spreadsheet template
2. Export to CSV
3. Run import script: `node functions/tools/import-from-spreadsheet.js parents.csv children.csv`
4. Script validates and uploads to Firestore

**Script Validation:**
- Check parent has no `format` field
- Verify all children reference valid parent IDs
- Ensure topic names match blueprint
- Validate answer formats
- Check mark totals match

---

### **Phase 3: Web-Based Admin Portal (Future)**
**Tool:** Build admin dashboard at `/admin` route

**Features:**
1. **Parent Question Builder:**
   - Rich text editor for context
   - Image uploader with preview
   - Auto-generate parent ID
   - Set metadata (subject, grade, topic)

2. **Child Question Builder:**
   - Select parent from dropdown
   - Question text editor
   - Answer input with variations
   - Hint editor for Sprint mode
   - Preview with parent context

3. **Validation:**
   - Real-time field validation
   - Check topic matches blueprint
   - Verify parent exists
   - Calculate total marks

4. **Bulk Operations:**
   - Import from spreadsheet
   - Export to CSV
   - Duplicate question sets
   - Bulk edit metadata

**Tech Stack:**
- Frontend: Flutter Web or React
- Backend: Cloud Functions
- Storage: Firestore + Firebase Storage (images)
- Auth: Firebase Auth with admin role check

---

## 📊 Example: Complete Parent-Child Set

### **Scenario:** Mathematics Functions & Graphs Question

**Parent Document:**
```javascript
{
  id: 'parent_func_001',
  isParent: true,
  type: 'context',
  questionText: 'The sketch below shows the graphs of f(x) = ax² + bx + c and g(x) = mx + k. The graph of f cuts the x-axis at A(-1, 0) and B(3, 0). The turning point of f is D. The two graphs intersect at A and C(2, 5).',
  imageUrl: 'https://storage/.../functions_graph_001.png',
  subject: 'mathematics',
  grade: 12,
  topic: 'Functions & Graphs',
  paper: 'p1',
  year: 2023,
  season: 'November',
  childQuestionIds: ['child_func_001_1', 'child_func_001_2', 'child_func_001_3'],
  totalMarks: 13,
  availableInModes: ['pqp', 'sprint', 'by_topic'],
  pqpData: {
    questionNumber: '4.1',
    year: 2023,
    season: 'November',
    paper: 'p1',
    marks: 13,
    isParent: true
  }
}
```

**Child 1 Document:**
```javascript
{
  id: 'child_func_001_1',
  format: 'short_answer',
  questionType: 'short_answer',
  answerType: 'coordinates',
  questionText: 'Calculate the coordinates of D, the turning point of f.',
  parentQuestionId: 'parent_func_001',
  usesParentImage: true,
  correctAnswer: {
    value: '(1, -4)',
    variations: ['(1;-4)', '(1, -4)', 'D(1, -4)']
  },
  marks: 4,
  subject: 'mathematics',
  grade: 12,
  topic: 'Functions & Graphs',
  paper: 'p1',
  year: 2023,
  season: 'November',
  cognitiveLevel: 'Level 3',
  difficulty: 'medium',
  availableInModes: ['pqp', 'sprint', 'by_topic'],
  pqpData: {
    questionNumber: '4.1.1',
    year: 2023,
    season: 'November',
    paper: 'p1',
    marks: 4,
    showWithParent: true
  },
  sprintData: {
    hint: 'The turning point x-coordinate is midway between the x-intercepts.',
    timeEstimate: 3
  },
  caseSensitive: false,
  tolerance: 0
}
```

**Child 2 & 3:** Similar structure with different questions, answers, and marks.

---

## ✅ Validation Checklist

Before uploading parent-child questions, verify:

### **Parent Checklist:**
- [ ] Has `isParent: true` field
- [ ] Has `type: 'context'` field
- [ ] Does NOT have `format` field
- [ ] Does NOT have `questionType` field
- [ ] Does NOT have `correctAnswer` field
- [ ] Does NOT have `sprintData` field
- [ ] Has `childQuestionIds` array with valid child IDs
- [ ] Has `totalMarks` equal to sum of children's marks
- [ ] Has `imageUrl` if children use shared image
- [ ] Topic name matches blueprint exactly

### **Child Checklist:**
- [ ] Has `format` field (MCQ, short_answer, etc.)
- [ ] Has `questionType` field
- [ ] Has `parentQuestionId` referencing valid parent
- [ ] Has `usesParentImage: true` if using parent's image
- [ ] Does NOT have `imageUrl` if `usesParentImage: true`
- [ ] Has `correctAnswer` field
- [ ] Has `marks` field
- [ ] Topic exactly matches parent's topic
- [ ] Has `pqpData.questionNumber` with proper numbering (e.g., 4.1.1)
- [ ] Has `sprintData` with hints for Sprint mode

---

## 🚨 Common Mistakes to Avoid

1. **Adding `format` to parent** → Parents are NOT answerable questions
2. **Adding `sprintData` to parent** → Only children have hints
3. **Topic mismatch** → Child topic must exactly match parent
4. **Missing `usesParentImage` flag** → Children won't know to display parent image
5. **Duplicate images** → Don't add `imageUrl` to child if using parent's image
6. **Wrong numbering** → PQP numbers should be 4.1 (parent), 4.1.1, 4.1.2 (children)
7. **Orphaned children** → Every child must have a valid `parentQuestionId`
8. **Standalone parents** → Parents filtered out by backend, never displayed alone

---

## 📞 Support & Questions

For questions about the parent-child structure:
1. Check this document first
2. Review `functions/tools/upload-parent-child-corrected.js` for working example
3. See `.github/copilot-instructions.md` for architecture overview
4. Contact: Kinetix Engineering Solutions

---

**Last Updated:** October 3, 2025  
**Version:** 1.0  
**Maintained by:** Kinetix Engineering Solutions
