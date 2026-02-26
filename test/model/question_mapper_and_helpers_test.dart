import 'package:flutter_test/flutter_test.dart';
import 'package:past_question_paper_v1/features/practice/domain/entities/question.dart';

void main() {
  group('Question mapper + helper tests', () {
    test('fromMap handles correctAnswer list and dropTargets alias', () {
      final question = Question.fromMap({
        'id': 'q-1',
        'subject': 'Mathematics',
        'paper': 'Paper 1',
        'grade': 12,
        'topic': 'Algebra',
        'cognitiveLevel': 'Application',
        'marks': 5,
        'year': 2025,
        'season': 'June',
        'format': 'drag-and-drop',
        'questionText': 'Match the pairs',
        'options': <String>[],
        'correctOrder': <String>[],
        'correctAnswer': ['ignored-first-works'],
        'explanation': 'Explanation',
        'dragItems': [
          {'id': 'd1', 'text': 'Item 1'},
        ],
        'dropTargets': [
          {'id': 't1', 'text': 'Target 1', 'correctPair': 'd1'},
        ],
      });

      expect(question.correctAnswer, equals('ignored-first-works'));
      expect(question.dragTargets, isNotNull);
      expect(question.dragTargets!.first.id, equals('t1'));
      expect(question.hasDragDropData, isTrue);
      expect(question.isValidDragAndDrop, isTrue);
    });

    test('fromMap reads dual-mode and parent context data', () {
      final question = Question.fromMap({
        'id': 'q-2',
        'subject': 'Physics',
        'paper': 'Paper 2',
        'grade': 11,
        'topic': 'Mechanics',
        'cognitiveLevel': 'Knowledge',
        'marks': 4,
        'year': 2024,
        'season': 'November',
        'format': 'MCQ',
        'questionText': 'Base text',
        'options': ['A', 'B', 'C', 'D'],
        'correctOrder': <String>[],
        'correctAnswer': 'A',
        'explanation': 'exp',
        'availableInModes': ['pqp', 'sprint'],
        'pqpData': {
          'questionText': 'PQP text',
          'questionNumber': '4.2.1',
          'marks': 6,
        },
        'sprintData': {
          'questionText': 'Sprint text',
          'canRandomize': true,
          'difficulty': 'medium',
          'estimatedTime': 45,
          'tags': ['revision'],
          'providedContext': {'hint': 'use formula'},
          'marks': 3,
        },
        'usesParentImage': true,
        'parentContext': {
          'imageUrl': 'https://example.com/parent.png',
          'questionText': 'Parent text',
          'pqpData': {'questionNumber': '4.2'},
        },
      });

      expect(question.supportsPQP, isTrue);
      expect(question.supportsSprint, isTrue);
      expect(question.getPQPQuestionText(), equals('PQP text'));
      expect(question.getSprintQuestionText(), equals('Sprint text'));
      expect(question.getPQPMarks(), equals(6));
      expect(question.getSprintMarks(), equals(3));
      expect(
        question.displayImageUrl,
        equals('https://example.com/parent.png'),
      );
      expect(question.parentQuestionText, equals('Parent text'));
      expect(question.parentQuestionNumber, equals('4.2'));
      expect(question.canRandomize, isTrue);
      expect(question.difficulty, equals('medium'));
      expect(question.estimatedTime, equals(45));
      expect(question.tags, equals(['revision']));
      expect(question.providedContext?['hint'], equals('use formula'));
    });

    test(
      'toMap writes optionImages and omits options when image options exist',
      () {
        final question = Question(
          id: 'q-3',
          subject: 'Life Sciences',
          paper: 'Paper 1',
          grade: 12,
          topic: 'Genetics',
          cognitiveLevel: 'Analysis',
          marks: 2,
          year: 2023,
          season: 'June',
          format: 'mcq',
          questionText: 'Which image is correct?',
          options: ['text-a'],
          optionImages: ['gs://bucket/a.png', 'gs://bucket/b.png'],
          correctOrder: <String>[],
          correctAnswer: '0',
          explanation: 'exp',
        );

        final map = question.toMap();

        expect(
          map['optionImages'],
          equals(['gs://bucket/a.png', 'gs://bucket/b.png']),
        );
        expect(map.containsKey('options'), isFalse);
      },
    );

    test('format and option helper getters behave as expected', () {
      final question = Question(
        id: 'q-4',
        subject: 'Math',
        paper: 'P1',
        grade: 12,
        topic: 'Functions',
        cognitiveLevel: 'Understanding',
        marks: 1,
        year: 2023,
        season: 'June',
        format: 'true_false',
        questionText: 'Statement',
        options: ['True', 'False'],
        correctOrder: <String>[],
        correctAnswer: 'True',
        explanation: 'exp',
      );

      expect(question.isTrueFalse, isTrue);
      expect(question.isMCQ, isFalse);
      expect(question.hasImageOptions, isFalse);
      expect(question.useTextOptions, isTrue);
      expect(question.displayOptions, equals(['True', 'False']));
      expect(question.optionCount, equals(2));
    });

    test('hasValidOptionCount checks drag and legacy formats', () {
      final dragQuestion = Question.fromMap({
        'id': 'q-5',
        'subject': 'Math',
        'paper': 'P1',
        'grade': 12,
        'topic': 'Match',
        'cognitiveLevel': 'Application',
        'marks': 3,
        'year': 2026,
        'season': 'June',
        'format': 'drag-and-drop',
        'questionText': 'Match',
        'options': <String>[],
        'correctOrder': <String>[],
        'correctAnswer': '',
        'explanation': '',
        'dragItems': [
          {'id': 'a', 'text': 'A'},
          {'id': 'b', 'text': 'B'},
        ],
        'dragTargets': [
          {'id': '1', 'text': '1', 'correctPair': 'a'},
          {'id': '2', 'text': '2', 'correctPair': 'b'},
        ],
      });

      final legacyQuestion = Question(
        id: 'q-6',
        subject: 'Math',
        paper: 'P1',
        grade: 12,
        topic: 'Order',
        cognitiveLevel: 'Application',
        marks: 3,
        year: 2026,
        season: 'June',
        format: 'drag-and-drop',
        questionText: 'Legacy',
        options: ['A', 'B'],
        correctOrder: ['1', '2'],
        correctAnswer: '',
        explanation: '',
      );

      expect(dragQuestion.hasValidOptionCount, isTrue);
      expect(legacyQuestion.hasValidOptionCount, isTrue);
    });
  });
}
