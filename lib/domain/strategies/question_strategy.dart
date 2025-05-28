import 'package:past_question_paper_stem/models/question.dart';
import 'package:flutter/material.dart';

/// The base strategy interface for handling different question types
abstract class QuestionStrategy {
  /// Validates the question data
  bool validate(Question question);

  /// Renders the question content
  Widget buildQuestionContent(Question question, BuildContext context);

  /// Checks if the provided answer is correct
  bool checkAnswer(Question question, dynamic userAnswer);

  /// Returns the correct answer(s) for display
  String getCorrectAnswerText(Question question);

  /// Resets any stateful data
  dynamic createInitialState(Question question);
}
