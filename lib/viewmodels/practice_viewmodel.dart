import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'package:past_question_paper_v1/repositories/question_repository.dart';

// Riverpod provider for the PracticeViewModel
final practiceViewModelProvider =
    StateNotifierProvider.autoDispose<PracticeViewModel, PracticeState>((ref) {
      // Use autoDispose to automatically clean up when no longer needed
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
  bool _disposed = false;

  PracticeViewModel(this._questionRepository) : super(const PracticeState());

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Checks if the view model is still active
  bool get isActive => !_disposed && mounted;

  /// Starts a new practice session with a given list of questions.
  /// This is called by the PracticeScreen when it's initialized.
  void startSession(List<Question> questions) {
    if (!isActive) return;
    state = PracticeState(questions: questions, userAnswers: {});
  }

  /// Cleans up the current session and resets the state.
  /// This should be called when the session is completed or cancelled.
  void clearSession() {
    if (!isActive) return;
    state = const PracticeState();
  }

  /// Resets the session to initial state while keeping the same questions.
  /// Useful for retaking the same test.
  void resetSession() {
    if (!isActive) return;
    if (state.questions.isNotEmpty) {
      state = PracticeState(questions: state.questions, userAnswers: {});
    } else {
      state = const PracticeState();
    }
  }

  /// Records the user's answer for a specific question.
  void answerQuestion(String questionId, dynamic answer) {
    if (!isActive) return;
    final newAnswers = Map<String, dynamic>.from(state.userAnswers);
    newAnswers[questionId] = answer;
    state = state.copyWith(userAnswers: newAnswers);
  }

  /// Submits the user's answers to the backend for grading.
  /// Returns a map containing the complete grading results.
  Future<Map<String, dynamic>?> submitTest() async {
    if (!isActive || state.isSubmitting) return null;

    state = state.copyWith(isSubmitting: true);

    try {
      // Get the subject and paper from the first question to pass to the cloud function
      final subject = state.questions.first.subject;
      final paper = state.questions.first.paper;

      // === DEBUG: Log what we're sending ===
      print('=== SUBMITTING TEST DATA ===');
      print('Subject: $subject');
      print('Paper: $paper');
      print('User Answers:');
      state.userAnswers.forEach((questionId, answer) {
        print('  $questionId: "$answer" (${answer.runtimeType})');
      });
      print('Questions with correctOrder:');
      for (final q in state.questions) {
        if (q.format == 'drag-and-drop' && q.correctOrder.isNotEmpty) {
          print('  ${q.id}: correctOrder = ${q.correctOrder}');
        }
      }
      print('=== END SUBMIT DATA ===\n');

      // Call the repository to trigger the 'gradeTest' Cloud Function
      final gradingResults = await _questionRepository.gradeTest(
        userAnswers: state.userAnswers,
        subject: subject,
        paper: paper,
      );

      // === DEBUG: Log what we received ===
      print('=== RECEIVED GRADING RESULTS ===');
      print('Raw response: $gradingResults');
      if (gradingResults['results'] != null) {
        print('Individual question results:');
        for (final result in gradingResults['results']) {
          if (result['format'] == 'dragAndDrop' &&
              result['subFormat'] == 'ordering') {
            print('  Question ${result['questionId']}:');
            print('    User answers: ${result['userAnswers']}');
            print('    Correct order: ${result['correctOrder']}');
            print(
              '    Correct count: ${result['correctCount']}/${result['totalSteps']}',
            );
            print('    Is correct: ${result['isCorrect']}');
            print('    Marks: ${result['marksAwarded']}/${result['maxMarks']}');
          }
        }
      }
      print('=== END GRADING RESULTS ===\n');

      if (!isActive) return null; // Check if still active after async operation

      state = state.copyWith(isSubmitting: false);

      // Return both grading results and questions for detailed results screen
      return {
        'gradingResults': gradingResults,
        'questions': state.questions.map((q) => q.toMap()).toList(),
      };
    } catch (e) {
      print('Error submitting test: $e');
      if (isActive) {
        state = state.copyWith(isSubmitting: false);
      }
      return null; // Return null to indicate failure
    } finally {
      // Note: Session cleanup is handled in PracticeScreen._submitTest()
      // before navigation to ensure proper lifecycle management
    }
  }
}
