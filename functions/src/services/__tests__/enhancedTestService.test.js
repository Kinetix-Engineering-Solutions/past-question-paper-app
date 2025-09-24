const {
  selectBestQuestionsForTopic,
  calculateVarietyScore,
  selectQuestionsKnapsackStyle,
  optimizeMarksWithSwaps,
  calculateDetailedComplianceReport,
  balanceCognitiveLevels
} = require('../enhancedTestService');

// Mock external dependencies
jest.mock('../databaseService', () => ({
  buildEnhancedQuestionQuery: jest.fn(),
  executeQuestionQuery: jest.fn(),
  fetchBlueprint: jest.fn()
}));

jest.mock('../helpers/dataHelpers', () => ({
  safeArray: jest.fn(arr => Array.isArray(arr) ? arr : []),
  mapQuestionData: jest.fn(doc => doc),
  normalizePaperFormat: jest.fn(format => format.toLowerCase())
}));

describe('Enhanced Test Service', () => {
  // Sample test data
  const sampleQuestions = [
    { id: '1', topic: 'Algebra', cognitiveLevel: 'Level 1', maxMarks: 5, year: 2023 },
    { id: '2', topic: 'Algebra', cognitiveLevel: 'Level 2', maxMarks: 8, year: 2022 },
    { id: '3', topic: 'Algebra', cognitiveLevel: 'Level 3', maxMarks: 10, year: 2023 },
    { id: '4', topic: 'Algebra', cognitiveLevel: 'Level 1', maxMarks: 3, year: 2021 },
    { id: '5', topic: 'Algebra', cognitiveLevel: 'Level 2', maxMarks: 7, year: 2023 },
    { id: '6', topic: 'Algebra', cognitiveLevel: 'Level 4', maxMarks: 12, year: 2022 }
  ];

  describe('selectBestQuestionsForTopic', () => {
    test('should distribute questions across cognitive levels', () => {
      const result = selectBestQuestionsForTopic(sampleQuestions, 4, 30);
      
      expect(result).toHaveLength(4);
      
      // Check that different cognitive levels are represented
      const levels = result.map(q => q.cognitiveLevel);
      const uniqueLevels = [...new Set(levels)];
      expect(uniqueLevels.length).toBeGreaterThan(1);
    });

    test('should add variety scores to selected questions', () => {
      const result = selectBestQuestionsForTopic(sampleQuestions, 3, 20);
      
      result.forEach(question => {
        expect(question).toHaveProperty('varietyScore');
        expect(typeof question.varietyScore).toBe('number');
      });
    });

    test('should return all questions if fewer available than needed', () => {
      const result = selectBestQuestionsForTopic(sampleQuestions.slice(0, 2), 5, 30);
      expect(result).toHaveLength(2);
    });

    test('should introduce randomness through shuffling', () => {
      // Run multiple times to check for variation
      const results = [];
      for (let i = 0; i < 5; i++) {
        const result = selectBestQuestionsForTopic(sampleQuestions, 3, 20);
        results.push(result.map(q => q.id).join(','));
      }
      
      // Should have some variation in selection order
      const uniqueResults = [...new Set(results)];
      expect(uniqueResults.length).toBeGreaterThan(1);
    });
  });

  describe('calculateVarietyScore', () => {
    test('should penalize over-represented cognitive levels', () => {
      const selectedQuestions = [
        { cognitiveLevel: 'Level 1', maxMarks: 5, year: 2023 },
        { cognitiveLevel: 'Level 1', maxMarks: 5, year: 2023 },
        { cognitiveLevel: 'Level 2', maxMarks: 8, year: 2022 }
      ];
      
      const level1Question = { cognitiveLevel: 'Level 1', maxMarks: 5, year: 2023 };
      const level3Question = { cognitiveLevel: 'Level 3', maxMarks: 10, year: 2023 };
      
      const score1 = calculateVarietyScore(level1Question, selectedQuestions);
      const score3 = calculateVarietyScore(level3Question, selectedQuestions);
      
      // Level 3 should score higher (better variety) than Level 1
      expect(score3).toBeGreaterThan(score1);
    });

    test('should reward recent years', () => {
      const oldQuestion = { cognitiveLevel: 'Level 1', maxMarks: 5, year: 2020 };
      const newQuestion = { cognitiveLevel: 'Level 1', maxMarks: 5, year: 2023 };
      
      const oldScore = calculateVarietyScore(oldQuestion, []);
      const newScore = calculateVarietyScore(newQuestion, []);
      
      expect(newScore).toBeGreaterThan(oldScore);
    });

    test('should penalize similar mark values', () => {
      const selectedQuestions = [
        { cognitiveLevel: 'Level 2', maxMarks: 5, year: 2023 },
        { cognitiveLevel: 'Level 3', maxMarks: 5, year: 2023 }
      ];
      
      const similarMarksQ = { cognitiveLevel: 'Level 1', maxMarks: 5, year: 2023 };
      const differentMarksQ = { cognitiveLevel: 'Level 1', maxMarks: 10, year: 2023 };
      
      const similarScore = calculateVarietyScore(similarMarksQ, selectedQuestions);
      const differentScore = calculateVarietyScore(differentMarksQ, selectedQuestions);
      
      expect(differentScore).toBeGreaterThan(similarScore);
    });
  });

  describe('selectQuestionsKnapsackStyle', () => {
    test('should select questions within tolerance range', () => {
      const targetMarks = 25;
      const tolerance = 0.2; // 20%
      const result = selectQuestionsKnapsackStyle(sampleQuestions, targetMarks, tolerance);
      
      const totalMarks = result.reduce((sum, q) => sum + q.marks, 0);
      const minMarks = targetMarks * (1 - tolerance);
      const maxMarks = targetMarks * (1 + tolerance);
      
      expect(totalMarks).toBeGreaterThanOrEqual(minMarks);
      expect(totalMarks).toBeLessThanOrEqual(maxMarks);
    });

    test('should prefer higher-mark questions in greedy approach', () => {
      const questions = [
        { id: '1', maxMarks: 3, marks: 3 },
        { id: '2', maxMarks: 10, marks: 10 },
        { id: '3', maxMarks: 7, marks: 7 }
      ];
      
      const result = selectQuestionsKnapsackStyle(questions, 15, 0.1);
      
      // Should prefer the 10-mark question
      expect(result.some(q => q.id === '2')).toBe(true);
    });

    test('should return empty array for empty input', () => {
      const result = selectQuestionsKnapsackStyle([], 25, 0.2);
      expect(result).toEqual([]);
    });
  });

  describe('optimizeMarksWithSwaps', () => {
    test('should improve marks allocation through swaps', () => {
      const selected = [
        { id: '1', marks: 15 },
        { id: '2', marks: 5 }
      ]; // Total: 20 marks
      
      const available = [
        { id: '3', marks: 8 },
        { id: '4', marks: 12 }
      ];
      
      const target = 25;
      const tolerance = 0.2;
      
      const result = optimizeMarksWithSwaps(selected, available, target, tolerance);
      const resultMarks = result.reduce((sum, q) => sum + q.marks, 0);
      const originalMarks = selected.reduce((sum, q) => sum + q.marks, 0);
      
      // Should be closer to target
      expect(Math.abs(resultMarks - target)).toBeLessThanOrEqual(Math.abs(originalMarks - target));
    });

    test('should maintain selection if already optimal', () => {
      const selected = [
        { id: '1', marks: 12 },
        { id: '2', marks: 13 }
      ]; // Total: 25 marks (perfect for target)
      
      const available = [
        { id: '3', marks: 8 },
        { id: '4', marks: 20 }
      ];
      
      const target = 25;
      const tolerance = 0.1;
      
      const result = optimizeMarksWithSwaps(selected, available, target, tolerance);
      
      // Should keep original selection as it's already optimal
      expect(result).toEqual(selected);
    });
  });

  describe('calculateDetailedComplianceReport', () => {
    const blueprint = {
      topics: {
        'Algebra': 50,
        'Functions': 30,
        'Geometry': 20
      },
      cognitiveLevels: {
        'Level 1': 0.3,
        'Level 2': 0.4,
        'Level 3': 0.2,
        'Level 4': 0.1
      },
      totalMarks: 100
    };

    test('should calculate topic compliance correctly', () => {
      const questions = [
        { allocatedTopic: 'Algebra', maxMarks: 45, cognitiveLevel: 'Level 1' },
        { allocatedTopic: 'Functions', maxMarks: 35, cognitiveLevel: 'Level 2' },
        { allocatedTopic: 'Geometry', maxMarks: 20, cognitiveLevel: 'Level 3' }
      ];

      const report = calculateDetailedComplianceReport(questions, blueprint);
      
      expect(report.topic).toHaveProperty('compliant');
      expect(report.topic).toHaveProperty('deviations');
      expect(report.topic.deviations).toHaveLength(3);
      
      // Check specific topic deviation
      const algebraDeviation = report.topic.deviations.find(d => d.topic === 'Algebra');
      expect(algebraDeviation.target).toBe(50);
      expect(algebraDeviation.actual).toBe(45);
      expect(algebraDeviation.deviation).toBe(-5);
    });

    test('should calculate cognitive level compliance correctly', () => {
      const questions = [
        { cognitiveLevel: 'Level 1', maxMarks: 10 },
        { cognitiveLevel: 'Level 1', maxMarks: 10 },
        { cognitiveLevel: 'Level 1', maxMarks: 10 }, // 3 Level 1 = 30%
        { cognitiveLevel: 'Level 2', maxMarks: 10 },
        { cognitiveLevel: 'Level 2', maxMarks: 10 },
        { cognitiveLevel: 'Level 2', maxMarks: 10 },
        { cognitiveLevel: 'Level 2', maxMarks: 10 }, // 4 Level 2 = 40%
        { cognitiveLevel: 'Level 3', maxMarks: 10 },
        { cognitiveLevel: 'Level 3', maxMarks: 10 }, // 2 Level 3 = 20%
        { cognitiveLevel: 'Level 4', maxMarks: 10 } // 1 Level 4 = 10%
      ];

      const report = calculateDetailedComplianceReport(questions, blueprint);
      
      expect(report.cognitive).toHaveProperty('compliant');
      expect(report.cognitive).toHaveProperty('deviations');
      expect(report.cognitive.deviations).toHaveLength(4);
      
      // Check Level 1 compliance (should be perfect)
      const level1Deviation = report.cognitive.deviations.find(d => d.level === 'Level 1');
      expect(level1Deviation.targetPct).toBe(30);
      expect(level1Deviation.actualPct).toBe(30);
      expect(level1Deviation.compliant).toBe(true);
    });

    test('should calculate marks compliance correctly', () => {
      const questions = [
        { maxMarks: 50 },
        { maxMarks: 30 },
        { maxMarks: 15 } // Total: 95 marks (vs 100 target)
      ];

      const report = calculateDetailedComplianceReport(questions, blueprint);
      
      expect(report.marks.target).toBe(100);
      expect(report.marks.actual).toBe(95);
      expect(report.marks.deviation).toBe(-5);
      expect(report.marks.deviationPct).toBe(-5);
      expect(report.marks.compliant).toBe(true); // Within 20% tolerance
    });

    test('should calculate overall compliance score', () => {
      const questions = [
        { allocatedTopic: 'Algebra', maxMarks: 50, cognitiveLevel: 'Level 1' },
        { allocatedTopic: 'Functions', maxMarks: 30, cognitiveLevel: 'Level 2' },
        { allocatedTopic: 'Geometry', maxMarks: 20, cognitiveLevel: 'Level 3' }
      ];

      const report = calculateDetailedComplianceReport(questions, blueprint);
      
      expect(report.overall).toHaveProperty('compliant');
      expect(report.overall).toHaveProperty('score');
      expect(report.overall.score).toBeGreaterThanOrEqual(0);
      expect(report.overall.score).toBeLessThanOrEqual(1);
    });

    test('should identify non-compliant cases', () => {
      const questions = [
        { allocatedTopic: 'Algebra', maxMarks: 80, cognitiveLevel: 'Level 1' }, // Way over allocation
        { allocatedTopic: 'Functions', maxMarks: 10, cognitiveLevel: 'Level 1' }, // Way under allocation
        { allocatedTopic: 'Geometry', maxMarks: 5, cognitiveLevel: 'Level 1' }   // Way under allocation
      ];

      const report = calculateDetailedComplianceReport(questions, blueprint);
      
      expect(report.topic.compliant).toBe(false);
      expect(report.cognitive.compliant).toBe(false); // All Level 1
      expect(report.overall.compliant).toBe(false);
    });
  });

  // Note: balanceCognitiveLevels tests would require mocking async database operations
  // and are more suitable for integration tests
  describe('balanceCognitiveLevels (unit tests)', () => {
    test('should export the function', () => {
      expect(typeof balanceCognitiveLevels).toBe('function');
    });

    // Additional unit tests would require extensive mocking of database operations
    // These are better suited for integration tests with actual database
  });
});
