import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_providers.dart';
import '../../../core/pagination/paged_response.dart';
import '../data/models/question.dart';
import '../data/question_repository.dart';

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepository(apiClient: ref.watch(apiClientProvider));
});

final questionsControllerProvider =
    AsyncNotifierProvider.family<
      QuestionsController,
      PagedResponse<Question>,
      String
    >(QuestionsController.new);

class QuestionsController
    extends FamilyAsyncNotifier<PagedResponse<Question>, String> {
  late String _topicId;

  @override
  Future<PagedResponse<Question>> build(String topicId) {
    _topicId = topicId;

    return ref.watch(questionRepositoryProvider).getQuestions(topicId: topicId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () =>
          ref.read(questionRepositoryProvider).getQuestions(topicId: _topicId),
    );
  }
}
