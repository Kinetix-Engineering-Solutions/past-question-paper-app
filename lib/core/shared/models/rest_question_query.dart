class RestQuestionQuery {
  final String subject;
  final int grade;
  final String topic;
  final int? startYear;
  final int? endYear;
  final String? paper;
  final String? season;
  final String? questionNumber;
  final String? questionPrefix;

  const RestQuestionQuery({
    required this.subject,
    required this.grade,
    required this.topic,
    this.startYear,
    this.endYear,
    this.paper,
    this.season,
    this.questionNumber,
    this.questionPrefix,
  });

  Map<String, String> toQueryParameters() {
    final normalizedSubject = _normalizeSubject(subject);
    final normalizedTopic = topic.trim();
    final normalizedPaper = _normalizeNullableText(paper);
    final normalizedSeason = _normalizeNullableText(season);
    final normalizedQuestionNumber = _normalizeNullableText(questionNumber);
    final normalizedQuestionPrefix = _normalizeNullableText(questionPrefix);

    if (normalizedSubject.isEmpty) {
      throw ArgumentError.value(subject, 'subject', 'Subject is required.');
    }

    if (grade <= 0) {
      throw ArgumentError.value(grade, 'grade', 'Grade must be positive.');
    }

    if (normalizedTopic.isEmpty) {
      throw ArgumentError.value(topic, 'topic', 'Topic is required.');
    }

    return <String, String>{
      'subject': normalizedSubject,
      'grade': grade.toString(),
      'topic': normalizedTopic,
      if (startYear != null) 'startYear': startYear.toString(),
      if (endYear != null) 'endYear': endYear.toString(),
      if (normalizedPaper != null) 'paper': normalizedPaper,
      if (normalizedSeason != null) 'season': normalizedSeason,
      if (normalizedQuestionNumber != null)
        'questionNumber': normalizedQuestionNumber,
      if (normalizedQuestionPrefix != null)
        'questionPrefix': normalizedQuestionPrefix,
    };
  }

  String get cacheKey {
    final entries = toQueryParameters().entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((entry) => '${entry.key}=${entry.value}').join('&');
  }

  static String _normalizeSubject(String value) {
    final normalized = value.trim().toLowerCase();
    // Backend expects full subject name (e.g. "mathematics"), not "math".
    if (normalized == 'math') return 'mathematics';
    if (normalized == 'maths') return 'mathematics';
    return normalized;
  }

  static String? _normalizeNullableText(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }
}
