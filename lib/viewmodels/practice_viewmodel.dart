import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'package:past_question_paper_v1/repositories/question_repository.dart';

// Riverpod provider for the PracticeViewModel
final practiceViewModelProvider =
    StateNotifierProvider<PracticeViewModel, PracticeState>((ref) {
      // The ViewModel now depends on the QuestionRepository to communicate with the backend
      return PracticeViewModel(ref.watch(questionRepositoryProvider));
    });

// A simpler state class to manage the active practice session
class PracticeState {
  final List<Question> questions;
  final Map<String, dynamic> userAnswers;
  final bool isSubmitting;

  const PracticeState({
    this.questions = const [],
    this.userAnswers = const {},
    this.isSubmitting = false,
  });

  PracticeState copyWith({
    List<Question>? questions,
    Map<String, dynamic>? userAnswers,
    bool? isSubmitting,
  }) {
    return PracticeState(
      questions: questions ?? this.questions,
      userAnswers: userAnswers ?? this.userAnswers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class PracticeViewModel extends StateNotifier<PracticeState> {
  final QuestionRepository _questionRepository;

  PracticeViewModel(this._questionRepository) : super(const PracticeState());

  /// Starts a new practice session with a given list of questions.
  /// This is called by the PracticeScreen when it's initialized.
  void startSession(List<Question> questions) {
    state = PracticeState(questions: questions, userAnswers: {});
  }

  /// Records the user's answer for a specific question.
  void answerQuestion(String questionId, dynamic answer) {
    final newAnswers = Map<String, dynamic>.from(state.userAnswers);
    newAnswers[questionId] = answer;
    state = state.copyWith(userAnswers: newAnswers);
  }

  /// Loads local test questions from test_questions_firestore.json
  /// This is useful for testing new question formats locally
  Future<void> loadLocalTestQuestions() async {
    try {
      final questions = await _questionRepository.loadLocalTestQuestions();
      state = PracticeState(questions: questions, userAnswers: {});
    } catch (e) {
      print('Error loading local test questions: $e');
      // Keep empty state if loading fails
      state = const PracticeState();
    }
  }

  /// Submits the user's answers to the backend for grading.
  /// Returns a map containing the score and total marks.
  Future<Map<String, int>?> submitTest() async {
    if (state.isSubmitting) return null;

    state = state.copyWith(isSubmitting: true);

    try {
      // Get the subject and paper from the first question to pass to the cloud function
      final subject = state.questions.first.subject;
      final paper = state.questions.first.paper;

      // Call the repository to trigger the 'gradeTest' Cloud Function
      final result = await _questionRepository.gradeTest(
        userAnswers: state.userAnswers,
        subject: subject,
        paper: paper,
      );

      state = state.copyWith(isSubmitting: false);
      return result;
    } catch (e) {
      print('Error submitting test: $e');
      state = state.copyWith(isSubmitting: false);
      return null; // Return null to indicate failure
    }
  }
}
