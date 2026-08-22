import '../domain/question_comment.dart';

final class QuestionCommentsState {
  QuestionCommentsState({
    required Iterable<QuestionComment> comments,
    this.isSubmitting = false,
    Iterable<String> deletingCommentIds = const [],
    this.errorMessage,
  }) : comments = List.unmodifiable(comments),
       deletingCommentIds = Set.unmodifiable(deletingCommentIds);

  final List<QuestionComment> comments;
  final bool isSubmitting;
  final Set<String> deletingCommentIds;
  final String? errorMessage;

  bool get isBusy => isSubmitting || deletingCommentIds.isNotEmpty;

  QuestionCommentsState copyWith({
    Iterable<QuestionComment>? comments,
    bool? isSubmitting,
    Iterable<String>? deletingCommentIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return QuestionCommentsState(
      comments: comments ?? this.comments,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      deletingCommentIds: deletingCommentIds ?? this.deletingCommentIds,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
