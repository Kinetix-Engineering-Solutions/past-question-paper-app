import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/quiz_type.dart';
import '../../core/widgets/quiz/no_question_placeholder.dart';
import '../../core/widgets/quiz/multiple_choice_options.dart';
import '../../core/widgets/dashboard/question_display.dart';
import '../../core/widgets/quiz/quiz_navigation_buttons.dart';
import '../../core/widgets/quiz/quiz_progress_indicator.dart';
import '../../core/widgets/quiz/quiz_timer.dart';
import '../../core/widgets/quiz/submit_quiz.dart';
import '../../core/widgets/quiz/true_false_options.dart';

// Riverpod providers
final questionIndexProvider = StateProvider<int>((ref) => 0);
final timerProvider = StateProvider<int>((ref) => 30);
final selectedAnswersProvider = StateProvider<Map<int, dynamic>>((ref) => {});

// Sample questions data
final sampleQuestions = {
  'Biology': {
    QuizType.trueFalse: [
      {'question': 'Plants make food through photosynthesis.', 'answer': true},
      {'question': 'Fungi can photosynthesize.', 'answer': false},
      {'question': 'All bacteria are harmful to humans.', 'answer': false},
      {'question': 'DNA is found in the nucleus of cells.', 'answer': true},
    ],
    QuizType.multipleChoice: [
      {
        'question': 'What is the powerhouse of the cell?',
        'options': ['Nucleus', 'Mitochondria', 'Chloroplast', 'Ribosome'],
        'answer': 'Mitochondria',
      },
      {
        'question': 'Which organelle is responsible for photosynthesis?',
        'options': ['Mitochondria', 'Nucleus', 'Chloroplast', 'Vacuole'],
        'answer': 'Chloroplast',
      },
    ],
  },
  'Physics': {
    QuizType.trueFalse: [
      {'question': 'Speed is a scalar quantity.', 'answer': true},
      {'question': 'Velocity is a scalar quantity.', 'answer': false},
    ],
    QuizType.multipleChoice: [
      {
        'question': 'What is the unit of force?',
        'options': ['Newton', 'Joule', 'Watt', 'Pascal'],
        'answer': 'Newton',
      },
    ],
  },
  'Mathematics': {
    QuizType.trueFalse: [
      {'question': 'The square root of 16 is 4.', 'answer': true},
      {'question': 'Pi is exactly 3.14.', 'answer': false},
    ],
    QuizType.multipleChoice: [
      {
        'question': 'What is 2 + 2?',
        'options': ['3', '4', '5', '6'],
        'answer': '4',
      },
    ],
  },
};

class QuizFlowScreen extends ConsumerStatefulWidget {
  final String subjectId;
  final String subjectName;
  final String gradeId;
  final String gradeName;
  final QuizType quizType;

  const QuizFlowScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.gradeId,
    required this.gradeName,
    required this.quizType,
  });

  @override
  ConsumerState<QuizFlowScreen> createState() => _QuizFlowScreenState();
}

class _QuizFlowScreenState extends ConsumerState<QuizFlowScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Reset providers when starting quiz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questionIndexProvider.notifier).state = 0;
      ref.read(selectedAnswersProvider.notifier).state = {};
      _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    ref.read(timerProvider.notifier).state = 30;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = ref.read(timerProvider);
      if (current > 0) {
        ref.read(timerProvider.notifier).state--;
      } else {
        _handleNextAuto();
      }
    });
  }

  void _handleNextAuto() {
    _timer?.cancel();
    final index = ref.read(questionIndexProvider);
    final questions = _getQuestions();

    if (index < questions.length - 1) {
      ref.read(questionIndexProvider.notifier).state++;
      _startTimer();
    } else {
      _showSubmitDialog(context);
    }
  }

  List<dynamic> _getQuestions() {
    final subjectMap = sampleQuestions[widget.subjectName];
    if (subjectMap == null) return [];

    return subjectMap[widget.quizType] ?? [];
  }

  void _selectAnswer(dynamic answer) {
    final currentIndex = ref.read(questionIndexProvider);
    final currentAnswers = ref.read(selectedAnswersProvider);
    ref.read(selectedAnswersProvider.notifier).state = {
      ...currentAnswers,
      currentIndex: answer,
    };
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(questionIndexProvider);
    final timer = ref.watch(timerProvider);
    final selectedAnswers = ref.watch(selectedAnswersProvider);
    final questionsList = _getQuestions();

    if (questionsList.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.subjectName} Quiz'),
          backgroundColor: const Color(0xFF6C5CE7),
          foregroundColor: Colors.white,
        ),
        body: const NoQuestionsPlaceholder(),
      );
    }

    final question = questionsList[index];
    final currentAnswer = selectedAnswers[index];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subjectName} Quiz'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _timer?.cancel();
            context.pop();
          },
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuizProgressIndicator(
              currentIndex: index,
              totalQuestions: questionsList.length,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${index + 1} of ${questionsList.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                QuizTimer(timeRemaining: timer),
              ],
            ),
            const SizedBox(height: 30),
            QuestionDisplay(questionText: question['question'] as String),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (widget.quizType == QuizType.trueFalse)
                      TrueFalseOptions(
                        currentAnswer: currentAnswer as bool?,
                        onSelectAnswer: _selectAnswer,
                      )
                    else if (widget.quizType == QuizType.multipleChoice)
                      MultipleChoiceOptions(
                        options: question['options'] as List,
                        currentAnswer: currentAnswer,
                        onSelectAnswer: _selectAnswer,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            QuizNavigationButtons(
              onPrevious: index > 0 ? _handlePrevious : null,
              onNext: index < questionsList.length - 1 ? _nextOrSubmit : null,
              onSubmit: () => _showSubmitDialog(context),
              showNext: index < questionsList.length - 1,
            ),
          ],
        ),
      ),
    );
  }

  void _nextOrSubmit() {
    final index = ref.read(questionIndexProvider);
    final questions = _getQuestions();

    if (index < questions.length - 1) {
      ref.read(questionIndexProvider.notifier).state++;
      _startTimer();
    } else {
      _showSubmitDialog(context);
    }
  }

  void _handlePrevious() {
    final index = ref.read(questionIndexProvider);
    if (index > 0) {
      ref.read(questionIndexProvider.notifier).state--;
      _startTimer();
    }
  }

  void _showSubmitDialog(BuildContext context) {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SubmitQuizDialog(
        onCancel: () {
          Navigator.pop(context);
          _startTimer(); // Resume timer
        },
        onSubmit: () {
          Navigator.pop(context);
          _submitQuiz();
        },
      ),
    );
  }
// Submit Button
  void _submitQuiz() {
    final selectedAnswers = ref.read(selectedAnswersProvider);
    final questionsList = _getQuestions();

    // Calculate score
    int correctAnswers = 0;
    for (int i = 0; i < questionsList.length; i++) {
      final question = questionsList[i];
      final userAnswer = selectedAnswers[i];
      final correctAnswer = question['answer'];

      if (userAnswer == correctAnswer) {
        correctAnswers++;
      }
    }

    // Navigate back to dashboard and show result
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Quiz Submitted! Score: $correctAnswers/${questionsList.length}',
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}