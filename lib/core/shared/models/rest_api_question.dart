class RestApiQuestion {
  final String id;
  final String subjectId;
  final int grade;
  final String topic;
  final int? year;
  final String? season;
  final String? paper;
  final String? questionNumber;
  final String? imageUrl;
  final String? answerImageUrl;

  const RestApiQuestion({
    required this.id,
    required this.subjectId,
    required this.grade,
    required this.topic,
    required this.year,
    required this.season,
    required this.paper,
    required this.questionNumber,
    required this.imageUrl,
    required this.answerImageUrl,
  });

  factory RestApiQuestion.fromJson(Map<String, dynamic> json) {
    String readString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    String? readNullableString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
      return null;
    }

    int? readNullableInt(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        if (value is int) return value;
        final parsed = int.tryParse(value.toString());
        if (parsed != null) return parsed;
      }
      return null;
    }

    final id = readString(['id', '_id', 'questionId', 'question_id']);
    final subjectId = readString(['subjectId', 'subject', 'subject_id']);
    final topic = readString(['topic', 'topicId', 'topic_id']);
    final grade = readNullableInt(['grade']);

    final missingFields = <String>[
      if (id.isEmpty) 'id',
      if (subjectId.isEmpty) 'subjectId',
      if (topic.isEmpty) 'topic',
      if (grade == null) 'grade',
    ];

    if (missingFields.isNotEmpty) {
      throw FormatException(
        'Question response is missing required fields: ${missingFields.join(', ')}.',
      );
    }

    return RestApiQuestion(
      id: id,
      subjectId: subjectId,
      grade: grade!,
      topic: topic,
      year: readNullableInt(['year', 'examYear', 'exam_year']),
      season: readNullableString(['season', 'examSeason', 'exam_season']),
      paper: readNullableString(['paper']),
      questionNumber: readNullableString(['questionNumber', 'question_number']),
      imageUrl: readNullableString(['imageUrl', 'image_url']),
      answerImageUrl: readNullableString([
        'answerImageUrl',
        'answer_image_url',
      ]),
    );
  }
}
