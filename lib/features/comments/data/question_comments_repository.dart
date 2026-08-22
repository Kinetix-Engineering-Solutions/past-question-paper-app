import '../domain/blocked_learner.dart';
import '../domain/question_comment.dart';
import '../domain/question_comment_report_reason.dart';

abstract interface class QuestionCommentsRepository {
  Future<List<QuestionComment>> getComments({
    required String questionId,
    int limit = 50,
  });

  Future<QuestionComment> createComment({
    required String questionId,
    required String body,
    String? externalUrl,
  });

  Future<bool> deleteComment({required String commentId});

  Future<void> reportComment({
    required String commentId,
    required QuestionCommentReportReason reason,
    String? details,
  });

  Future<String> blockCommentAuthor({required String commentId});

  Future<bool> unblockUser({required String userId});

  Future<List<BlockedLearner>> getBlockedUsers();
}
