# Spreadsheet Import Template

## 📊 Overview

This document provides templates for importing parent-child questions from spreadsheets (CSV/Excel) into Firestore.

---

## 📝 Parents Template

### **File:** `parents.csv`

#### **Column Headers:**
```csv
id,type,questionText,imageUrl,subject,grade,topic,paper,year,season,totalMarks,pqpQuestionNumber,availableModes
```

#### **Example Rows:**
```csv
id,type,questionText,imageUrl,subject,grade,topic,paper,year,season,totalMarks,pqpQuestionNumber,availableModes
parent_func_001,context,"The sketch below shows the graphs of f(x) = ax² + bx + c and g(x) = mx + k. The graph of f cuts the x-axis at A(-1, 0) and B(3, 0). The turning point of f is D. The two graphs intersect at A and C(2, 5).",https://storage.googleapis.com/.../functions_graph_001.png,mathematics,12,Functions & Graphs,p1,2023,November,13,4.1,"pqp|sprint|by_topic"
parent_trig_001,context,"In the diagram below, triangle ABC is shown with angle A = 30°, angle B = 60°, and side AB = 10 cm.",https://storage.googleapis.com/.../triangle_diagram_001.png,mathematics,12,Trigonometry,p1,2023,November,10,5.1,"pqp|sprint|by_topic"
```

#### **Field Descriptions:**

| Field | Type | Required | Description | Example |
|-------|------|----------|-------------|---------|
| `id` | String | Yes | Unique identifier (use prefix `parent_`) | `parent_func_001` |
| `type` | String | Yes | Always use `context` | `context` |
| `questionText` | Text | Yes | Full context/scenario text | `"The sketch shows..."` |
| `imageUrl` | URL | Optional | Link to shared image/diagram | `https://storage...` |
| `subject` | String | Yes | Subject name | `mathematics` |
| `grade` | Number | Yes | Grade level | `12` |
| `topic` | String | Yes | Topic name (must match blueprint) | `Functions & Graphs` |
| `paper` | String | Yes | Paper code | `p1`, `p2`, `p3` |
| `year` | Number | Yes | Year | `2023` |
| `season` | String | Yes | Season | `November`, `June`, `March` |
| `totalMarks` | Number | Yes | Sum of all children's marks | `13` |
| `pqpQuestionNumber` | String | Yes | Parent question number | `4.1`, `5.2` |
| `availableModes` | String | Yes | Pipe-separated modes | `pqp\|sprint\|by_topic` |

---

## 👶 Children Template

### **File:** `children.csv`

#### **Column Headers:**
```csv
id,parentId,format,questionType,answerType,questionText,correctAnswer,answerVariations,marks,cognitiveLevel,difficulty,pqpQuestionNumber,sprintHint,sprintTimeEstimate,caseSensitive,tolerance,usesParentImage
```

#### **Example Rows:**
```csv
id,parentId,format,questionType,answerType,questionText,correctAnswer,answerVariations,marks,cognitiveLevel,difficulty,pqpQuestionNumber,sprintHint,sprintTimeEstimate,caseSensitive,tolerance,usesParentImage
child_func_001_1,parent_func_001,short_answer,short_answer,coordinates,"Calculate the coordinates of D, the turning point of f.","(1, -4)","(1;-4)|(1, -4)|D(1, -4)|D(1;-4)|(1,-4)",4,Level 3,medium,4.1.1,"The turning point x-coordinate is midway between the x-intercepts. Use x = (x₁ + x₂)/2 = (-1 + 3)/2.",3,false,0,true
child_func_001_2,parent_func_001,short_answer,short_answer,equation,"Determine the equation of f in the form f(x) = ax² + bx + c.","f(x) = x² - 2x - 3","f(x) = x² - 2x - 3|f(x)=x²-2x-3|y = x² - 2x - 3|x² - 2x - 3",4,Level 3,medium,4.1.2,"Use factored form: f(x) = a(x + 1)(x - 3). Substitute point C(2, 5) to find a.",4,false,0,true
child_func_001_3,parent_func_001,short_answer,short_answer,equation,"Determine the equation of g.","g(x) = 2x + 1","g(x) = 2x + 1|g(x)=2x+1|y = 2x + 1|2x + 1",5,Level 2,medium,4.1.3,"Use two points A(-1, 0) and C(2, 5). Find gradient m = (y₂ - y₁)/(x₂ - x₁), then use y = mx + k.",5,false,0,true
```

#### **Field Descriptions:**

| Field | Type | Required | Description | Example |
|-------|------|----------|-------------|---------|
| `id` | String | Yes | Unique identifier (use prefix `child_`) | `child_func_001_1` |
| `parentId` | String | Yes | Reference to parent ID | `parent_func_001` |
| `format` | String | Yes | Question format | `short_answer`, `MCQ`, `drag_drop` |
| `questionType` | String | Yes | Usually same as format | `short_answer` |
| `answerType` | String | Conditional | For short_answer only | `text`, `number`, `coordinates`, `equation` |
| `questionText` | Text | Yes | Question text | `"Calculate the coordinates..."` |
| `correctAnswer` | String | Yes | Main correct answer | `(1, -4)` or `B` for MCQ |
| `answerVariations` | String | Optional | Pipe-separated variations | `(1;-4)\|(1, -4)\|D(1, -4)` |
| `marks` | Number | Yes | Marks for this question | `4` |
| `cognitiveLevel` | String | Yes | Cognitive level | `Level 1`, `Level 2`, `Level 3`, `Level 4` |
| `difficulty` | String | Yes | Difficulty level | `easy`, `medium`, `hard` |
| `pqpQuestionNumber` | String | Yes | Child question number | `4.1.1`, `4.1.2` |
| `sprintHint` | Text | Optional | Hint for Sprint mode | `"Use the formula..."` |
| `sprintTimeEstimate` | Number | Optional | Estimated time (minutes) | `3` |
| `caseSensitive` | Boolean | Yes | Case sensitive answer | `true`, `false` |
| `tolerance` | Number | Yes | Numeric tolerance | `0`, `0.01` |
| `usesParentImage` | Boolean | Yes | Uses parent's image | `true`, `false` |

---

## 🎨 MCQ Children Template

### **File:** `children_mcq.csv`

For MCQ questions, add these additional columns:

```csv
id,parentId,format,questionType,questionText,optionA,optionB,optionC,optionD,correctAnswer,marks,cognitiveLevel,difficulty,pqpQuestionNumber,sprintHint,sprintTimeEstimate,usesParentImage
child_stats_001_1,parent_stats_001,MCQ,MCQ,"What is the mean of the dataset?",15.5,16.2,17.8,18.3,B,3,Level 2,easy,3.1.1,"Add all values and divide by the count.",2,true
```

---

## 🛠️ Import Script (To Be Created)

### **File:** `functions/tools/import-from-spreadsheet.js`

**Usage:**
```bash
node functions/tools/import-from-spreadsheet.js parents.csv children.csv
```

**Script Features:**
1. Parse CSV files
2. Validate all required fields
3. Check parent-child relationships
4. Verify topic names match blueprints
5. Calculate and validate total marks
6. Upload to Firestore in batches
7. Generate error report if validation fails

**Validation Rules:**
- ✅ Every child must reference an existing parent
- ✅ Parent's `totalMarks` must equal sum of children's marks
- ✅ No `format` field on parents
- ✅ All children must have `format` field
- ✅ Topic names must match blueprint exactly
- ✅ PQP numbering must follow pattern (4.1 → 4.1.1, 4.1.2)
- ✅ If `usesParentImage: true`, parent must have `imageUrl`

---

## 📋 Quick Start Guide

### **Step 1: Prepare Your Data**
1. Download templates: `parents.csv` and `children.csv`
2. Fill in one parent row per scenario/context
3. Fill in child rows for each sub-question
4. Ensure `parentId` in children matches `id` in parents

### **Step 2: Upload Images (if needed)**
1. Go to Firebase Console → Storage
2. Upload images to `questions/` folder
3. Copy public URL
4. Paste URL into `imageUrl` column in parents.csv

### **Step 3: Validate**
1. Check all required fields are filled
2. Verify topic names match exactly: `Functions & Graphs`, `Trigonometry`, etc.
3. Confirm parent's `totalMarks` = sum of children's `marks`
4. Ensure PQP numbering is correct (4.1, 4.1.1, 4.1.2)

### **Step 4: Import**
```bash
cd functions
node tools/import-from-spreadsheet.js path/to/parents.csv path/to/children.csv
```

### **Step 5: Verify**
1. Check Firestore Console for new documents
2. Test in app: Select topic → Verify parent context appears
3. Test PQP mode → Verify numbering is correct

---

## 📊 Sample Data Sets

### **Example 1: Functions & Graphs (3 children)**
**Parent:** Graph with two functions
**Children:** 
- Calculate turning point (4 marks)
- Determine equation of f (4 marks)
- Determine equation of g (5 marks)
**Total:** 13 marks

### **Example 2: Trigonometry (2 children)**
**Parent:** Triangle diagram with given angles
**Children:**
- Calculate missing side (5 marks)
- Find area of triangle (5 marks)
**Total:** 10 marks

### **Example 3: Statistics (4 children)**
**Parent:** Data table with values
**Children:**
- Calculate mean (3 marks)
- Calculate median (3 marks)
- Calculate standard deviation (4 marks)
- Interpret results (5 marks)
**Total:** 15 marks

---

## 🚨 Common Errors

### **Error: Parent not found**
```
Child 'child_func_001_1' references parent 'parent_func_001' which doesn't exist.
```
**Fix:** Ensure parent ID in children.csv exactly matches ID in parents.csv

### **Error: Marks mismatch**
```
Parent 'parent_func_001' has totalMarks=13 but children sum to 12.
```
**Fix:** Update parent's `totalMarks` or fix children's individual `marks`

### **Error: Invalid topic**
```
Topic 'Functions and Graphs' doesn't match blueprint. Did you mean 'Functions & Graphs'?
```
**Fix:** Use exact topic name from blueprint (with ampersand &, not "and")

### **Error: Missing format**
```
Child 'child_func_001_1' is missing required field 'format'.
```
**Fix:** Add format column: `short_answer`, `MCQ`, or `drag_drop`

---

## 💡 Best Practices

1. **Naming Convention:**
   - Parents: `parent_<topic_abbrev>_<number>` (e.g., `parent_func_001`)
   - Children: `child_<parent_abbrev>_<parent_num>_<child_num>` (e.g., `child_func_001_1`)

2. **Image Management:**
   - Upload to Firebase Storage first
   - Use descriptive filenames: `functions_graph_001.png`
   - Use parent's image for all children when possible

3. **Answer Variations:**
   - Include common student responses
   - Use pipe `|` separator: `(1, -4)|(1;-4)|D(1, -4)`
   - Consider spacing variations

4. **Sprint Hints:**
   - Be helpful but not giving away the answer
   - Reference formulas or concepts
   - Keep under 200 characters

5. **Batch Size:**
   - Upload max 100 parent-child sets at a time
   - Allows for easier error tracking
   - Reduces risk of partial uploads

---

**Last Updated:** October 3, 2025  
**Version:** 1.0  
**Maintained by:** Kinetix Engineering Solutions
