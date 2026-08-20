import '../../../core/pagination/paged_response.dart';
import '../data/models/question.dart';

final class QuestionFeed {
  QuestionFeed({
    required Iterable<Question> items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    this.isLoadingMore = false,
    this.loadMoreError,
  }) : items = List.unmodifiable(items);

  final List<Question> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool isLoadingMore;
  final String? loadMoreError;

  bool get hasNextPage => page < totalPages;

  factory QuestionFeed.fromPage(PagedResponse<Question> response) {
    return QuestionFeed(
      items: response.items,
      page: response.page,
      pageSize: response.pageSize,
      totalCount: response.totalCount,
      totalPages: response.totalPages,
    );
  }

  QuestionFeed startLoadingMore() {
    return QuestionFeed(
      items: items,
      page: page,
      pageSize: pageSize,
      totalCount: totalCount,
      totalPages: totalPages,
      isLoadingMore: true,
    );
  }

  QuestionFeed append(PagedResponse<Question> response) {
    final questionsById = {
      for (final question in items) question.id: question,
      for (final question in response.items) question.id: question,
    };

    return QuestionFeed(
      items: questionsById.values,
      page: response.page,
      pageSize: response.pageSize,
      totalCount: response.totalCount,
      totalPages: response.totalPages,
    );
  }

  QuestionFeed failLoadingMore(String message) {
    return QuestionFeed(
      items: items,
      page: page,
      pageSize: pageSize,
      totalCount: totalCount,
      totalPages: totalPages,
      loadMoreError: message,
    );
  }
}
