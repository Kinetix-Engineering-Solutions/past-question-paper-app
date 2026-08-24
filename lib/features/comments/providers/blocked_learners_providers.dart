import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'blocked_learners_state.dart';
import 'question_comments_providers.dart';

final blockedLearnersControllerProvider =
    AsyncNotifierProvider.autoDispose<
      BlockedLearnersController,
      BlockedLearnersState
    >(BlockedLearnersController.new);

final class BlockedLearnersController
    extends AutoDisposeAsyncNotifier<BlockedLearnersState> {
  @override
  FutureOr<BlockedLearnersState> build() async {
    final learners = await ref
        .watch(questionCommentsRepositoryProvider)
        .getBlockedUsers();

    return BlockedLearnersState(learners: learners);
  }

  Future<bool> unblockUser(String userId) async {
    final current = state.asData?.value;

    if (current == null || current.isUnblocking(userId)) {
      return false;
    }

    final userExists = current.learners.any(
      (learner) => learner.userId == userId,
    );

    if (!userExists) {
      return false;
    }

    state = AsyncData(
      current.copyWith(unblockingUserIds: {userId}, clearError: true),
    );

    try {
      final unblocked = await ref
          .read(questionCommentsRepositoryProvider)
          .unblockUser(userId: userId);

      if (!unblocked) {
        throw StateError('Learner was not blocked.');
      }

      final remainingLearners = current.learners
          .where((learner) => learner.userId != userId)
          .toList(growable: false);

      state = AsyncData(BlockedLearnersState(learners: remainingLearners));

      return true;
    } catch (_) {
      state = AsyncData(
        current.copyWith(errorMessage: 'Unable to unblock this learner.'),
      );

      return false;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final learners = await ref
          .read(questionCommentsRepositoryProvider)
          .getBlockedUsers();

      return BlockedLearnersState(learners: learners);
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
