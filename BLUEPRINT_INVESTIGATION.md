# Blueprint Investigation - Topic & Cognitive Level Selection

## 🔍 Investigation Summary

### Current Blueprint Structure (Working Example):
```javascript
{
  paper: "p1",
  subject: "mathematics", 
  grade: 12,
  totalMarks: 150,
  topics: {
    "Pattern & Sequences": 25,           // Should get ~17% of questions
    "Functions & Graphs": 35,            // Should get ~23% of questions  
    "Differential Calculus": 35,         // Should get ~23% of questions
    "Algebra, Equations & Inequalities": 25,  // Should get ~17% of questions
    "Probability": 25,                   // Should get ~17% of questions
    "Finance, Growth & Decay": 15        // Should get ~10% of questions
  },
  cognitiveLevels: {
    "Level 1": 0.2,   // 20% of questions
    "Level 2": 0.35,  // 35% of questions
    "Level 3": 0.3,   // 30% of questions
    "Level 4": 0.15   // 15% of questions
  }
}
```

## ❌ Issues Found:

### 1. **No Topic-Based Selection**
**Current Code:**
```javascript
// Only basic filtering - NO topic consideration
const query = buildQuestionQuery({
  grade, subject, paper, year, season, topic, limit
});
```

**Problem:** The `topic` parameter is a single value, but blueprint has multiple topics with mark allocations.

### 2. **No Cognitive Level Filtering**
**Current Code:**
```javascript
// No cognitive level filtering at all
function buildQuestionQuery(params) {
  // Missing: cognitiveLevel filtering
}
```

**Problem:** Questions are selected randomly regardless of cognitive level requirements.

### 3. **Random Selection Instead of Strategic**
**Current Code:**
```javascript
const selectedQuestions = selectRandomQuestions(questionData, totalQuestions);
```

**Problem:** Should select questions to meet topic allocation and cognitive level distribution.

## 🎯 Required Implementation:

### 1. **Topic-Based Question Selection**
```javascript
// For each topic in blueprint:
for (const [topicName, marks] of Object.entries(blueprint.topics)) {
  const questionsNeeded = calculateQuestionsForTopic(marks, averageMarksPerQuestion);
  const topicQuestions = await getQuestionsByTopic(topicName, questionsNeeded);
  selectedQuestions.push(...topicQuestions);
}
```

### 2. **Cognitive Level Balancing**
```javascript
// For each cognitive level:
for (const [level, percentage] of Object.entries(blueprint.cognitiveLevels)) {
  const questionsNeeded = Math.round(totalQuestions * percentage);
  // Select questions with this cognitive level
}
```

### 3. **Smart Question Distribution**
- Calculate questions needed per topic based on marks allocation
- Balance cognitive levels across selected questions
- Optimize for total marks requirement
- Fallback to similar topics if insufficient questions

## 🧪 Test Scenarios Needed:

1. **Topic Distribution Test**: Verify questions are selected from each topic according to blueprint allocation
2. **Cognitive Level Test**: Verify the distribution matches blueprint percentages  
3. **Marks Optimization Test**: Verify total marks match blueprint requirements
4. **Insufficient Questions Test**: Verify graceful degradation when database lacks questions

## 🔧 Implementation Plan:

1. **Enhanced Database Queries**: Add topic and cognitive level filtering
2. **Smart Selection Algorithm**: Replace random selection with strategic selection
3. **Distribution Validation**: Ensure selected questions match blueprint requirements
4. **Fallback Mechanisms**: Handle cases with insufficient questions per topic/level
