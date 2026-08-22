import 'package:supabase_flutter/supabase_flutter.dart';

import 'bookmark_repository.dart';

final class SupabaseBookmarkRepository implements BookmarkRepository {
  const SupabaseBookmarkRepository({required SupabaseClient client})
    : _client = client;

  final SupabaseClient _client;

  @override
  Future<bool> isBookmarked({
    required String userId,
    required String questionId,
  }) async {
    _validate(userId, questionId);

    final result = await _client
        .from('question_bookmarks')
        .select('question_id')
        .eq('user_id', userId)
        .eq('question_id', questionId)
        .maybeSingle();

    return result != null;
  }

  @override
  Future<void> addBookmark({
    required String userId,
    required String questionId,
  }) async {
    _validate(userId, questionId);

    await _client.from('question_bookmarks').insert({
      'user_id': userId,
      'question_id': questionId,
    });
  }

  @override
  Future<void> removeBookmark({
    required String userId,
    required String questionId,
  }) async {
    _validate(userId, questionId);

    await _client
        .from('question_bookmarks')
        .delete()
        .eq('user_id', userId)
        .eq('question_id', questionId);
  }

  @override
  Future<Set<String>> getBookmarkedQuestionIds({required String userId}) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'A user ID is required.');
    }

    final rows = await _client
        .from('question_bookmarks')
        .select('question_id')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return rows.map((row) => row['question_id'] as String).toSet();
  }

  void _validate(String userId, String questionId) {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'A user ID is required.');
    }

    if (questionId.trim().isEmpty) {
      throw ArgumentError.value(
        questionId,
        'questionId',
        'A question ID is required.',
      );
    }
  }
}
