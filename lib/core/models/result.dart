import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizResult {
  final String subject;
  final int score; // percentage
  final String date; // format: Apr 18
  final String timeTaken;

  QuizResult({
    required this.subject,
    required this.score,
    required this.date,
    required this.timeTaken,
  });
}

final resultViewModelProvider =
    StateNotifierProvider<ResultViewModel, List<QuizResult>>((ref) {
      return ResultViewModel();
    });

class ResultViewModel extends StateNotifier<List<QuizResult>> {
  ResultViewModel()
    : super([
        QuizResult(
          subject: 'Mathematics',
          score: 75,
          date: 'Apr 18',
          timeTaken: '03m 45s',
        ),
        QuizResult(
          subject: 'Life Sciences',
          score: 92,
          date: 'Apr 18',
          timeTaken: '02m 30s',
        ),
        QuizResult(
          subject: 'Geography',
          score: 60,
          date: 'Apr 20',
          timeTaken: '04m 10s',
        ),
      ]);

  QuizResult get latestResult => state.last;

  void addResult(QuizResult result) {
    state = [...state, result];
  }
}
