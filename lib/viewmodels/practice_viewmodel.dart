import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'package:past_question_paper_v1/repositories/question_repository.dart';
import 'package:past_question_paper_v1/services/firestore_database_firebase.dart';
import 'package:past_question_paper_v1/viewmodels/session_history_viewmodel.dart';

// Riverpod provider for the PracticeViewModel
final practiceViewModelProvider =
    StateNotifierProvider.autoDispose<PracticeViewModel, PracticeState>((ref) {
      // Use autoDispose to automatically clean up when no longer needed
      // The ViewModel now depends on the QuestionRepository to communicate with the backend
      return PracticeViewModel(
        ref,
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
  final bool isPQPMode;
  final bool isSprintMode;
  final String modeLabel;
  final String? subject;
  final String? paper;
  final int? durationMinutes;
  final DateTime? startedAt;
  final int totalQuestions;
  final Map<String, dynamic> sessionMetadata;

  const PracticeState({
    this.questions = const [],
    this.userAnswers = const {},
    this.isSubmitting = false,
    this.pqpDisplayNumbers = const {},
    this.isPQPMode = false,
    this.isSprintMode = false,
    this.modeLabel = 'Practice',
    this.subject,
    this.paper,
    this.durationMinutes,
    this.startedAt,
    this.totalQuestions = 0,
    this.sessionMetadata = const {},
  });

  PracticeState copyWith({
    List<Question>? questions,
    Map<String, dynamic>? userAnswers,
    bool? isSubmitting,
    Map<String, int>? pqpDisplayNumbers,
    bool? isPQPMode,
    bool? isSprintMode,
    String? modeLabel,
    String? subject,
    String? paper,
    int? durationMinutes,
    DateTime? startedAt,
    int? totalQuestions,
    Map<String, dynamic>? sessionMetadata,
  }) {
    return PracticeState(
      questions: questions ?? this.questions,
      userAnswers: userAnswers ?? this.userAnswers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      pqpDisplayNumbers: pqpDisplayNumbers ?? this.pqpDisplayNumbers,
      isPQPMode: isPQPMode ?? this.isPQPMode,
      isSprintMode: isSprintMode ?? this.isSprintMode,
      modeLabel: modeLabel ?? this.modeLabel,
      subject: subject ?? this.subject,
      paper: paper ?? this.paper,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startedAt: startedAt ?? this.startedAt,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      sessionMetadata: sessionMetadata ?? this.sessionMetadata,
    );
  }
}

class PracticeViewModel extends StateNotifier<PracticeState> {
  final Ref _ref;
  final QuestionRepository _questionRepository;
  final FirestoreDatabaseService _firestoreService;
  bool _disposed = false;

  // Option 3: Cache for parent questions to avoid repeated fetches
  final Map<String, Question> _parentCache = {};

  PracticeViewModel(this._ref, this._questionRepository, this._firestoreService)
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
  Future<void> startSession(
    List<Question> questions, {
    bool isPQPMode = false,
    bool isSprintMode = false,
    int? durationMinutes,
    String? modeKey,
    Map<String, dynamic>? sessionMetadata,
  }) async {
    if (!isActive) return;

    final subject = questions.isNotEmpty ? questions.first.subject : null;
    final paper = questions.isNotEmpty ? questions.first.paper : null;

    final computedModeLabel = _resolveModeLabel(
      isPQPMode: isPQPMode,
      isSprintMode: isSprintMode,
      modeKey: modeKey,
    );

    final mergedMetadata = <String, dynamic>{
      if (sessionMetadata != null) ...sessionMetadata,
      if (modeKey != null) 'modeKey': modeKey,
    };

    state = PracticeState(
      questions: questions,
      userAnswers: const {},
      pqpDisplayNumbers: _generateSequentialPqpNumbers(questions),
      isPQPMode: isPQPMode,
      isSprintMode: isSprintMode,
      modeLabel: computedModeLabel,
      subject: subject,
      paper: paper,
      durationMinutes: durationMinutes,
      startedAt: DateTime.now(),
      totalQuestions: questions.length,
      sessionMetadata: mergedMetadata,
    );

    // Option 3: Load parent context for questions that need it
    // Note: Backend should already enrich, but this is a fallback
    for (final question in questions) {
      if (question.hasParent && question.parentContext == null) {
        await loadParentContext(question);
      }
    }
  }

  String _resolveModeLabel({
    required bool isPQPMode,
    required bool isSprintMode,
    String? modeKey,
  }) {
    if (isPQPMode) return 'Past Paper';
    if (isSprintMode) return 'Sprint';
    switch (modeKey) {
      case 'quick_practice':
        return 'Sprint';
      case 'by_topic':
        return 'By Topic';
      case 'full_exam':
        return 'Past Paper';
      default:
        return 'Practice';
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
      state = state.copyWith(
        userAnswers: <String, dynamic>{},
        pqpDisplayNumbers: state.pqpDisplayNumbers,
        startedAt: DateTime.now(),
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
  /// IMPORTANT: Includes ALL questions, even unanswered ones (as null/empty)
  Future<Map<String, dynamic>?> submitTest() async {
    if (!isActive || state.isSubmitting) return null;

    state = state.copyWith(isSubmitting: true);

    try {
      // Determine metadata for this submission
      final subject = state.subject ?? state.questions.first.subject;
      final paper = state.paper ?? state.questions.first.paper;
      final totalQuestions = state.totalQuestions != 0
          ? state.totalQuestions
          : state.questions.length;
      final modeLabel = state.modeLabel;
      final durationMinutes = state.durationMinutes;
      final sessionDurationSeconds = state.startedAt != null
          ? DateTime.now().difference(state.startedAt!).inSeconds
          : null;
      final mergedMetadata = {
        ...state.sessionMetadata,
        'modeLabel': modeLabel,
        'subject': subject,
        'paper': paper,
        'totalQuestions': totalQuestions,
        if (durationMinutes != null)
          'configuredDurationMinutes': durationMinutes,
        if (sessionDurationSeconds != null)
          'sessionDurationSeconds': sessionDurationSeconds,
      };

      // ✅ FIX: Build complete submissions map INCLUDING unanswered questions
      // This ensures all questions appear in the grading results
      final completeSubmissions = <String, dynamic>{};
      for (final question in state.questions) {
        // Add answer if exists, otherwise add null (indicates unanswered)
        completeSubmissions[question.id] =
            state.userAnswers[question.id] ?? null;
      }

      // === DEBUG: Log what we're sending ===
      print('=== SUBMITTING TEST DATA ===');
      print('Subject: $subject');
      print('Paper: $paper');
      print('Total questions: ${state.questions.length}');
      print('Mode: $modeLabel');
      print('Answered questions: ${state.userAnswers.length}');
      print(
        'Unanswered questions: ${state.questions.length - state.userAnswers.length}',
      );
      print('User Answers:');
      completeSubmissions.forEach((questionId, answer) {
        print(
          '  $questionId: ${answer == null ? "[UNANSWERED]" : '"$answer"'} (${answer.runtimeType})',
        );
      });
      print('Questions with correctOrder:');
      for (final q in state.questions) {
        final format = q.format.toLowerCase();
        final isDragAndDrop =
            format == 'draganddrop' ||
            format == 'drag-and-drop' ||
            format == 'drag_drop' ||
            format == 'drag and drop';
        if (isDragAndDrop && q.correctOrder.isNotEmpty) {
          print('  ${q.id}: correctOrder = ${q.correctOrder}');
        }
      }
      print('=== END SUBMIT DATA ===\n');

      // Call the repository to trigger the 'gradeTest' Cloud Function
      final gradingResults = await _questionRepository.gradeTest(
        userAnswers: completeSubmissions,
        subject: subject,
        paper: paper,
        mode: modeLabel,
        totalQuestions: totalQuestions,
        durationMinutes: durationMinutes,
        sessionDurationSeconds: sessionDurationSeconds,
        sessionMetadata: mergedMetadata,
        isPQPMode: state.isPQPMode,
        isSprintMode: state.isSprintMode,
      );

      // === DEBUG: Log what we received ===
      print('=== RECEIVED GRADING RESULTS ===');
      print('Raw response: $gradingResults');
      if (gradingResults['results'] != null) {
        print('Total results: ${gradingResults['results'].length}');
        print('Individual question results:');
        for (final result in gradingResults['results']) {
          print('  Question ${result['questionId']}:');
          if (result['wasUnanswered'] == true) {
            print('    [UNANSWERED] - 0/${result['maxMarks']} marks');
          } else if (result['format'] == 'dragAndDrop' &&
              result['subFormat'] == 'ordering') {
            print('    User answers: ${result['userAnswers']}');
            print('    Correct order: ${result['correctOrder']}');
            print(
              '    Correct count: ${result['correctCount']}/${result['totalSteps']}',
            );
            print('    Is correct: ${result['isCorrect']}');
            print('    Marks: ${result['marksAwarded']}/${result['maxMarks']}');
          } else {
            print(
              '    ${result['isCorrect'] ? '✓' : '✗'} - ${result['marksAwarded']}/${result['maxMarks']} marks',
            );
          }
        }
      }
      print('=== END GRADING RESULTS ===\n');

      if (!isActive) return null; // Check if still active after async operation

      state = state.copyWith(isSubmitting: false);

      // Invalidate session history so the next visit reloads fresh data
      _ref.invalidate(sessionHistoryViewModelProvider);

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
