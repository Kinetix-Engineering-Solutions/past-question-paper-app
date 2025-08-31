enum QuestionType {
  multipleChoice('multiple_choice'),
  trueFalse('true_false'),
  dragAndDrop('drag_and_drop'),
  fillInTheBlank('fill_in_the_blank'),
  matching('matching'),
  shortAnswer('short_answer');

  const QuestionType(this.value);
  final String value;

  static QuestionType fromString(String value) {
    switch (value) {
      case 'multiple_choice':
        return QuestionType.multipleChoice;
      case 'true_false':
        return QuestionType.trueFalse;
      case 'drag_and_drop':
      case 'drag-and-drop': // Support both formats
        return QuestionType.dragAndDrop;
      case 'fill_in_the_blank':
        return QuestionType.fillInTheBlank;
      case 'matching':
        return QuestionType.matching;
      case 'short_answer':
        return QuestionType.shortAnswer;
      default:
        return QuestionType.multipleChoice; // Default fallback
    }
  }

  String get displayName {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.trueFalse:
        return 'True/False';
      case QuestionType.dragAndDrop:
        return 'Drag & Drop';
      case QuestionType.fillInTheBlank:
        return 'Fill in the Blank';
      case QuestionType.matching:
        return 'Matching';
      case QuestionType.shortAnswer:
        return 'Short Answer';
    }
  }

  bool get supportsDragAndDrop {
    return this == QuestionType.dragAndDrop || this == QuestionType.matching;
  }

  bool get supportsMultipleAnswers {
    return this == QuestionType.dragAndDrop || this == QuestionType.matching;
  }
}
