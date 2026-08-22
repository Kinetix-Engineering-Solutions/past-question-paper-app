import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/question_comment_report_reason.dart';
import 'question_comments_providers.dart';
import 'question_comments_state.dart';

final class QuestionCommentsController
    extends AutoDisposeFamilyAsyncNotifier<QuestionCommentsState, String> {
  @override
  FutureOr<QuestionCommentsState> build(String questionId) async {
    final comments = await ref
        .watch(questionCommentsRepositoryProvider)
        .getComments(questionId: questionId);

    return QuestionCommentsState(comments: comments);
  }

  Future<bool> createComment({
    required String body,
    String? externalUrl,
  }) async {
    final current = state.asData?.value;

    if (current == null || current.isBusy) {
      return false;
    }

    final normalisedBody = body.trim();
    final normalisedUrl = externalUrl?.trim();

    if (normalisedBody.length < 2 || normalisedBody.length > 1000) {
      state = AsyncData(
        current.copyWith(
          errorMessage: 'Comment must be between 2 and 1000 characters.',
        ),
      );

      return false;
    }

    state = AsyncData(current.copyWith(isSubmitting: true, clearError: true));

    try {
      final comment = await ref
          .read(questionCommentsRepositoryProvider)
          .createComment(
            questionId: arg,
            body: normalisedBody,
            externalUrl: normalisedUrl?.isEmpty == true ? null : normalisedUrl,
          );

      state = AsyncData(
        QuestionCommentsState(comments: [comment, ...current.comments]),
      );

      return true;
    } catch (_) {
      state = AsyncData(
        current.copyWith(errorMessage: 'Unable to post your comment.'),
      );

      return false;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    final current = state.asData?.value;

    if (current == null || current.isBusy) {
      return false;
    }

    final commentExists = current.comments.any(
      (comment) => comment.id == commentId && comment.isOwnComment,
    );

    if (!commentExists) {
      return false;
    }

    final remainingComments = current.comments
        .where((comment) => comment.id != commentId)
        .toList(growable: false);

    state = AsyncData(
      current.copyWith(
        comments: remainingComments,
        deletingCommentIds: {commentId},
        clearError: true,
      ),
    );

    try {
      final deleted = await ref
          .read(questionCommentsRepositoryProvider)
          .deleteComment(commentId: commentId);

      if (!deleted) {
        throw StateError('Comment was not deleted.');
      }

      state = AsyncData(QuestionCommentsState(comments: remainingComments));

      return true;
    } catch (_) {
      state = AsyncData(
        current.copyWith(errorMessage: 'Unable to delete your comment.'),
      );

      return false;
    }
  }

  Future<bool> reportComment({
    required String commentId,
    required QuestionCommentReportReason reason,
    String? details,
  }) async {
    final current = state.asData?.value;

    if (current == null || current.isBusy) {
      return false;
    }

    final commentExists = current.comments.any(
      (comment) => comment.id == commentId && !comment.isOwnComment,
    );

    if (!commentExists) {
      return false;
    }

    final normalisedDetails = details?.trim();

    if (normalisedDetails != null && normalisedDetails.length > 500) {
      state = AsyncData(
        current.copyWith(
          errorMessage: 'Report details cannot exceed 500 characters.',
        ),
      );

      return false;
    }

    state = AsyncData(
      current.copyWith(reportingCommentIds: {commentId}, clearError: true),
    );

    try {
      await ref
          .read(questionCommentsRepositoryProvider)
          .reportComment(
            commentId: commentId,
            reason: reason,
            details: normalisedDetails?.isEmpty == true
                ? null
                : normalisedDetails,
          );

      state = AsyncData(current.copyWith(clearError: true));

      return true;
    } catch (_) {
      state = AsyncData(
        current.copyWith(errorMessage: 'Unable to report this comment.'),
      );

      return false;
    }
  }

  Future<bool> blockCommentAuthor(String commentId) async {
    final current = state.asData?.value;

    if (current == null || current.isBusy) {
      return false;
    }

    final matchingComments = current.comments.where(
      (comment) => comment.id == commentId && !comment.isOwnComment,
    );

    if (matchingComments.isEmpty) {
      return false;
    }

    final blockedAuthorId = matchingComments.first.authorUserId;

    state = AsyncData(
      current.copyWith(blockingCommentIds: {commentId}, clearError: true),
    );

    try {
      final returnedUserId = await ref
          .read(questionCommentsRepositoryProvider)
          .blockCommentAuthor(commentId: commentId);

      if (returnedUserId != blockedAuthorId) {
        throw StateError('Block RPC returned an unexpected user.');
      }

      final remainingComments = current.comments
          .where((comment) => comment.authorUserId != blockedAuthorId)
          .toList(growable: false);

      state = AsyncData(QuestionCommentsState(comments: remainingComments));

      return true;
    } catch (_) {
      state = AsyncData(
        current.copyWith(errorMessage: 'Unable to block this learner.'),
      );

      return false;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final comments = await ref
          .read(questionCommentsRepositoryProvider)
          .getComments(questionId: arg);

      return QuestionCommentsState(comments: comments);
    });
  }

  void clearError() {
    final current = state.asData?.value;

    if (current == null || current.errorMessage == null) {
      return;
    }

    state = AsyncData(current.copyWith(clearError: true));
  }
}
