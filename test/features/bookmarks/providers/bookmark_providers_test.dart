import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:past_question_paper_v1/features/bookmarks/data/bookmark_repository.dart';
import 'package:past_question_paper_v1/features/bookmarks/domain/bookmark_target.dart';
import 'package:past_question_paper_v1/features/bookmarks/providers/bookmark_providers.dart';

void main() {
  const target = BookmarkTarget(userId: 'user-id', questionId: 'question-id');

  test('loads the existing bookmark state', () async {
    final repository = _FakeBookmarkRepository(bookmarkedIds: {'question-id'});

    final container = ProviderContainer(
      overrides: [bookmarkRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);

    final state = await container.read(
      bookmarkControllerProvider(target).future,
    );

    expect(state.isBookmarked, isTrue);
  });

  test('adds a bookmark when currently unbookmarked', () async {
    final repository = _FakeBookmarkRepository();

    final container = ProviderContainer(
      overrides: [bookmarkRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);

    await container.read(bookmarkControllerProvider(target).future);

    await container.read(bookmarkControllerProvider(target).notifier).toggle();

    final state = container
        .read(bookmarkControllerProvider(target))
        .requireValue;

    expect(state.isBookmarked, isTrue);
    expect(repository.bookmarkedIds, contains('question-id'));
  });

  test('removes an existing bookmark', () async {
    final repository = _FakeBookmarkRepository(bookmarkedIds: {'question-id'});

    final container = ProviderContainer(
      overrides: [bookmarkRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);

    await container.read(bookmarkControllerProvider(target).future);

    await container.read(bookmarkControllerProvider(target).notifier).toggle();

    final state = container
        .read(bookmarkControllerProvider(target))
        .requireValue;

    expect(state.isBookmarked, isFalse);
    expect(repository.bookmarkedIds, isNot(contains('question-id')));
  });
}

final class _FakeBookmarkRepository implements BookmarkRepository {
  _FakeBookmarkRepository({Set<String>? bookmarkedIds})
    : bookmarkedIds = bookmarkedIds ?? <String>{};

  final Set<String> bookmarkedIds;

  @override
  Future<bool> isBookmarked({
    required String userId,
    required String questionId,
  }) async {
    return bookmarkedIds.contains(questionId);
  }

  @override
  Future<void> addBookmark({
    required String userId,
    required String questionId,
  }) async {
    bookmarkedIds.add(questionId);
  }

  @override
  Future<void> removeBookmark({
    required String userId,
    required String questionId,
  }) async {
    bookmarkedIds.remove(questionId);
  }

  @override
  Future<Set<String>> getBookmarkedQuestionIds({required String userId}) async {
    return Set.unmodifiable(bookmarkedIds);
  }
}
