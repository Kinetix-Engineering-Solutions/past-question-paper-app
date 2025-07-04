import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/quiz_type.dart';

final questionIndexProvider = StateProvider<int>((ref) => 0);
final timerProvider = StateProvider<int>((ref) => 30);

final sampleQuestions = {
  'Biology': {
    QuizType.trueFalse: [
      {'question': 'Plants make food through photosynthesis.', 'answer': true},
      {'question': 'Fungi can photosynthesize.', 'answer': false},
    ],
    QuizType.multipleChoice: [
      {
        'question': 'What is the powerhouse of the cell?',
        'options': ['Nucleus', 'Mitochondria', 'Chloroplast', 'Ribosome'],
        'answer': 'Mitochondria',
      },
    ],
  },
  'Physics': {
    QuizType.trueFalse: [
      {'question': 'Speed is a scalar quantity.', 'answer': true},
    ],
  }
};

class QuizFlowScreen extends ConsumerStatefulWidget {
  final String subjectId;
  final QuizType type;

  const QuizFlowScreen({
    super.key,
    required this.subjectId,
    required this.type,
  });

  @override
  ConsumerState<QuizFlowScreen> createState() => _QuizFlowScreenState();
}

class _QuizFlowScreenState extends ConsumerState<QuizFlowScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
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
    final subjectMap = sampleQuestions[widget.subjectId];
    if (subjectMap == null) return [];

    return subjectMap[widget.type] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(questionIndexProvider);
    final timer = ref.watch(timerProvider);
    final questionsList = _getQuestions();

    if (questionsList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Session')),
        body: const Center(child: Text('No questions available')),
      );
    }

    final question = questionsList[index];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Session'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _timer?.cancel();
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question ${index + 1} of ${questionsList.length}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('⏰ $timer seconds',
                style: const TextStyle(color: Colors.red, fontSize: 16)),
            const SizedBox(height: 20),
            Text(question['question'] as String,
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            if (widget.type == QuizType.trueFalse)
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _nextOrSubmit,
                    child: const Text('True'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _nextOrSubmit,
                    child: const Text('False'),
                  ),
                ],
              )
            else if (widget.type == QuizType.multipleChoice)
              ...List.generate((question['options'] as List).length, (i) {
                final label = String.fromCharCode(65 + i); // A, B, C, ...
                final text = question['options'][i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton(
                    onPressed: _nextOrSubmit,
                    child: Text('$label) $text'),
                  ),
                );
              }),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _handlePrevious,
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: () => _showSubmitDialog(context),
                  child: const Text('Submit'),
                ),
              ],
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
