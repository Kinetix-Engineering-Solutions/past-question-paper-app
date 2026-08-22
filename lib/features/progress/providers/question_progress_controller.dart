import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/features/progress/domain/question_progress.dart';
import 'package:past_question_paper_v1/features/progress/providers/progress_providers.dart';

final class QuestionProgressController
    extends AutoDisposeFamilyAsyncNotifier<QuestionProgress?, String> {
  @override
  FutureOr<QuestionProgress?> build(String questionId) async {
    final repository = ref.watch(progressRepositoryProvider);

    try {
      return await repository.getQuestionProgress(questionId);
    } on StateError {
      // Guests can study without saving progress.
      return null;
    }
  }

  Future<void> setStatus(QuestionProgressStatus status) async {
    if (state.isLoading) {
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref
          .read(progressRepositoryProvider)
          .setQuestionProgress(questionId: arg, status: status),
    );
  }

  Future<void> retry() async {
    ref.invalidateSelf();
    await future;
  }
}
