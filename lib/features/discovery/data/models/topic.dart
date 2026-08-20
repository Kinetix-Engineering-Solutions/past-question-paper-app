final class Topic {
  const Topic({
    required this.id,
    required this.name,
    required this.slug,
    required this.grade,
    required this.displayOrder,
    required this.subjectId,
    required this.subjectName,
    required this.subjectSlug,
    required this.questionCount,
  });

  final String id;
  final String name;
  final String slug;
  final int grade;
  final int displayOrder;
  final String subjectId;
  final String subjectName;
  final String subjectSlug;
  final int questionCount;

  factory Topic.fromJson(Map<String, Object?> json) {
    return switch (json) {
      {
        'id': final String id,
        'name': final String name,
        'slug': final String slug,
        'grade': final int grade,
        'displayOrder': final int displayOrder,
        'subjectId': final String subjectId,
        'subjectName': final String subjectName,
        'subjectSlug': final String subjectSlug,
        'questionCount': final int questionCount,
      }
          when id.isNotEmpty &&
              name.isNotEmpty &&
              slug.isNotEmpty &&
              subjectId.isNotEmpty &&
              subjectName.isNotEmpty &&
              subjectSlug.isNotEmpty &&
              grade >= 10 &&
              grade <= 12 &&
              displayOrder >= 0 &&
              questionCount >= 0 =>
        Topic(
          id: id,
          name: name,
          slug: slug,
          grade: grade,
          displayOrder: displayOrder,
          subjectId: subjectId,
          subjectName: subjectName,
          subjectSlug: subjectSlug,
          questionCount: questionCount,
        ),
      _ => throw const FormatException('Invalid topic response.'),
    };
  }
}
