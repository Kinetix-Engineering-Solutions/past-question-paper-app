import '../domain/question_comment.dart';

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
}
