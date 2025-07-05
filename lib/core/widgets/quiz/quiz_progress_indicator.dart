import 'package:flutter/material.dart';

class QuizProgressIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;

  const QuizProgressIndicator({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: (currentIndex + 1) / totalQuestions,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
        ),
        const SizedBox(height: 20),
        Text(
          'Question ${currentIndex + 1} of $totalQuestions',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}