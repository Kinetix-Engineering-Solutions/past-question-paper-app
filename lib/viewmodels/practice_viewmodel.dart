import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/practice_mode.dart';
import 'package:past_question_paper_stem/model/practice_session.dart';
import 'package:past_question_paper_stem/model/topic.dart';
import 'package:past_question_paper_stem/model/question.dart';
import 'package:past_question_paper_stem/repositories/question_repository.dart';

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
  final QuestionRepository _questionRepository = QuestionRepository();
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
      // Debug: Print the topic ID being used
      print('🔍 Loading questions for topic ID: ${topic.id}');
      print('🔍 Topic name: ${topic.name}');

      // Load questions from Firestore using QuestionRepository
      final questions = await _questionRepository.getQuestionsForTopic(
        topic.id,
      );

      // Debug: Print results
      print('🔍 Found ${questions.length} questions for topic ${topic.id}');
      if (questions.isNotEmpty) {
        print('🔍 First question topicId: ${questions.first.topicId}');
        print('🔍 First question type: ${questions.first.questionType}');
      }

      // Convert all gs:// URLs to HTTP URLs for better performance
      print('🔄 Converting image URLs to HTTP URLs...');
      final questionsWithUrls = await Future.wait(
        questions.map((q) => q.withHttpUrls()),
      );
      print(
        '✅ URL conversion completed for ${questionsWithUrls.length} questions',
      );

      state = state.copyWith(
        availableQuestions: questionsWithUrls,
        isLoading: false,
      );
    } catch (e) {
      print('❌ Error loading questions: $e');
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

    // First update the status, then calculate score
    final sessionWithCompletedStatus = session.copyWith(
      status: PracticeSessionStatus.completed,
      endTime: DateTime.now(),
      duration: session.elapsedTime,
    );

    final completedSession = sessionWithCompletedStatus.copyWith(
      score: sessionWithCompletedStatus.calculateScore(),
    );

    state = state.copyWith(currentSession: completedSession, showResults: true);
  }

  /// End session due to time expiry
  void _expireSession() {
    final session = state.currentSession;
    if (session == null) return;

    _timer?.cancel();

    // First update the status, then calculate score
    final sessionWithExpiredStatus = session.copyWith(
      status: PracticeSessionStatus.timeExpired,
      endTime: DateTime.now(),
      duration: session.mode.duration,
    );

    final expiredSession = sessionWithExpiredStatus.copyWith(
      score: sessionWithExpiredStatus.calculateScore(),
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

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Start a new practice session with the same topic and mode as the current session
  Future<void> startNewSession() async {
    final currentSession = state.currentSession;
    if (currentSession == null) {
      state = state.copyWith(error: 'No current session to restart');
      return;
    }

    final topic = currentSession.topic;
    final mode = currentSession.mode;

    // Clear current session first
    endSession();

    // Ensure we have questions loaded for this topic
    if (state.availableQuestions.isEmpty) {
      await loadQuestionsForTopic(topic);
    }

    // Start a new session with the same topic and mode
    await startPracticeSession(topic, mode);
  }

  /// Reset all state
  void reset() {
    _timer?.cancel();
    state = const PracticeState();
  }
}
