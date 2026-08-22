import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../data/bookmark_repository.dart';
import '../data/supabase_bookmark_repository.dart';
import '../domain/bookmark_target.dart';
import 'bookmark_state.dart';

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return SupabaseBookmarkRepository(client: ref.watch(supabaseClientProvider));
});

final bookmarkControllerProvider =
    AsyncNotifierProvider.family<
      BookmarkController,
      BookmarkState,
      BookmarkTarget
    >(BookmarkController.new);

class BookmarkController
    extends FamilyAsyncNotifier<BookmarkState, BookmarkTarget> {
  late BookmarkTarget _target;

  @override
  Future<BookmarkState> build(BookmarkTarget target) async {
    _target = target;

    final isBookmarked = await ref
        .watch(bookmarkRepositoryProvider)
        .isBookmarked(userId: target.userId, questionId: target.questionId);

    return BookmarkState(isBookmarked: isBookmarked);
  }

  Future<void> toggle() async {
    final current = state.asData?.value;

    if (current == null || current.isSaving) {
      return;
    }

    state = AsyncData(current.saving());

    try {
      if (current.isBookmarked) {
        await ref
            .read(bookmarkRepositoryProvider)
            .removeBookmark(
              userId: _target.userId,
              questionId: _target.questionId,
            );
      } else {
        await ref
            .read(bookmarkRepositoryProvider)
            .addBookmark(
              userId: _target.userId,
              questionId: _target.questionId,
            );
      }

      state = AsyncData(current.success(isBookmarked: !current.isBookmarked));
    } catch (_) {
      state = AsyncData(
        current.failure('Unable to update bookmark. Try again.'),
      );
    }
  }
}
