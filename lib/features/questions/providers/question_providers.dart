import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_providers.dart';
import '../data/question_repository.dart';
import 'question_feed.dart';

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepository(apiClient: ref.watch(apiClientProvider));
});

final questionsControllerProvider =
    AsyncNotifierProvider.family<QuestionsController, QuestionFeed, String>(
      QuestionsController.new,
    );

class QuestionsController extends FamilyAsyncNotifier<QuestionFeed, String> {
  late String _topicId;

  @override
  Future<QuestionFeed> build(String topicId) async {
    _topicId = topicId;

    final response = await ref
        .watch(questionRepositoryProvider)
        .getQuestions(topicId: topicId);

    return QuestionFeed.fromPage(response);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(questionRepositoryProvider)
          .getQuestions(topicId: _topicId);

      return QuestionFeed.fromPage(response);
    });
  }

  Future<void> loadNextPage() async {
    final current = state.asData?.value;

    if (current == null || !current.hasNextPage || current.isLoadingMore) {
      return;
    }

    state = AsyncData(current.startLoadingMore());

    try {
      final response = await ref
          .read(questionRepositoryProvider)
          .getQuestions(
            topicId: _topicId,
            page: current.page + 1,
            pageSize: current.pageSize,
          );

      state = AsyncData(current.append(response));
    } on ApiException catch (error) {
      state = AsyncData(current.failLoadingMore(error.message));
    } catch (_) {
      state = AsyncData(
        current.failLoadingMore('Unable to load more questions.'),
      );
    }
  }
}
