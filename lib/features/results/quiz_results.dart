import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:past_question_paper_v1/core/models/result.dart';

class ResultPage extends ConsumerWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(resultViewModelProvider);
    final latest = results.last;

    final score = 71;
    final passed = score >= 70;

    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFFF8F9FA)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // ✅ Enlarged Card
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 320),
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'YOUR QUIZ RESULTS',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        height: 120,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: score >= 70
                              ? Lottie.asset(
                                  'assets/animations/confetti.json',
                                  repeat: true,
                                )
                              : const Icon(
                                  Icons.sentiment_dissatisfied,
                                  size: 80,
                                  color: Colors.red,
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        '$score%',
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: passed ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Time: ${latest.timeTaken}',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              _actionButton('View Answers', () {
                context.go('/answers');
              }),
              const SizedBox(height: 16),
              _actionButton('Retake Quiz', () {
                context.go('/quizsession');
              }),
              const SizedBox(height: 16),
              _actionButton('History', () {
                context.go('/history');
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 17),
        ),
        child: Text(label),
      ),
    );
  }
}
