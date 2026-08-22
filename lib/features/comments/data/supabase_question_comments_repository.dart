import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/question_comment.dart';
import 'question_comments_repository.dart';

final class SupabaseQuestionCommentsRepository
    implements QuestionCommentsRepository {
  SupabaseQuestionCommentsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<QuestionComment>> getComments({
    required String questionId,
    int limit = 50,
  }) async {
    final data = await _client.rpc(
      'get_question_comments',
      params: {'p_question_id': questionId, 'p_limit': limit},
    );

    return _parseCommentList(data);
  }

  @override
  Future<QuestionComment> createComment({
    required String questionId,
    required String body,
    String? externalUrl,
  }) async {
    _requireUserId();

    final data = await _client.rpc(
      'create_question_comment',
      params: {
        'p_question_id': questionId,
        'p_body': body.trim(),
        'p_external_url': externalUrl?.trim(),
      },
    );

    final comments = _parseCommentList(data);

    if (comments.isEmpty) {
      throw const FormatException('Create comment RPC returned no comment.');
    }

    return comments.first;
  }

  @override
  Future<bool> deleteComment({required String commentId}) async {
    _requireUserId();

    final data = await _client.rpc(
      'delete_my_question_comment',
      params: {'p_comment_id': commentId},
    );

    if (data is! bool) {
      throw const FormatException(
        'Delete comment RPC returned an invalid result.',
      );
    }

    return data;
  }

  List<QuestionComment> _parseCommentList(dynamic data) {
    if (data is! List) {
      throw const FormatException('Comments RPC returned an invalid result.');
    }

    return data
        .map((row) {
          if (row is! Map) {
            throw const FormatException(
              'Comments RPC returned an invalid row.',
            );
          }

          return QuestionComment.fromJson(Map<String, dynamic>.from(row));
        })
        .toList(growable: false);
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;

    if (userId == null) {
      throw StateError('Authentication is required.');
    }

    return userId;
  }
}
