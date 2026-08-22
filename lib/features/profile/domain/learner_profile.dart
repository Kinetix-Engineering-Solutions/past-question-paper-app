final class LearnerProfile {
  const LearnerProfile({
    required this.userId,
    required this.displayName,
    required this.grade,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String? displayName;
  final int? grade;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isComplete => displayName != null && grade != null;

  factory LearnerProfile.fromJson(Map<String, dynamic> json) {
    final grade = json['grade'];

    if (grade != null && (grade is! int || grade < 10 || grade > 12)) {
      throw const FormatException('Invalid learner profile grade.');
    }

    return LearnerProfile(
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String?,
      grade: grade as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
