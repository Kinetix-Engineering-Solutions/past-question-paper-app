abstract interface class BookmarkRepository {
  Future<bool> isBookmarked({
    required String userId,
    required String questionId,
  });

  Future<void> addBookmark({
    required String userId,
    required String questionId,
  });

  Future<void> removeBookmark({
    required String userId,
    required String questionId,
  });

  Future<List<String>> getBookmarkedQuestionIds({required String userId});
}
