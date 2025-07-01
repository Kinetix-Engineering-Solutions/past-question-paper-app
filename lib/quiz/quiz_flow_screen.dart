import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'quiz_type_selector.dart';


enum QuizType { none, trueFalse }

final quizTypeProvider = StateProvider<QuizType>((ref) => QuizType.none);
final questionIndexProvider = StateProvider<int>((ref) => 0);

final questionsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'question': 'The heart is a muscle.',
      'answer': true,
    },
    {
      'question': 'Photosynthesis occurs in the mitochondria.',
      'answer': false,
    },
    {
      'question': 'White blood cells help fight infections.',
      'answer': true,
    },
    {
      'question': 'DNA is found only in the cell membrane.',
      'answer': false,
    },
    {
      'question': 'Red blood cells carry oxygen throughout the body.',
      'answer': true,
    },
  ];
});


// --- Main Widget ---
class QuizFlowScreen extends ConsumerWidget {
  const QuizFlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizType = ref.watch(quizTypeProvider);

    return Scaffold(
      appBar: AppBar(
  title: const Text('Quiz Session'),
  leading: quizType != QuizType.none
      ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Reset state to show type selector
            ref.read(quizTypeProvider.notifier).state = QuizType.none;
            ref.read(questionIndexProvider.notifier).state = 0;
          },
        )
      : null,
),


      body: Padding(
        padding: const EdgeInsets.all(20),
        child: quizType == QuizType.none
            ? _buildTypeSelector(context, ref)
            : _buildQuiz(context, ref),
      ),
    );
  }

 Widget _buildTypeSelector(BuildContext context, WidgetRef ref) {
  return QuizTypeSelector(
    onSelect: (type) {
      if (type == 'true false') {
        ref.read(quizTypeProvider.notifier).state = QuizType.trueFalse;
      } else {
        // You can expand this to other types
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: $type')),
        );
      }
    },
  );
}

  Widget _buildQuiz(BuildContext context, WidgetRef ref) {
    final index = ref.watch(questionIndexProvider);
    final questions = ref.watch(questionsProvider);
    final question = questions[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question ${index + 1} of ${questions.length}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Text(question['question'], style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 30),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _nextOrSubmit(context, ref),
              child: const Text('True'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _nextOrSubmit(context, ref),
              child: const Text('False'),
            ),
          ],
        ),
      ],
    );
  }

  void _nextOrSubmit(BuildContext context, WidgetRef ref) {
    final index = ref.read(questionIndexProvider);
    final total = ref.read(questionsProvider).length;

    if (index < total - 1) {
      ref.read(questionIndexProvider.notifier).state++;
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
