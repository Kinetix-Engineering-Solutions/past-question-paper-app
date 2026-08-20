import 'package:flutter_test/flutter_test.dart';
import 'package:past_question_paper_v1/core/pagination/paged_response.dart';
import 'package:past_question_paper_v1/features/questions/data/models/question.dart';

void main() {
  final validQuestionJson = <String, Object?>{
    'id': 'question-id',
    'questionNumber': '1.2',
    'displayOrder': 2,
    'examYear': 2022,
    'examSeason': 'May-June',
    'paperNumber': 1,
    'questionImageUrl': 'https://example.com/question.webp',
    'memoImageUrl': 'https://example.com/memo.webp',
    'topicId': 'topic-id',
    'topicName': 'Newtonian Mechanics',
    'topicSlug': 'newtonian-mechanics',
    'grade': 12,
    'subjectId': 'subject-id',
    'subjectName': 'Physical Sciences',
    'subjectSlug': 'physical-sciences',
  };

  test('maps a valid question response', () {
    final question = Question.fromJson(validQuestionJson);

    expect(question.questionNumber, '1.2');
    expect(question.examYear, 2022);
    expect(question.questionImageUrl.host, 'example.com');
  });

  test('rejects an invalid question image URL', () {
    final json = {...validQuestionJson, 'questionImageUrl': '/question.webp'};

    expect(() => Question.fromJson(json), throwsFormatException);
  });

  test('maps a valid paged question response', () {
    final response = PagedResponse<Question>.fromJson({
      'items': [validQuestionJson],
      'page': 1,
      'pageSize': 20,
      'totalCount': 1,
      'totalPages': 1,
    }, Question.fromJson);

    expect(response.items, hasLength(1));
    expect(response.totalCount, 1);
    expect(response.hasNextPage, isFalse);
  });

  test('rejects a malformed paged response', () {
    expect(
      () => PagedResponse<Question>.fromJson({
        'items': [],
        'page': 1,
      }, Question.fromJson),
      throwsFormatException,
    );
  });
}
