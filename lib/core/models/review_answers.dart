import 'package:flutter_riverpod/flutter_riverpod.dart';

final reviewAnswersProvider = Provider<ReviewAnswersViewModel>(
  (ref) => ReviewAnswersViewModel(),
);

class ReviewAnswerItem {
  final int questionNumber;
  final String correctAnswer;
  final String userAnswer;

  ReviewAnswerItem({
    required this.questionNumber,
    required this.correctAnswer,
    required this.userAnswer,
  });

  bool get isCorrect => correctAnswer == userAnswer;
}

class ReviewAnswersViewModel {
  List<ReviewAnswerItem> get answers => [
    ReviewAnswerItem(questionNumber: 1, correctAnswer: "C", userAnswer: "A"),
    ReviewAnswerItem(questionNumber: 2, correctAnswer: "B", userAnswer: "B"),
    ReviewAnswerItem(
      questionNumber: 3,
      correctAnswer: "True",
      userAnswer: "False",
    ),
    ReviewAnswerItem(questionNumber: 4, correctAnswer: "8", userAnswer: "8"),
  ];
}
