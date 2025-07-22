import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/practice_mode.dart';
import 'package:past_question_paper_stem/model/practice_session.dart';
import 'package:past_question_paper_stem/model/topic.dart';
import 'package:past_question_paper_stem/model/question.dart';
import 'package:past_question_paper_stem/services/firestore_database_firebase.dart';

// Practice View Model Provider
final practiceViewModelProvider =
    StateNotifierProvider<PracticeViewModel, PracticeState>((ref) {
      return PracticeViewModel();
    });

// Practice State
class PracticeState {
  final bool isLoading;
  final String? error;
  final PracticeSession? currentSession;
  final List<Question> availableQuestions;
  final Duration? remainingTime;
  final bool showResults;

  const PracticeState({
    this.isLoading = false,
    this.error,
    this.currentSession,
    this.availableQuestions = const [],
    this.remainingTime,
    this.showResults = false,
  });

  PracticeState copyWith({
    bool? isLoading,
    String? error,
    PracticeSession? currentSession,
    List<Question>? availableQuestions,
    Duration? remainingTime,
    bool? showResults,
  }) {
    return PracticeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentSession: currentSession ?? this.currentSession,
      availableQuestions: availableQuestions ?? this.availableQuestions,
      remainingTime: remainingTime ?? this.remainingTime,
      showResults: showResults ?? this.showResults,
    );
  }

  bool get hasActiveSession => currentSession?.isActive ?? false;
  bool get isSessionCompleted => currentSession?.isCompleted ?? false;
  Question? get currentQuestion => currentSession?.currentQuestion;
  double get progress => currentSession?.progress ?? 0.0;
}

class PracticeViewModel extends StateNotifier<PracticeState> {
  final FirestoreDatabaseService _database = FirestoreDatabaseService();
  Timer? _timer;

  PracticeViewModel() : super(const PracticeState());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Load questions for a topic to prepare for practice
  Future<void> loadQuestionsForTopic(Topic topic) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implement getQuestionsForTopic in FirestoreDatabaseService
      // For now, we'll use mock data
      final questions = await _getMockQuestions(topic);

      state = state.copyWith(availableQuestions: questions, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load questions: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Start a new practice session
  Future<void> startPracticeSession(Topic topic, PracticeMode mode) async {
    if (state.availableQuestions.isEmpty) {
      state = state.copyWith(error: 'No questions available for this topic');
      return;
    }

    try {
      // Shuffle and select questions based on mode
      final selectedQuestions = _selectQuestionsForMode(
        state.availableQuestions,
        mode,
      );

      final session = PracticeSession.create(
        topic: topic,
        mode: mode,
        questions: selectedQuestions,
      );

      // Start the session
      final startedSession = session.copyWith(
        status: PracticeSessionStatus.inProgress,
        startTime: DateTime.now(),
      );

      state = state.copyWith(
        currentSession: startedSession,
        showResults: false,
        error: null,
      );

      // Start timer for timed sessions
      if (mode.isTimeLimited) {
        _startTimer();
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to start practice session: ${e.toString()}',
      );
    }
  }

  /// Answer the current question
  void answerQuestion(dynamic answer) {
    final session = state.currentSession;
    if (session == null || !session.isActive) return;

    final currentQuestion = session.currentQuestion;
    if (currentQuestion == null) return;

    // Add answer to user answers
    final updatedAnswers = Map<String, dynamic>.from(session.userAnswers);
    updatedAnswers[currentQuestion.id] = answer;

    final updatedSession = session.copyWith(userAnswers: updatedAnswers);
    state = state.copyWith(currentSession: updatedSession);
  }

  /// Move to next question
  void nextQuestion() {
    final session = state.currentSession;
    if (session == null || !session.isActive) return;

    if (session.hasNextQuestion) {
      final updatedSession = session.copyWith(
        currentQuestionIndex: session.currentQuestionIndex + 1,
      );
      state = state.copyWith(currentSession: updatedSession);
    } else {
      // This was the last question, complete the session
      _completeSession();
    }
  }

  /// Move to previous question
  void previousQuestion() {
    final session = state.currentSession;
    if (session == null || !session.isActive) return;

    if (session.currentQuestionIndex > 0) {
      final updatedSession = session.copyWith(
        currentQuestionIndex: session.currentQuestionIndex - 1,
      );
      state = state.copyWith(currentSession: updatedSession);
    }
  }

  /// Pause the current session
  void pauseSession() {
    final session = state.currentSession;
    if (session == null || !session.isActive) return;

    _timer?.cancel();

    final pausedSession = session.copyWith(
      status: PracticeSessionStatus.paused,
    );

    state = state.copyWith(currentSession: pausedSession);
  }

  /// Resume a paused session
  void resumeSession() {
    final session = state.currentSession;
    if (session == null || session.status != PracticeSessionStatus.paused)
      return;

    final resumedSession = session.copyWith(
      status: PracticeSessionStatus.inProgress,
    );

    state = state.copyWith(currentSession: resumedSession);

    // Restart timer if this is a timed session
    if (session.mode.isTimeLimited) {
      _startTimer();
    }
  }

  /// Complete the current session
  void _completeSession() {
    final session = state.currentSession;
    if (session == null) return;

    _timer?.cancel();

    final completedSession = session.copyWith(
      status: PracticeSessionStatus.completed,
      endTime: DateTime.now(),
      duration: session.elapsedTime,
      score: session.calculateScore(),
    );

    state = state.copyWith(currentSession: completedSession, showResults: true);
  }

  /// End session due to time expiry
  void _expireSession() {
    final session = state.currentSession;
    if (session == null) return;

    _timer?.cancel();

    final expiredSession = session.copyWith(
      status: PracticeSessionStatus.timeExpired,
      endTime: DateTime.now(),
      duration: session.mode.duration,
      score: session.calculateScore(),
    );

    state = state.copyWith(currentSession: expiredSession, showResults: true);
  }

  /// Manually finish the session early
  void finishSession() {
    _completeSession();
  }

  /// Reset and clear current session
  void endSession() {
    _timer?.cancel();
    state = state.copyWith(
      currentSession: null,
      showResults: false,
      remainingTime: null,
    );
  }

  /// Start timer for timed sessions
  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final session = state.currentSession;
      if (session == null || !session.isActive) {
        timer.cancel();
        return;
      }

      final remaining = session.remainingTime;
      if (remaining == null) {
        timer.cancel();
        return;
      }

      state = state.copyWith(remainingTime: remaining);

      // Check if time is up
      if (session.isTimeUp) {
        timer.cancel();
        _expireSession();
      }
    });
  }

  /// Select questions based on practice mode
  List<Question> _selectQuestionsForMode(
    List<Question> allQuestions,
    PracticeMode mode,
  ) {
    final shuffled = List<Question>.from(allQuestions)..shuffle();

    // For now, just select a reasonable number based on mode
    int maxQuestions;
    switch (mode) {
      case PracticeMode.quick:
        maxQuestions = 5;
        break;
      case PracticeMode.standard:
        maxQuestions = 10;
        break;
      case PracticeMode.extended:
        maxQuestions = 20;
        break;
      case PracticeMode.unlimited:
        maxQuestions = shuffled.length;
        break;
    }

    return shuffled.take(maxQuestions).toList();
  }

  /// Mock questions for testing (TODO: Replace with actual database calls)
  Future<List<Question>> _getMockQuestions(Topic topic) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      Question(
        id: '1',
        questionType: 'multiple-choice',
        questionText: 'What is 2 + 2?',
        options: ['2', '3', '4', '5'],
        correctOrder: [],
        correctAnswer: ['4'],
        explanation: '2 + 2 equals 4',
      ),
      Question(
        id: '2',
        questionType: 'true-false',
        questionText: 'The Earth is flat.',
        options: ['True', 'False'],
        correctOrder: [],
        correctAnswer: ['False'],
        explanation: 'The Earth is round',
      ),
      Question(
        id: '3',
        questionType: 'multiple-choice',
        questionText: 'What is the capital of France?',
        options: ['London', 'Berlin', 'Paris', 'Madrid'],
        correctOrder: [],
        correctAnswer: ['Paris'],
        explanation: 'Paris is the capital of France',
      ),
    ];
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset all state
  void reset() {
    _timer?.cancel();
    state = const PracticeState();
  }
}
