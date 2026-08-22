import '../domain/blocked_learner.dart';

final class BlockedLearnersState {
  BlockedLearnersState({
    required Iterable<BlockedLearner> learners,
    Iterable<String> unblockingUserIds = const [],
    this.errorMessage,
  }) : learners = List.unmodifiable(learners),
       unblockingUserIds = Set.unmodifiable(unblockingUserIds);

  final List<BlockedLearner> learners;
  final Set<String> unblockingUserIds;
  final String? errorMessage;

  bool isUnblocking(String userId) {
    return unblockingUserIds.contains(userId);
  }

  BlockedLearnersState copyWith({
    Iterable<BlockedLearner>? learners,
    Iterable<String>? unblockingUserIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BlockedLearnersState(
      learners: learners ?? this.learners,
      unblockingUserIds: unblockingUserIds ?? this.unblockingUserIds,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
