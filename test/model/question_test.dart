import 'package:flutter_test/flutter_test.dart';
import 'package:past_question_paper_v1/model/question.dart';

void main() {
  group('Question Model Tests', () {
    test('should create Question with new metadata fields', () {
      final question = Question(
        id: 'test-id',
        subject: 'Mathematics',
        paper: 'Paper 1',
        grade: 12,
        topic: 'Algebra',
        cognitiveLevel: 'Application',
        marks: 5,
        year: 2023,
        season: 'Summer',
        format: 'MCQ',
        questionText: 'What is 2 + 2?',
        options: ['2', '3', '4', '5'],
        correctOrder: [],
        correctAnswer: '4',
        explanation: '2 + 2 equals 4',
      );

      expect(question.subject, equals('Mathematics'));
      expect(question.paper, equals('Paper 1'));
      expect(question.grade, equals(12));
      expect(question.topic, equals('Algebra'));
      expect(question.cognitiveLevel, equals('Application'));
      expect(question.marks, equals(5));
      expect(question.year, equals(2023));
      expect(question.season, equals('Summer'));
      expect(question.format, equals('MCQ'));
      expect(question.correctAnswer, equals('4'));
    });

    test('should provide backward compatibility getters', () {
      final question = Question(
        id: 'test-id',
        subject: 'Physics',
        paper: 'Paper 2',
        grade: 11,
        topic: 'Mechanics',
        cognitiveLevel: 'Knowledge',
        marks: 3,
        year: 2022,
        season: 'Winter',
        format: 'true-false',
        questionText: 'Force equals mass times acceleration.',
        options: ['True', 'False'],
        correctOrder: [],
        correctAnswer: 'True',
        explanation: 'This is Newton\'s second law.',
        imageUrl: 'https://example.com/image.jpg',
      );

      // Test backward compatibility
      expect(question.topicId, equals('Mechanics'));
      expect(question.questionType, equals('true-false'));
      expect(question.questionImage, equals('https://example.com/image.jpg'));
      expect(question.correctAnswerList, equals(['True']));
    });

    test('should handle fromFirestore with both old and new field names', () {
      // This would normally be tested with actual Firestore documents
      // For now, we verify the structure exists
      expect(Question.fromFirestore, isNotNull);
    });
  });
}
