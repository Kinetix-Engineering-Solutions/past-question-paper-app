import 'package:past_question_paper_v1/features/practice/domain/entities/question_components/map_cast_utils.dart';

class PQPData {
  final String? paper;
  final String? season;
  final int? year;
  final String? questionNumber;
  final String? questionText;
  final int? marks;

  PQPData({
    this.paper,
    this.season,
    this.year,
    this.questionNumber,
    this.questionText,
    this.marks,
  });

  factory PQPData.fromMap(Map<String, dynamic> data) {
    return PQPData(
      paper: data['paper']?.toString(),
      season: data['season']?.toString(),
      year: (data['year'] as num?)?.toInt(),
      questionNumber: data['questionNumber']?.toString(),
      questionText: data['questionText']?.toString(),
      marks: (data['marks'] as num?)?.toInt(),
    );
  }
}

class SprintData {
  final String? questionText;
  final Map<String, dynamic>? providedContext;
  final int? marks;
  final bool? canRandomize;
  final String? difficulty;
  final int? estimatedTime;
  final List<String>? tags;

  SprintData({
    this.questionText,
    this.providedContext,
    this.marks,
    this.canRandomize,
    this.difficulty,
    this.estimatedTime,
    this.tags,
  });

  factory SprintData.fromMap(Map<String, dynamic> data) {
    return SprintData(
      questionText: data['questionText']?.toString(),
      providedContext: data['providedContext'] != null
          ? safeMapCast(data['providedContext'])
          : null,
      marks: (data['marks'] as num?)?.toInt(),
      canRandomize: data['canRandomize'] as bool?,
      difficulty: data['difficulty']?.toString(),
      estimatedTime: (data['estimatedTime'] as num?)?.toInt(),
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
    );
  }
}

class QuestionModeData {
  final List<String>? availableInModes;
  final PQPData? pqpData;
  final SprintData? sprintData;

  const QuestionModeData({
    this.availableInModes,
    this.pqpData,
    this.sprintData,
  });

  bool get supportsPQP => availableInModes?.contains('pqp') ?? false;

  bool get supportsSprint => availableInModes?.contains('sprint') ?? false;

  bool get canRandomize => sprintData?.canRandomize ?? false;

  String? get difficulty => sprintData?.difficulty;

  int? get estimatedTime => sprintData?.estimatedTime;

  List<String> get tags => sprintData?.tags ?? [];

  Map<String, dynamic>? get providedContext => sprintData?.providedContext;
}
