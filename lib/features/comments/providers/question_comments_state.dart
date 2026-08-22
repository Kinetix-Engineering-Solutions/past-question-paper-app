import '../domain/question_comment.dart';

final class QuestionCommentsState {
  QuestionCommentsState({
    required Iterable<QuestionComment> comments,
    this.isSubmitting = false,
    Iterable<String> deletingCommentIds = const [],
    Iterable<String> reportingCommentIds = const [],
    Iterable<String> blockingCommentIds = const [],
    this.errorMessage,
  }) : comments = List.unmodifiable(comments),
       deletingCommentIds = Set.unmodifiable(deletingCommentIds),
       reportingCommentIds = Set.unmodifiable(reportingCommentIds),
       blockingCommentIds = Set.unmodifiable(blockingCommentIds);

  final List<QuestionComment> comments;
  final bool isSubmitting;
  final Set<String> deletingCommentIds;
  final Set<String> reportingCommentIds;
  final Set<String> blockingCommentIds;
  final String? errorMessage;

  bool get isBusy =>
      isSubmitting ||
      deletingCommentIds.isNotEmpty ||
      reportingCommentIds.isNotEmpty ||
      blockingCommentIds.isNotEmpty;

  bool isDeleting(String commentId) {
    return deletingCommentIds.contains(commentId);
  }

  bool isReporting(String commentId) {
    return reportingCommentIds.contains(commentId);
  }

  bool isBlocking(String commentId) {
    return blockingCommentIds.contains(commentId);
  }

  QuestionCommentsState copyWith({
    Iterable<QuestionComment>? comments,
    bool? isSubmitting,
    Iterable<String>? deletingCommentIds,
    Iterable<String>? reportingCommentIds,
    Iterable<String>? blockingCommentIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return QuestionCommentsState(
      comments: comments ?? this.comments,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      deletingCommentIds: deletingCommentIds ?? this.deletingCommentIds,
      reportingCommentIds: reportingCommentIds ?? this.reportingCommentIds,
      blockingCommentIds: blockingCommentIds ?? this.blockingCommentIds,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
