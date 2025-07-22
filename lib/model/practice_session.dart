import 'package:past_question_paper_stem/model/practice_mode.dart';
import 'package:past_question_paper_stem/model/topic.dart';
import 'package:past_question_paper_stem/model/question.dart';

class PracticeSession {
  final String id;
  final Topic topic;
  final PracticeMode mode;
  final List<Question> questions;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final Map<String, dynamic> userAnswers; // questionId -> answer
  final PracticeSessionStatus status;
  final int currentQuestionIndex;
  final int? score; // calculated when session is completed

  const PracticeSession({
    required this.id,
    required this.topic,
    required this.mode,
    required this.questions,
    required this.startTime,
    this.endTime,
    this.duration,
    this.userAnswers = const {},
    this.status = PracticeSessionStatus.notStarted,
    this.currentQuestionIndex = 0,
    this.score,
  });

  /// Create a new practice session
  factory PracticeSession.create({
    required Topic topic,
    required PracticeMode mode,
    required List<Question> questions,
  }) {
    return PracticeSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      topic: topic,
      mode: mode,
      questions: questions,
      startTime: DateTime.now(),
      userAnswers: {},
      status: PracticeSessionStatus.notStarted,
      currentQuestionIndex: 0,
    );
  }

  /// Copy with updated fields
  PracticeSession copyWith({
    String? id,
    Topic? topic,
    PracticeMode? mode,
    List<Question>? questions,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    Map<String, dynamic>? userAnswers,
    PracticeSessionStatus? status,
    int? currentQuestionIndex,
    int? score,
  }) {
    return PracticeSession(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      mode: mode ?? this.mode,
      questions: questions ?? this.questions,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      userAnswers: userAnswers ?? this.userAnswers,
      status: status ?? this.status,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
    );
  }

  /// Check if session is active (started but not finished)
  bool get isActive => status == PracticeSessionStatus.inProgress;

  /// Check if session is completed
  bool get isCompleted => status == PracticeSessionStatus.completed;

  /// Check if session is expired (time limit reached)
  bool get isExpired => status == PracticeSessionStatus.timeExpired;

  /// Get elapsed time from start
  Duration get elapsedTime {
    final now = DateTime.now();
    return now.difference(startTime);
  }

  /// Get remaining time for timed sessions
  Duration? get remainingTime {
    if (!mode.isTimeLimited) return null;

    final elapsed = elapsedTime;
    final remaining = mode.duration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Check if time limit is reached
  bool get isTimeUp {
    if (!mode.isTimeLimited) return false;
    final remaining = remainingTime;
    return remaining == null || remaining.inSeconds <= 0;
  }

  /// Get current question
  Question? get currentQuestion {
    if (currentQuestionIndex >= 0 && currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null;
  }

  /// Check if there are more questions
  bool get hasNextQuestion => currentQuestionIndex < questions.length - 1;

  /// Check if this is the last question
  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;

  /// Get progress percentage (0.0 to 1.0)
  double get progress {
    if (questions.isEmpty) return 0.0;
    return (currentQuestionIndex + 1) / questions.length;
  }

  /// Get number of answered questions
  int get answeredCount => userAnswers.length;

  /// Get number of remaining questions
  int get remainingCount => questions.length - answeredCount;

  /// Calculate score if session is completed
  int calculateScore() {
    if (!isCompleted) return 0;

    int correctAnswers = 0;
    for (final question in questions) {
      final userAnswer = userAnswers[question.id];
      if (userAnswer != null && _isAnswerCorrect(question, userAnswer)) {
        correctAnswers++;
      }
    }

    return (correctAnswers / questions.length * 100).round();
  }

  /// Check if a user answer is correct for a given question
  bool _isAnswerCorrect(Question question, dynamic userAnswer) {
    switch (question.questionType.toLowerCase()) {
      case 'multiple-choice':
      case 'true-false':
        return question.correctAnswer.contains(userAnswer.toString());

      case 'drag-and-drop':
        if (userAnswer is List<int>) {
          return _listsEqual(userAnswer, question.correctOrder);
        }
        return false;

      default:
        return false;
    }
  }

  /// Helper method to compare two lists for equality
  bool _listsEqual<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topicId': topic.id,
      'mode': mode.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration?.inSeconds,
      'userAnswers': userAnswers,
      'status': status.name,
      'currentQuestionIndex': currentQuestionIndex,
      'score': score,
      'questionCount': questions.length,
    };
  }

  /// Create from JSON
  static PracticeSession fromJson(
    Map<String, dynamic> json,
    Topic topic,
    List<Question> questions,
  ) {
    return PracticeSession(
      id: json['id'],
      topic: topic,
      mode: PracticeMode.values.firstWhere(
        (mode) => mode.name == json['mode'],
        orElse: () => PracticeMode.standard,
      ),
      questions: questions,
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      duration:
          json['duration'] != null ? Duration(seconds: json['duration']) : null,
      userAnswers: Map<String, dynamic>.from(json['userAnswers'] ?? {}),
      status: PracticeSessionStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => PracticeSessionStatus.notStarted,
      ),
      currentQuestionIndex: json['currentQuestionIndex'] ?? 0,
      score: json['score'],
    );
  }
}

enum PracticeSessionStatus {
  notStarted,
  inProgress,
  completed,
  timeExpired,
  paused,
}

extension PracticeSessionStatusExtension on PracticeSessionStatus {
  String get displayName {
    switch (this) {
      case PracticeSessionStatus.notStarted:
        return 'Not Started';
      case PracticeSessionStatus.inProgress:
        return 'In Progress';
      case PracticeSessionStatus.completed:
        return 'Completed';
      case PracticeSessionStatus.timeExpired:
        return 'Time Expired';
      case PracticeSessionStatus.paused:
        return 'Paused';
    }
  }

  bool get isActive => this == PracticeSessionStatus.inProgress;
  bool get isFinished =>
      this == PracticeSessionStatus.completed ||
      this == PracticeSessionStatus.timeExpired;
}
