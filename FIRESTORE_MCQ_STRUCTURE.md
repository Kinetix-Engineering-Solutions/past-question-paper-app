# Firestore Multiple Choice Question Structure

## 📋 **Complete MCQ Document Structure**

### **Basic Text MCQ (No Images)**
```javascript
{
  // === Document ID ===
  // Auto-generated or custom (e.g., "mcq_math_p1_001")
  
  // === Essential Metadata ===
  "id": "mcq_math_p1_001",
  "subject": "mathematics",
  "paper": "p1",
  "grade": 12,
  "topic": "Algebra, Equations & Inequalities",
  "cognitiveLevel": "Level 2",
  "marks": 2,
  "year": 2024,
  "season": "November",
  
  // === Question Format ===
  "format": "mcq",                    // Alternative: "multiple-choice", "multipleChoice"
  "questionType": "multiple-choice",   // Legacy field for backward compatibility
  
  // === Question Content ===
  "questionText": "Solve for x: 3x + 12 = 21",
  "imageUrl": null,                    // No question image
  "questionImage": null,               // Legacy field
  
  // === Answer Options (Text Only) ===
  "options": [
    "x = 1",
    "x = 3", 
    "x = 5",
    "x = 9"
  ],
  "optionImages": null,                // No option images
  
  // === Correct Answer ===
  "correctAnswer": "x = 3",            // Single correct answer (string)
  "correctAnswerList": ["x = 3"],      // Legacy format (array)
  
  // === Additional Fields ===
  "correctOrder": [],                  // Empty for MCQ (used for drag-and-drop)
  "explanation": "3x + 12 = 21 → 3x = 9 → x = 3",
  "points": 2,                         // Legacy points field
  "timeAllocation": 60,                // Seconds allocated
  
  // === Drag & Drop Fields (Empty for MCQ) ===
  "dragItems": null,
  "dragTargets": null,
  
  // === Timestamps ===
  "createdAt": "2024-11-15T10:30:00Z",
  "updatedAt": "2024-11-15T10:30:00Z"
}
```

### **MCQ with Question Image**
```javascript
{
  "id": "mcq_math_p1_002",
  "subject": "mathematics",
  "paper": "p1",
  "grade": 12,
  "topic": "Functions & Graphs",
  "cognitiveLevel": "Level 3",
  "marks": 3,
  "year": 2024,
  "season": "November",
  
  "format": "mcq",
  "questionType": "multiple-choice",
  
  // === Question with Image ===
  "questionText": "What is the gradient of the line shown in the graph?",
  "imageUrl": "https://storage.googleapis.com/your-bucket/graphs/linear_function_001.png",
  "questionImage": "https://storage.googleapis.com/your-bucket/graphs/linear_function_001.png", // Legacy
  
  // === Text Options ===
  "options": [
    "m = 2",
    "m = -1/2",
    "m = 1/2", 
    "m = -2"
  ],
  "optionImages": null,
  
  "correctAnswer": "m = 1/2",
  "correctOrder": [],
  "explanation": "Rise over run: Δy/Δx = 2/4 = 1/2",
  "points": 3,
  "timeAllocation": 90
}
```

### **MCQ with Option Images**
```javascript
{
  "id": "mcq_math_p1_003",
  "subject": "mathematics", 
  "paper": "p1",
  "grade": 12,
  "topic": "Differential Calculus",
  "cognitiveLevel": "Level 4",
  "marks": 4,
  "year": 2024,
  "season": "November",
  
  "format": "mcq",
  "questionType": "multiple-choice",
  
  "questionText": "Which graph represents the derivative of f(x) = x²?",
  "imageUrl": "https://storage.googleapis.com/your-bucket/functions/parabola_001.png",
  
  // === Image Options ===
  "options": [
    "Option A",
    "Option B", 
    "Option C",
    "Option D"
  ],
  "optionImages": [
    "https://storage.googleapis.com/your-bucket/derivatives/linear_positive.png",
    "https://storage.googleapis.com/your-bucket/derivatives/parabola_up.png",
    "https://storage.googleapis.com/your-bucket/derivatives/linear_negative.png",
    "https://storage.googleapis.com/your-bucket/derivatives/constant.png"
  ],
  
  "correctAnswer": "Option A",
  "correctOrder": [],
  "explanation": "The derivative of x² is 2x, which is a linear function with positive slope",
  "points": 4,
  "timeAllocation": 120
}
```

## 🔧 **Field Specifications**

### **Required Fields**
- `id` (string): Unique identifier
- `subject` (string): Subject name
- `paper` (string): Paper designation (p1, p2, etc.)
- `grade` (number): Grade level (10, 11, 12)
- `topic` (string): Topic/chapter name
- `cognitiveLevel` (string): Level 1-4
- `marks` (number): Marks allocated
- `year` (number): Exam year
- `season` (string): Exam session
- `format` (string): Question type
- `questionText` (string): Question content
- `options` (array): Answer choices
- `correctAnswer` (string): Correct option

### **Optional Fields**
- `imageUrl` (string): Question image URL
- `optionImages` (array): Option image URLs
- `explanation` (string): Answer explanation
- `points` (number): Legacy points field
- `timeAllocation` (number): Time in seconds

### **Empty/Null Fields for MCQ**
- `correctOrder`: [] (empty array)
- `dragItems`: null
- `dragTargets`: null

## 🎯 **Format Variations Supported**

The system should handle these format values:
- `"mcq"`
- `"multiple-choice"`
- `"multipleChoice"`
- `"multiple_choice"`
- `"MCQ"`

## 📊 **Collection Structure**

```
questions/
├── mcq_math_p1_001     (Basic text MCQ)
├── mcq_math_p1_002     (MCQ with question image)  
├── mcq_math_p1_003     (MCQ with option images)
├── mcq_physics_p1_001  (Physics MCQ)
└── ...
```

## 🔍 **Query Examples**

### Get all MCQ questions for Math Grade 12 Paper 1:
```javascript
db.collection('questions')
  .where('subject', '==', 'mathematics')
  .where('grade', '==', 12)
  .where('paper', '==', 'p1')
  .where('format', 'in', ['mcq', 'multiple-choice', 'multipleChoice'])
```

### Get MCQ questions by topic:
```javascript
db.collection('questions')
  .where('format', '==', 'mcq')
  .where('topic', '==', 'Algebra, Equations & Inequalities')
  .where('grade', '==', 12)
```

## ⚠️ **Common Issues to Avoid**

1. **Format Inconsistency**: Use consistent format values
2. **Missing Required Fields**: Ensure all required fields are present
3. **Incorrect Data Types**: Numbers as numbers, arrays as arrays
4. **Empty Options Array**: Always provide at least 2 options
5. **Missing Correct Answer**: correctAnswer must match one of the options exactly
6. **Image URL Issues**: Ensure images are accessible and properly formatted

## 🧪 **Validation Rules**

- `options.length >= 2` (minimum 2 choices)
- `correctAnswer` must be in `options` array
- If `optionImages` provided, length must equal `options.length`
- `marks > 0`
- `grade` in [10, 11, 12]
- `cognitiveLevel` in ["Level 1", "Level 2", "Level 3", "Level 4"]
