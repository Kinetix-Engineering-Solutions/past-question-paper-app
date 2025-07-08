import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:past_question_paper_v1/core/models/review_answers.dart';

class ReviewAnswersPage extends ConsumerWidget {
  const ReviewAnswersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(reviewAnswersProvider).answers;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Answers"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/result'),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: answers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = answers[index];

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: item.isCorrect ? Colors.green[50] : Colors.red[50],
              border: Border.all(
                color: item.isCorrect ? Colors.green : Colors.red,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Question ${item.questionNumber}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      item.isCorrect ? Icons.check_circle : Icons.cancel,
                      color: item.isCorrect ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.isCorrect ? "Correct" : "Incorrect",
                      style: TextStyle(
                        color: item.isCorrect ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("✅ Correct Answer: ${item.correctAnswer}"),
                Text("📝 Your Answer: ${item.userAnswer}"),
              ],
            ),
          );
        },
      ),
    );
  }
}
