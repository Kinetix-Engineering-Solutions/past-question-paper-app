import 'package:flutter_test/flutter_test.dart';
import 'package:past_question_paper_v1/features/discovery/data/models/subject.dart';
import 'package:past_question_paper_v1/features/discovery/data/models/topic.dart';

void main() {
  group('Subject', () {
    test('maps a valid API response', () {
      final subject = Subject.fromJson({
        'id': 'subject-id',
        'name': 'Mathematics',
        'slug': 'mathematics',
      });

      expect(subject.id, 'subject-id');
      expect(subject.name, 'Mathematics');
      expect(subject.slug, 'mathematics');
    });

    test('rejects a malformed response', () {
      expect(
        () => Subject.fromJson({'id': 'subject-id', 'name': 'Mathematics'}),
        throwsFormatException,
      );
    });
  });

  group('Topic', () {
    test('maps a valid API response', () {
      final topic = Topic.fromJson({
        'id': 'topic-id',
        'name': 'Newtonian Mechanics',
        'slug': 'newtonian-mechanics',
        'grade': 12,
        'displayOrder': 1,
        'subjectId': 'subject-id',
        'subjectName': 'Physical Sciences',
        'subjectSlug': 'physical-sciences',
        'questionCount': 2,
      });

      expect(topic.id, 'topic-id');
      expect(topic.grade, 12);
      expect(topic.subjectId, 'subject-id');
      expect(topic.questionCount, 2);
    });

    test('rejects a malformed response', () {
      expect(
        () => Topic.fromJson({
          'id': 'topic-id',
          'name': 'Newtonian Mechanics',
          'grade': 12,
        }),
        throwsFormatException,
      );
    });
  });
}
