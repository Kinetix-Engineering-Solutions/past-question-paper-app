import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/learner_profile.dart';
import 'profile_repository.dart';

final class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<LearnerProfile> getProfile({required String userId}) async {
    final currentUserId = _requireUserId();

    if (currentUserId != userId) {
      throw StateError(
        'Profiles can only be loaded '
        'for the current user.',
      );
    }

    final data = await _client
        .from('profiles')
        .select(
          'user_id, display_name, grade, '
          'created_at, updated_at',
        )
        .eq('user_id', userId)
        .single();

    return LearnerProfile.fromJson(data);
  }

  @override
  Future<LearnerProfile> updateProfile({
    required String displayName,
    required int grade,
  }) async {
    _requireUserId();

    final data = await _client.rpc(
      'update_my_profile',
      params: {'p_display_name': displayName.trim(), 'p_grade': grade},
    );

    if (data is! List || data.isEmpty) {
      throw const FormatException('Profile RPC returned no result.');
    }

    final firstRow = data.first;

    if (firstRow is! Map) {
      throw const FormatException('Profile RPC returned an invalid result.');
    }

    return LearnerProfile.fromJson(Map<String, dynamic>.from(firstRow));
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;

    if (userId == null) {
      throw StateError('Authentication is required.');
    }

    return userId;
  }
}
