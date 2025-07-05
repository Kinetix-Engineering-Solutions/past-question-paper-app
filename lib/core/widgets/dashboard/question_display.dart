import 'package:flutter/material.dart';

class QuestionDisplay extends StatelessWidget {
  final String questionText;

  const QuestionDisplay({
    super.key,
    required this.questionText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        questionText,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}