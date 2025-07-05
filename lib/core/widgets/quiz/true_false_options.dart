import 'package:flutter/material.dart';

class TrueFalseOptions extends StatelessWidget {
  final bool? currentAnswer;
  final ValueChanged<bool> onSelectAnswer;

  const TrueFalseOptions({
    super.key,
    required this.currentAnswer,
    required this.onSelectAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => onSelectAnswer(true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  currentAnswer == true ? const Color(0xFF6C5CE7) : Colors.white,
              foregroundColor:
                  currentAnswer == true ? Colors.white : const Color(0xFF6C5CE7),
              side: const BorderSide(color: Color(0xFF6C5CE7)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('True', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => onSelectAnswer(false),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  currentAnswer == false ? const Color(0xFF6C5CE7) : Colors.white,
              foregroundColor:
                  currentAnswer == false ? Colors.white : const Color(0xFF6C5CE7),
              side: const BorderSide(color: Color(0xFF6C5CE7)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('False', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}