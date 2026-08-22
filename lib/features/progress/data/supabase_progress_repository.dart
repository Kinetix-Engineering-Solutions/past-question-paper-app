import 'package:past_question_paper_v1/features/progress/data/progress_repository.dart';
import 'package:past_question_paper_v1/features/progress/domain/question_progress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class SupabaseProgressRepository implements ProgressRepository {
  SupabaseProgressRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<QuestionProgress?> getQuestionProgress(String questionId) async {
    final userId = _requireUserId();

    final data = await _client
        .from('question_progress')
        .select(
          'question_id, topic_id, status, review_count, '
          'first_reviewed_at, last_reviewed_at',
        )
        .eq('user_id', userId)
        .eq('question_id', questionId)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return QuestionProgress.fromJson(data);
  }

  @override
  Future<QuestionProgress> setQuestionProgress({
    required String questionId,
    required QuestionProgressStatus status,
  }) async {
    _requireUserId();

    final data = await _client.rpc(
      'set_question_progress',
      params: {'p_question_id': questionId, 'p_status': status.apiValue},
    );

    if (data is! List || data.isEmpty) {
      throw const FormatException('Question progress RPC returned no result.');
    }

    final firstRow = data.first;

    if (firstRow is! Map) {
      throw const FormatException(
        'Question progress RPC returned an invalid result.',
      );
    }

    return QuestionProgress.fromJson(Map<String, dynamic>.from(firstRow));
  }

  @override
  Future<List<String>> getQuestionIdsByStatus({
    required String userId,
    required QuestionProgressStatus status,
  }) async {
    final currentUserId = _requireUserId();

    if (currentUserId != userId) {
      throw StateError(
        'Question progress can only be loaded for the current user.',
      );
    }

    final data = await _client
        .from('question_progress')
        .select('question_id')
        .eq('user_id', userId)
        .eq('status', status.apiValue)
        .order('last_reviewed_at', ascending: false);

    return data
        .map((row) => row['question_id'] as String)
        .toList(growable: false);
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;

    if (userId == null) {
      throw StateError('Authentication is required to save question progress.');
    }

    return userId;
  }
}
