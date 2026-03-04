part of 'question.dart';

extension QuestionModeHelpers on Question {
  bool get supportsPQP => modeData.supportsPQP;

  bool get supportsSprint => modeData.supportsSprint;

  String getPQPQuestionText() {
    return pqpData?.questionText ?? questionText;
  }

  String getSprintQuestionText() {
    return sprintData?.questionText ?? questionText;
  }

  int getPQPMarks() {
    return pqpData?.marks ?? marks;
  }

  int getSprintMarks() {
    return sprintData?.marks ?? marks;
  }

  bool get hasParent => parentData.hasParent;

  String? get displayImageUrl => parentData.displayImageUrl(imageUrl);

  String? get parentQuestionText => parentData.parentQuestionText;

  String? get parentQuestionNumber => parentData.parentQuestionNumber;

  bool get canRandomize => modeData.canRandomize;

  String? get difficulty => modeData.difficulty;

  int? get estimatedTime => modeData.estimatedTime;

  List<String> get tags => modeData.tags;

  Map<String, dynamic>? get providedContext => modeData.providedContext;
}
