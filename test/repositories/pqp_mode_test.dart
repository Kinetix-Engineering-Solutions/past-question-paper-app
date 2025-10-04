import 'package:flutter_test/flutter_test.dart';
import 'package:past_question_paper_v1/model/question.dart';

void main() {
  group('PQP Mode Tests', () {
    test('should parse PQP question data correctly', () {
      // Test data from our JSON structure
      final testData = {
        'questionId': 'math_g12_func_transform_001',
        'topicId': 'exponential_functions',
        'questionType': 'short_answer',
        'format': 'short_answer',
        'availableInModes': ['pqp', 'sprint'],
        'pqpData': {
          'paper': 'p1',
          'season': 'November',
          'year': 2023,
          'questionNumber': '4.5',
          'parentQuestionId': 'math_g12_asymptote_exp_001',
          'questionText':
              'Write down the equation of g if it is given that g(x) = f(x) + 4',
          'marks': 1,
        },
        'sprintData': {
          'questionText':
              'Given that f(x) = 2^x - 4, write down the equation of g if it is given that g(x) = f(x) + 4',
          'providedContext': {
            'f(x)': '2^x - 4',
            'transformation': 'g(x) = f(x) + 4',
            'context': 'Function transformation - vertical shift',
          },
          'marks': 2,
          'canRandomize': true,
          'difficulty': 'easy',
          'estimatedTime': 2,
          'tags': [
            'function_transformations',
            'exponential_functions',
            'vertical_shifts',
          ],
        },
        'correctAnswer': 'g(x) = 2^x',
        'answerVariations': ['g(x) = 2^x', 'g(x)=2^x', 'y = 2^x', '2^x'],
        'caseSensitive': false,
        'answerType': 'equation',
        'grade': 12,
        'subject': 'mathematics',
        'topic': 'exponential_functions',
        'cognitiveLevel': 'Level 1',
        'workingSteps': [
          'Given: g(x) = f(x) + 4',
          'Given: f(x) = 2^x - 4',
          'Substitute: g(x) = (2^x - 4) + 4',
          'Simplify: g(x) = 2^x - 4 + 4',
          'Therefore: g(x) = 2^x',
        ],
        'hints': [
          'Substitute f(x) = 2^x - 4 into g(x) = f(x) + 4',
          'Simplify the expression by combining like terms',
        ],
        'explanation':
            'By substituting f(x) = 2^x - 4 into g(x) = f(x) + 4, we get g(x) = (2^x - 4) + 4 = 2^x',
        'points': 2,
        'timeAllocation': 120,
        'showWorking': true,
        'options': [],
        'correctOrder': [],
      };

      // Convert test data to Question.fromMap format
      final pqpData = testData['pqpData'] as Map<String, dynamic>;
      final Map<String, dynamic> questionMap = {
        'id': testData['questionId'],
        'questionText': pqpData['questionText'],
        'format': testData['format'],
        'options': testData['options'],
        'correctAnswer': testData['correctAnswer'],
        'correctOrder': testData['correctOrder'],
        'explanation': testData['explanation'],
        'marks': pqpData['marks'],
        'timeAllocation': testData['timeAllocation'],
        'dragItems': null,
        'dragTargets': null,
        'imageUrl': null,
        'optionImages': null,
        'availableInModes': testData['availableInModes'],
        'pqpData': testData['pqpData'],
        'sprintData': testData['sprintData'],
        'subject': testData['subject'],
        'paper': pqpData['paper'],
        'grade': testData['grade'],
        'topic': testData['topic'],
        'cognitiveLevel': testData['cognitiveLevel'],
        'year': pqpData['year'],
        'season': pqpData['season'],
      };

      final question = Question.fromMap(questionMap);

      // Test basic question properties
      expect(question.id, equals('math_g12_func_transform_001'));
      expect(question.format, equals('short_answer'));
      expect(question.correctAnswer, equals('g(x) = 2^x'));

      // Test dual mode support
      expect(question.supportsPQP, isTrue);
      expect(question.supportsSprint, isTrue);

      // Test PQP specific data
      expect(question.pqpData, isNotNull);
      expect(question.pqpData?.paper, equals('p1'));
      expect(question.pqpData?.season, equals('November'));
      expect(question.pqpData?.year, equals(2023));
      expect(question.pqpData?.questionNumber, equals('4.5'));
      expect(question.pqpData?.marks, equals(1));

      // Test parent relationship (Option 3 structure)
      expect(question.hasParent, isTrue);
      expect(question.parentQuestionId, equals('math_g12_asymptote_exp_001'));

      // Test Sprint specific data
      expect(question.sprintData, isNotNull);
      expect(question.sprintData?.marks, equals(2));
      expect(question.sprintData?.difficulty, equals('easy'));
      expect(question.sprintData?.canRandomize, isTrue);
      expect(question.sprintData?.estimatedTime, equals(2));

      // Test utility methods
      expect(
        question.getPQPQuestionText(),
        equals(
          'Write down the equation of g if it is given that g(x) = f(x) + 4',
        ),
      );
      expect(
        question.getSprintQuestionText(),
        contains('Given that f(x) = 2^x - 4'),
      );
      expect(question.getPQPMarks(), equals(1));
      expect(question.getSprintMarks(), equals(2));

      // Test Sprint utility methods
      expect(question.canRandomize, isTrue);
      expect(question.difficulty, equals('easy'));
      expect(question.estimatedTime, equals(2));
      expect(question.tags, contains('function_transformations'));
      expect(question.providedContext, isNotNull);
      expect(question.providedContext?['f(x)'], equals('2^x - 4'));

      print('✅ PQP question parsing works correctly');
    });

    test('should handle questions without PQP data', () {
      // Test data without PQP support
      final testData = {
        'questionId': 'legacy_question_001',
        'questionType': 'multiple-choice',
        'format': 'MCQ',
        'questionText': 'What is 2 + 2?',
        'options': ['2', '3', '4', '5'],
        'correctAnswer': '4',
        'correctOrder': [],
        'explanation': '2 + 2 equals 4',
        'marks': 1,
        'timeAllocation': 60,
        'subject': 'mathematics',
        'paper': 'p1',
        'grade': 12,
        'topic': 'arithmetic',
        'cognitiveLevel': 'Level 1',
        'year': 2023,
        'season': 'June',
      };

      final question = Question.fromMap(testData);

      // Test that question doesn't support dual modes
      expect(question.supportsPQP, isFalse);
      expect(question.supportsSprint, isFalse);
      expect(question.pqpData, isNull);
      expect(question.sprintData, isNull);

      // Test fallback behavior
      expect(question.getPQPQuestionText(), equals('What is 2 + 2?'));
      expect(question.getSprintQuestionText(), equals('What is 2 + 2?'));
      expect(question.getPQPMarks(), equals(1));
      expect(question.getSprintMarks(), equals(1));

      // Test that question has no parent (standalone question)
      expect(question.hasParent, isFalse);
      expect(question.parentQuestionId, isNull);

      print('✅ Legacy question handling works correctly');
    });
  });
}
