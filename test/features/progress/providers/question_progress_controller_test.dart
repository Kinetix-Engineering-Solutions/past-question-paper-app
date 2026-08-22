import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:past_question_paper_v1/features/progress/data/progress_repository.dart';
import 'package:past_question_paper_v1/features/progress/domain/question_progress.dart';
import 'package:past_question_paper_v1/features/progress/providers/progress_providers.dart';

void main() {
  const questionId = 'question-1';
  const topicId = 'topic-1';

  QuestionProgress progress(
    QuestionProgressStatus status, {
    int reviewCount = 1,
  }) {
    final timestamp = DateTime.utc(2026, 8, 22);

    return QuestionProgress(
      questionId: questionId,
      topicId: topicId,
      status: status,
      reviewCount: reviewCount,
      firstReviewedAt: timestamp,
      lastReviewedAt: timestamp,
    );
  }

  test('loads existing question progress', () async {
    final repository = FakeProgressRepository(
      existingProgress: progress(QuestionProgressStatus.needsReview),
    );

    final container = ProviderContainer(
      overrides: [progressRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      questionProgressControllerProvider(questionId).future,
    );

    expect(result?.status, QuestionProgressStatus.needsReview);
    expect(result?.reviewCount, 1);
    expect(repository.loadedQuestionId, questionId);
  });

  test('saves progress and exposes the returned result', () async {
    final savedProgress = progress(
      QuestionProgressStatus.understood,
      reviewCount: 2,
    );

    final repository = FakeProgressRepository(savedProgress: savedProgress);

    final container = ProviderContainer(
      overrides: [progressRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final provider = questionProgressControllerProvider(questionId);

    await container.read(provider.future);

    await container
        .read(provider.notifier)
        .setStatus(QuestionProgressStatus.understood);

    final result = container.read(provider).value;

    expect(result?.status, QuestionProgressStatus.understood);
    expect(result?.reviewCount, 2);
    expect(repository.savedQuestionId, questionId);
    expect(repository.savedStatus, QuestionProgressStatus.understood);
    expect(repository.saveCount, 1);
  });
}

final class FakeProgressRepository implements ProgressRepository {
  FakeProgressRepository({this.existingProgress, this.savedProgress});

  final QuestionProgress? existingProgress;
  final QuestionProgress? savedProgress;

  String? loadedQuestionId;
  String? savedQuestionId;
  QuestionProgressStatus? savedStatus;
  int saveCount = 0;

  @override
  Future<List<String>> getQuestionIdsByStatus({
    required String userId,
    required QuestionProgressStatus status,
  }) async {
    return const [];
  }

  @override
  Future<QuestionProgress?> getQuestionProgress(String questionId) async {
    loadedQuestionId = questionId;
    return existingProgress;
  }

  @override
  Future<QuestionProgress> setQuestionProgress({
    required String questionId,
    required QuestionProgressStatus status,
  }) async {
    saveCount++;
    savedQuestionId = questionId;
    savedStatus = status;

    final result = savedProgress;

    if (result == null) {
      throw StateError('No fake saved progress configured.');
    }

    return result;
  }
}
