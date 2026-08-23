import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/community_guidelines_status.dart';
import 'question_comments_providers.dart';

final communityGuidelinesControllerProvider = AsyncNotifierProvider.autoDispose
    .family<CommunityGuidelinesController, CommunityGuidelinesStatus, String>(
      CommunityGuidelinesController.new,
    );

final class CommunityGuidelinesController
    extends AutoDisposeFamilyAsyncNotifier<CommunityGuidelinesStatus, String> {
  @override
  FutureOr<CommunityGuidelinesStatus> build(String userId) {
    return ref
        .watch(questionCommentsRepositoryProvider)
        .getCommunityGuidelinesStatus();
  }

  Future<bool> accept() async {
    final current = state.asData?.value;

    if (current == null || current.isAccepted) {
      return false;
    }

    state = const AsyncLoading();

    try {
      final acceptedAt = await ref
          .read(questionCommentsRepositoryProvider)
          .acceptCommunityGuidelines();

      state = AsyncData(
        CommunityGuidelinesStatus(
          version: current.version,
          isAccepted: true,
          acceptedAt: acceptedAt,
        ),
      );

      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref
          .read(questionCommentsRepositoryProvider)
          .getCommunityGuidelinesStatus(),
    );
  }
}
