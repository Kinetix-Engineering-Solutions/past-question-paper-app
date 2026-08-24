final class Question {
  const Question({
    required this.id,
    required this.questionNumber,
    required this.displayOrder,
    required this.examYear,
    required this.examSeason,
    required this.paperNumber,
    required this.questionImageUrl,
    required this.memoImageUrl,
    required this.topicId,
    required this.topicName,
    required this.topicSlug,
    required this.grade,
    required this.subjectId,
    required this.subjectName,
    required this.subjectSlug,
  });

  final String id;
  final String questionNumber;
  final int displayOrder;
  final int examYear;
  final String examSeason;
  final int paperNumber;
  final Uri questionImageUrl;
  final Uri memoImageUrl;
  final String topicId;
  final String topicName;
  final String topicSlug;
  final int grade;
  final String subjectId;
  final String subjectName;
  final String subjectSlug;

  factory Question.fromJson(Map<String, Object?> json) {
    if (json case {
      'id': final String id,
      'questionNumber': final String questionNumber,
      'displayOrder': final int displayOrder,
      'examYear': final int examYear,
      'examSeason': final String examSeason,
      'paperNumber': final int paperNumber,
      'questionImageUrl': final String questionImageUrl,
      'memoImageUrl': final String memoImageUrl,
      'topicId': final String topicId,
      'topicName': final String topicName,
      'topicSlug': final String topicSlug,
      'grade': final int grade,
      'subjectId': final String subjectId,
      'subjectName': final String subjectName,
      'subjectSlug': final String subjectSlug,
    }) {
      final questionUri = Uri.tryParse(questionImageUrl);
      final memoUri = Uri.tryParse(memoImageUrl);

      if (id.isEmpty ||
          questionNumber.isEmpty ||
          examSeason.isEmpty ||
          topicId.isEmpty ||
          topicName.isEmpty ||
          topicSlug.isEmpty ||
          subjectId.isEmpty ||
          subjectName.isEmpty ||
          subjectSlug.isEmpty ||
          displayOrder < 0 ||
          examYear < 1996 ||
          paperNumber < 1 ||
          paperNumber > 4 ||
          grade < 10 ||
          grade > 12 ||
          !_isValidHttpUri(questionUri) ||
          !_isValidHttpUri(memoUri)) {
        throw const FormatException('Invalid question response.');
      }

      return Question(
        id: id,
        questionNumber: questionNumber,
        displayOrder: displayOrder,
        examYear: examYear,
        examSeason: examSeason,
        paperNumber: paperNumber,
        questionImageUrl: questionUri!,
        memoImageUrl: memoUri!,
        topicId: topicId,
        topicName: topicName,
        topicSlug: topicSlug,
        grade: grade,
        subjectId: subjectId,
        subjectName: subjectName,
        subjectSlug: subjectSlug,
      );
    }

    throw const FormatException('Invalid question response.');
  }

  static bool _isValidHttpUri(Uri? uri) {
    return uri != null &&
        uri.isAbsolute &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }
}
