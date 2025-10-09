import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'package:past_question_paper_v1/repositories/question_repository.dart';
import 'package:past_question_paper_v1/services/firestore_database_firebase.dart';

// Riverpod provider for the PracticeViewModel
final practiceViewModelProvider =
    StateNotifierProvider.autoDispose<PracticeViewModel, PracticeState>((ref) {
      // Use autoDispose to automatically clean up when no longer needed
      // The ViewModel now depends on the QuestionRepository to communicate with the backend
      return PracticeViewModel(
        ref.watch(questionRepositoryProvider),
        ref.watch(firestoreDatabaseProvider),
      );
    });

// Provider for FirestoreDatabaseService
final firestoreDatabaseProvider = Provider<FirestoreDatabaseService>((ref) {
  return FirestoreDatabaseService();
});

// A simpler state class to manage the active practice session
class PracticeState {
  final List<Question> questions;
  final Map<String, dynamic> userAnswers;
  final bool isSubmitting;
  final Map<String, int> pqpDisplayNumbers;

  const PracticeState({
    this.questions = const [],
    this.userAnswers = const {},
    this.isSubmitting = false,
    this.pqpDisplayNumbers = const {},
  });

  PracticeState copyWith({
    List<Question>? questions,
    Map<String, dynamic>? userAnswers,
    bool? isSubmitting,
    Map<String, int>? pqpDisplayNumbers,
  }) {
    return PracticeState(
      questions: questions ?? this.questions,
      userAnswers: userAnswers ?? this.userAnswers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      pqpDisplayNumbers: pqpDisplayNumbers ?? this.pqpDisplayNumbers,
    );
  }
}

class PracticeViewModel extends StateNotifier<PracticeState> {
  final QuestionRepository _questionRepository;
  final FirestoreDatabaseService _firestoreService;
  bool _disposed = false;

  // Option 3: Cache for parent questions to avoid repeated fetches
  final Map<String, Question> _parentCache = {};

  PracticeViewModel(this._questionRepository, this._firestoreService)
    : super(const PracticeState());

  @override
  void dispose() {
    _disposed = true;
    _parentCache.clear();
    super.dispose();
  }

  /// Checks if the view model is still active
  bool get isActive => !_disposed && mounted;

  /// Option 3: Loads parent context for a question
  /// This enriches questions with parent data if they have a parentQuestionId
  Future<void> loadParentContext(Question question) async {
    if (!isActive || !question.hasParent) return;

    // Check if already enriched by backend
    if (question.parentContext != null) {
      print(
        '✅ Question ${question.id} already has parent context from backend',
      );
      return;
    }

    // Check cache first
    if (_parentCache.containsKey(question.parentQuestionId)) {
      print('✅ Using cached parent for question ${question.id}');
      return;
    }

    try {
      print('🔍 Fetching parent context for question ${question.id}');

      // Fetch from Firestore
      final parent = await _firestoreService.getParentQuestion(
        question.parentQuestionId!,
      );

      if (parent != null) {
        _parentCache[parent.id] = parent;
        print('✅ Cached parent question ${parent.id}');

        // Enrich the question with parent context
        final enriched = await _firestoreService.enrichQuestionWithParent(
          question,
        );

        // Update the question in state with enriched version
        if (isActive) {
          final updatedQuestions = state.questions.map((q) {
            return q.id == enriched.id ? enriched : q;
          }).toList();

          state = state.copyWith(questions: updatedQuestions);
          print('✅ Updated question ${enriched.id} with parent context');
        }
      } else {
        print('⚠️ Parent question not found for ${question.id}');
      }
    } catch (e) {
      print('❌ Error loading parent context for question ${question.id}: $e');
      // Continue without parent context - not critical
    }
  }

  /// Starts a new practice session with a given list of questions.
  /// This is called by the PracticeScreen when it's initialized.
  /// Option 3: Also loads parent context for child questions
  Future<void> startSession(List<Question> questions) async {
    if (!isActive) return;

    state = PracticeState(
      questions: questions,
      userAnswers: const {},
      pqpDisplayNumbers: _generateSequentialPqpNumbers(questions),
    );

    // Option 3: Load parent context for questions that need it
    // Note: Backend should already enrich, but this is a fallback
    for (final question in questions) {
      if (question.hasParent && question.parentContext == null) {
        await loadParentContext(question);
      }
    }
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
      state = PracticeState(
        questions: state.questions,
        userAnswers: const {},
        pqpDisplayNumbers: state.pqpDisplayNumbers,
      );
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

  Map<String, int> _generateSequentialPqpNumbers(List<Question> questions) {
    if (questions.isEmpty) {
      return const {};
    }

    final Map<String, int> displayNumbers = {};
    for (var index = 0; index < questions.length; index++) {
      displayNumbers[questions[index].id] = index + 1;
    }

    return displayNumbers;
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
