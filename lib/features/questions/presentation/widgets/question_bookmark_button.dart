import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/app_user.dart';
import '../../../auth/presentation/auth_screen.dart';
import '../../../bookmarks/domain/bookmark_target.dart';
import '../../../bookmarks/providers/bookmark_providers.dart';
import '../../../bookmarks/providers/saved_questions_provider.dart';
import '../../data/models/question.dart';

class QuestionBookmarkButton extends ConsumerWidget {
  const QuestionBookmarkButton({
    required this.user,
    required this.question,
    super.key,
  });

  final AppUser? user;
  final Question question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = user;

    if (currentUser == null) {
      return IconButton(
        tooltip: 'Sign in to bookmark',
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const AuthScreen()));
        },
        icon: const Icon(Icons.bookmark_border),
      );
    }

    final target = BookmarkTarget(
      userId: currentUser.id,
      questionId: question.id,
    );

    final bookmark = ref.watch(bookmarkControllerProvider(target));

    return bookmark.when(
      loading: () => const IconButton(
        tooltip: 'Loading bookmark',
        onPressed: null,
        icon: SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, stackTrace) => IconButton(
        tooltip: 'Retry bookmark',
        onPressed: () {
          ref.invalidate(bookmarkControllerProvider(target));
        },
        icon: const Icon(Icons.bookmark_border),
      ),
      data: (state) {
        return IconButton(
          tooltip: state.isBookmarked ? 'Remove bookmark' : 'Bookmark question',
          onPressed: state.isSaving
              ? null
              : () => _toggle(context, ref, target),
          icon: Icon(
            state.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          ),
        );
      },
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    BookmarkTarget target,
  ) async {
    await ref.read(bookmarkControllerProvider(target).notifier).toggle();

    if (!context.mounted) {
      return;
    }

    final updatedState = ref
        .read(bookmarkControllerProvider(target))
        .asData
        ?.value;

    final errorMessage = updatedState?.errorMessage;

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));

      return;
    }

    ref.invalidate(savedQuestionsProvider(target.userId));
  }
}
