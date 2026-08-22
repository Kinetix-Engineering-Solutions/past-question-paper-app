import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/learner_profile.dart';
import 'profile_providers.dart';

final class ProfileController
    extends AutoDisposeFamilyAsyncNotifier<LearnerProfile, String> {
  @override
  FutureOr<LearnerProfile> build(String userId) {
    return ref.watch(profileRepositoryProvider).getProfile(userId: userId);
  }

  Future<void> updateProfile({
    required String displayName,
    required int grade,
  }) async {
    if (state.isLoading) {
      return;
    }

    final normalisedName = displayName.trim();

    if (normalisedName.length < 2 || normalisedName.length > 40) {
      state = AsyncError(
        ArgumentError(
          'Display name must be between '
          '2 and 40 characters.',
        ),
        StackTrace.current,
      );

      return;
    }

    if (grade < 10 || grade > 12) {
      state = AsyncError(
        ArgumentError('Grade must be between 10 and 12.'),
        StackTrace.current,
      );

      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref
          .read(profileRepositoryProvider)
          .updateProfile(displayName: normalisedName, grade: grade),
    );
  }

  Future<void> retry() async {
    ref.invalidateSelf();
    await future;
  }
}
