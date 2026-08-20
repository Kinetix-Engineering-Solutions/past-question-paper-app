final class QuestionFilterOptions {
  QuestionFilterOptions({
    required Iterable<int> examYears,
    required Iterable<String> examSeasons,
  }) : examYears = List.unmodifiable(examYears),
       examSeasons = List.unmodifiable(examSeasons);

  final List<int> examYears;
  final List<String> examSeasons;

  factory QuestionFilterOptions.fromJson(Map<String, Object?> json) {
    final years = json['examYears'];
    final seasons = json['examSeasons'];

    if (years is! List || seasons is! List) {
      throw const FormatException('Invalid question filter options.');
    }

    if (years.any((year) => year is! int) ||
        seasons.any((season) => season is! String || season.trim().isEmpty)) {
      throw const FormatException('Invalid question filter options.');
    }

    return QuestionFilterOptions(
      examYears: years.cast<int>(),
      examSeasons: seasons.cast<String>(),
    );
  }
}
