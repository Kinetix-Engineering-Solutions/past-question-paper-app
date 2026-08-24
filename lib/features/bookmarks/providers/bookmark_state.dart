final class BookmarkState {
  const BookmarkState({
    required this.isBookmarked,
    this.isSaving = false,
    this.errorMessage,
  });

  final bool isBookmarked;
  final bool isSaving;
  final String? errorMessage;

  BookmarkState saving() {
    return BookmarkState(isBookmarked: isBookmarked, isSaving: true);
  }

  BookmarkState success({required bool isBookmarked}) {
    return BookmarkState(isBookmarked: isBookmarked);
  }

  BookmarkState failure(String message) {
    return BookmarkState(isBookmarked: isBookmarked, errorMessage: message);
  }
}
