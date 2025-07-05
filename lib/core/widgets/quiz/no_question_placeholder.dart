import 'package:flutter/material.dart';

class NoQuestionsPlaceholder extends StatelessWidget {
  const NoQuestionsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No questions available for this quiz type',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}