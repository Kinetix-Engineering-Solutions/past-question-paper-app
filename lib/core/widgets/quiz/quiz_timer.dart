import 'package:flutter/material.dart';

class QuizTimer extends StatelessWidget {
  final int timeRemaining;

  const QuizTimer({
    super.key,
    required this.timeRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: timeRemaining <= 10 ? Colors.red : const Color(0xFF6C5CE7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '⏰ ${timeRemaining}s',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}