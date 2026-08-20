import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/features/questions/data/models/question_filter_options.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/api_providers.dart';
import '../../../core/pagination/paged_response.dart';
import '../data/models/question.dart';
import '../data/question_repository.dart';
import '../domain/question_query.dart';
import 'question_feed.dart';

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepository(apiClient: ref.watch(apiClientProvider));
});

final questionFilterOptionsProvider =
    FutureProvider.family<QuestionFilterOptions, String>((ref, topicId) {
      return ref
          .watch(questionRepositoryProvider)
          .getFilterOptions(topicId: topicId);
    });

final questionsControllerProvider =
    AsyncNotifierProvider.family<
      QuestionsController,
      QuestionFeed,
      QuestionQuery
    >(QuestionsController.new);

class QuestionsController
    extends FamilyAsyncNotifier<QuestionFeed, QuestionQuery> {
  late QuestionQuery _query;

  @override
  Future<QuestionFeed> build(QuestionQuery query) async {
    _query = query;

    final response = await _loadPage(1);

    return QuestionFeed.fromPage(response);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final response = await _loadPage(1);
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
      final response = await _loadPage(
        current.page + 1,
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

  Future<PagedResponse<Question>> _loadPage(int page, {int pageSize = 20}) {
    return ref
        .read(questionRepositoryProvider)
        .getQuestions(
          topicId: _query.topicId,
          examYear: _query.examYear,
          season: _query.season,
          questionNumber: _query.questionNumber,
          page: page,
          pageSize: pageSize,
        );
  }
}
