# South African Step-Based Marking System for Drag-and-Drop Ordering

## Overview

This implementation aligns the drag-and-drop ordering grading system with South African educational marking guidelines, where calculation and procedural questions award marks for each correctly completed step.

## Key Principles

### 1. **Equal Step Weighting**
- Each step in the sequence has equal mark value
- Formula: `marksPerStep = totalMarks ÷ numberOfSteps`
- Students receive credit for each correctly positioned step

### 2. **Direct Step-Based Calculation**
- No complex percentage calculations
- No rounding errors from proportional scoring
- Transparent and predictable marking

### 3. **Partial Credit**
- Students get marks for partially correct sequences
- Encourages step-by-step problem solving
- Aligns with SA pedagogical principles

## Implementation Details

### Grading Function Changes

**Before (Proportional Marking):**
```javascript
const percentage = correctCount / totalSteps;
const marksAwarded = Math.round(maxMarks * percentage);
```

**After (SA Step-Based Marking):**
```javascript
const marksPerStep = maxMarks / totalSteps;
const marksAwarded = correctCount * marksPerStep;
```

### Detailed Result Structure

Each step now includes individual mark allocation:
```javascript
detailedResults: [
  {
    stepPosition: 1,
    userAnswer: "identify",
    correctAnswer: "identify", 
    isCorrect: true,
    marksAwarded: 1.0,
    marksAvailable: 1.0
  },
  // ... more steps
]
```

## Examples

### Example 1: 4-Mark Mathematics Question
```
Question: Solve 3x + 12 = 21
Steps: ["identify", "rearrange", "calculate", "solve"]
Marks per step: 4 ÷ 4 = 1 mark

Student A: ["identify", "rearrange", "calculate", "solve"] → 4/4 = 4 marks
Student B: ["identify", "rearrange", "wrong", "solve"] → 3/4 = 3 marks  
Student C: ["wrong", "rearrange", "calculate", "solve"] → 3/4 = 3 marks
```

### Example 2: 6-Mark Physics Question  
```
Question: Calculate projectile motion time
Steps: ["analyze", "formula", "substitute", "calculate"]
Marks per step: 6 ÷ 4 = 1.5 marks

Student: ["analyze", "formula", "wrong", "calculate"] → 3/4 = 4.5 marks
```

### Example 3: 3-Mark Chemistry Question
```
Question: Prepare standard solution
Steps: ["weigh", "dissolve", "transfer", "dilute"] 
Marks per step: 3 ÷ 4 = 0.75 marks

Student: ["weigh", "dissolve", "transfer", "wrong"] → 3/4 = 2.25 marks
```

## Advantages Over Previous System

### Educational Benefits
- ✅ **Clear expectations**: Students know each step has equal value
- ✅ **Encourages process**: Rewards methodical problem-solving
- ✅ **Partial credit**: No "all-or-nothing" penalty
- ✅ **SA alignment**: Matches traditional marking schemes

### Technical Benefits  
- ✅ **No rounding errors**: Direct calculation eliminates Math.round() issues
- ✅ **Transparent scoring**: Simple multiplication, not percentage conversion
- ✅ **Consistent results**: Same input always produces same output
- ✅ **Flexible marks**: Works with any total marks and step count

### Teacher Benefits
- ✅ **Easy to explain**: Students understand the scoring immediately
- ✅ **Fair assessment**: Each logical step receives appropriate credit
- ✅ **Consistent grading**: Automated system follows SA guidelines exactly
- ✅ **Detailed feedback**: Shows exactly which steps were correct/incorrect

## Pass Threshold

The system uses a **50% threshold** for marking questions as "correct":
- Aligns with typical SA pass requirements
- Lower than the previous 80% threshold for ordering questions
- More appropriate for step-based assessment

## Comparison: Old vs New System

| Scenario | Old System (%) | New System (Steps) | Marks |
|----------|----------------|-------------------|-------|
| 4 marks, 4 steps, 4 correct | 100% → 4 marks | 4 × 1.0 = 4 marks | Same ✅ |
| 4 marks, 4 steps, 3 correct | 75% → 3 marks | 3 × 1.0 = 3 marks | Same ✅ |
| 6 marks, 4 steps, 3 correct | 75% → 5 marks | 3 × 1.5 = 4.5 marks | More accurate ✅ |
| 3 marks, 4 steps, 2 correct | 50% → 2 marks | 2 × 0.75 = 1.5 marks | More precise ✅ |

## Configuration

### Question Setup
Ensure questions have:
```dart
Question {
  marks: 4,  // Total marks for the question
  correctOrder: ["step1", "step2", "step3", "step4"],  // Required sequence
  dragItems: [
    DragItem(id: "step1", text: "Step 1 description"),
    // ... can include distractor steps
  ]
}
```

### Result Interpretation
```javascript
{
  questionId: "q123",
  markingMethod: "step-based",
  marksPerStep: 1.0,
  correctCount: 3,
  totalSteps: 4,
  marksAwarded: 3.0,
  maxMarks: 4,
  isCorrect: true,  // ≥50% threshold
  explanation: "Each correct step awards 1.00 marks. Total: 3/4 steps correct."
}
```

## Future Enhancements

### Possible Extensions
1. **Weighted steps**: Allow some steps to be worth more marks
2. **Method marks**: Partial credit for logical but incorrect steps  
3. **Dependency marking**: Later steps depend on earlier ones
4. **Subject-specific thresholds**: Different pass rates for different subjects

### SA Curriculum Integration
- Mathematics: Calculation procedures, algebraic manipulation
- Physical Sciences: Problem-solving methodology, formula application  
- Chemistry: Laboratory procedures, reaction mechanisms
- Accounting: Financial calculation sequences

This implementation provides a solid foundation for step-based assessment that can be extended to meet specific curriculum requirements.
