import 'package:past_question_paper_stem/domain/strategies/drag_and_drop_strategy.dart';
import 'package:past_question_paper_stem/domain/strategies/multiple_choice_strategy.dart';
import 'package:past_question_paper_stem/domain/strategies/question_strategy.dart';
import 'package:past_question_paper_stem/domain/strategies/true_false_strategy.dart';
import 'package:past_question_paper_stem/models/question.dart';

/// Factory for creating the appropriate question strategy based on question type
class QuestionStrategyFactory {
  /// Get a strategy instance for the given question
  static QuestionStrategy getStrategy(Question question) {
    // Convert to lowercase to make comparisons case-insensitive
    final questionType = question.questionType.toLowerCase();

    switch (questionType) {
      case 'multiple choice':
      case 'mcq':
        return MultipleChoiceStrategy();

      case 'drag-and-drop':
      case 'drag and drop':
      case 'order':
        return DragAndDropStrategy();

      case 'true/false':
      case 'true-false':
      case 'true false':
        return TrueFalseStrategy();

      default:
        // Default to multiple choice for unknown types
        return MultipleChoiceStrategy();
    }
  }
}
