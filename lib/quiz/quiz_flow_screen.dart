import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'quiz_type_selector.dart';

enum QuizType { none, trueFalse }

final quizTypeProvider = StateProvider<QuizType>((ref) => QuizType.none);
final questionIndexProvider = StateProvider<int>((ref) => 0);
final timerProvider = StateProvider<int>((ref) => 30);

final questionsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {'question': 'The heart is a muscle.', 'answer': true},
    {'question': 'Photosynthesis occurs in the mitochondria.', 'answer': false},
    {'question': 'White blood cells help fight infections.', 'answer': true},
    {'question': 'DNA is found only in the cell membrane.', 'answer': false},
    {'question': 'Red blood cells carry oxygen throughout the body.', 'answer': true},
  ];
});

class QuizFlowScreen extends ConsumerStatefulWidget {
  const QuizFlowScreen({super.key});

  @override
  ConsumerState<QuizFlowScreen> createState() => _QuizFlowScreenState();
}

class _QuizFlowScreenState extends ConsumerState<QuizFlowScreen> {
  Timer? _timer;

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
    final total = ref.read(questionsProvider).length;

    if (index < total - 1) {
      ref.read(questionIndexProvider.notifier).state++;
      _startTimer();
    } else {
      _showSubmitDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizType = ref.watch(quizTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Session'),
        leading: quizType != QuizType.none
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _timer?.cancel();
                  ref.read(quizTypeProvider.notifier).state = QuizType.none;
                  ref.read(questionIndexProvider.notifier).state = 0;
                },
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: quizType == QuizType.none
            ? _buildTypeSelector()
            : _buildQuiz(),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return QuizTypeSelector(
      onSelect: (QuizType type) {
        ref.read(quizTypeProvider.notifier).state = type;
        ref.read(questionIndexProvider.notifier).state = 0;
        _startTimer();
      },
    );
  }

  Widget _buildQuiz() {
    final index = ref.watch(questionIndexProvider);
    final timer = ref.watch(timerProvider);
    final questions = ref.watch(questionsProvider);
    final question = questions[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question ${index + 1} of ${questions.length}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Time Left: $timer seconds',
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        Text(question['question'], style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 30),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _nextOrSubmit(),
              child: const Text('True'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _nextOrSubmit(),
              child: const Text('False'),
            ),
          ],
        ),
      ],
    );
  }

  void _nextOrSubmit() {
    final index = ref.read(questionIndexProvider);
    final total = ref.read(questionsProvider).length;

    if (index < total - 1) {
      ref.read(questionIndexProvider.notifier).state++;
      _startTimer();
    } else {
      _showSubmitDialog(context);
    }
  }

  void _showSubmitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Submit Quiz?'),
        content: const Text('Do you want to end the session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Quiz Submitted!')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
