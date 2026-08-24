import 'package:flutter_test/flutter_test.dart';
import 'package:past_question_paper_v1/core/pagination/paged_response.dart';
import 'package:past_question_paper_v1/features/questions/data/models/question.dart';
import 'package:past_question_paper_v1/features/questions/providers/question_feed.dart';

void main() {
  test('appends a new page without duplicate questions', () {
    final firstQuestion = _question(id: 'question-1', number: '1.1');

    final secondQuestion = _question(id: 'question-2', number: '1.2');

    final feed = QuestionFeed.fromPage(
      PagedResponse(
        items: [firstQuestion],
        page: 1,
        pageSize: 1,
        totalCount: 2,
        totalPages: 2,
      ),
    );

    final updatedFeed = feed.append(
      PagedResponse(
        items: [firstQuestion, secondQuestion],
        page: 2,
        pageSize: 1,
        totalCount: 2,
        totalPages: 2,
      ),
    );

    expect(updatedFeed.items, hasLength(2));
    expect(updatedFeed.items.last.id, 'question-2');
    expect(updatedFeed.hasNextPage, isFalse);
  });
}

Question _question({required String id, required String number}) {
  return Question(
    id: id,
    questionNumber: number,
    displayOrder: 1,
    examYear: 2022,
    examSeason: 'May-June',
    paperNumber: 1,
    questionImageUrl: Uri.parse('https://example.com/question.webp'),
    memoImageUrl: Uri.parse('https://example.com/memo.webp'),
    topicId: 'topic-id',
    topicName: 'Newtonian Mechanics',
    topicSlug: 'newtonian-mechanics',
    grade: 12,
    subjectId: 'subject-id',
    subjectName: 'Physical Sciences',
    subjectSlug: 'physical-sciences',
  );
}
