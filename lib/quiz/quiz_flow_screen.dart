import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/core/models/quiz_type.dart';

final selectedQuizTypeProvider = StateProvider<String?>((ref) => null);
final currentQuestionIndexProvider = StateProvider<int>((ref) => 0);

final trueFalseQuestionsProvider = Provider<List<Map<String, dynamic>>>((ref) => [
  {'question': 'The heart is a muscle.', 'answer': true},
  {'question': 'Plants do not perform photosynthesis.', 'answer': false},
]);

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
  void submitQuiz(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to submit your answers?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Quiz submitted!')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedQuizType = ref.watch(selectedQuizTypeProvider);
    final currentIndex = ref.watch(currentQuestionIndexProvider);
    final questions = ref.watch(trueFalseQuestionsProvider);

    Widget _buildQuizTypeSelection() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Quiz Type:', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => ref.read(selectedQuizTypeProvider.notifier).state = 'true_false',
            child: const Text('True or False'),
          ),
          ElevatedButton(
            onPressed: () => ref.read(selectedQuizTypeProvider.notifier).state = 'mcq',
            child: const Text('Multiple Choice'),
          ),
        ],
      );
    }

    Widget _buildTrueFalseQuiz() {
      final question = questions[currentIndex];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question ${currentIndex + 1}:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(question['question']),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  if (currentIndex < questions.length - 1) {
                    ref.read(currentQuestionIndexProvider.notifier).state++;
                  } else {
                    submitQuiz(context);
                  }
                },
                child: const Text('True'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  if (currentIndex < questions.length - 1) {
                    ref.read(currentQuestionIndexProvider.notifier).state++;
                  } else {
                    submitQuiz(context);
                  }
                },
                child: const Text('False'),
              ),
            ],
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: selectedQuizType == null
            ? _buildQuizTypeSelection()
            : selectedQuizType == 'true_false'
                ? _buildTrueFalseQuiz()
                : const Center(child: Text('Other quiz types not implemented')),
      ),
    );
  }
}
