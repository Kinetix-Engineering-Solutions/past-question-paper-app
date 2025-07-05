import 'package:flutter/material.dart';

class MultipleChoiceOptions extends StatelessWidget {
  final List<dynamic> options;
  final dynamic currentAnswer;
  final ValueChanged<dynamic> onSelectAnswer;

  const MultipleChoiceOptions({
    super.key,
    required this.options,
    required this.currentAnswer,
    required this.onSelectAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(options.length, (i) {
        final option = options[i];
        final isSelected = currentAnswer == option;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onSelectAnswer(option),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSelected ? const Color(0xFF6C5CE7) : Colors.white,
                foregroundColor:
                    isSelected ? Colors.white : const Color(0xFF2D3436),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey[300]!,
                ),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                option.toString(),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
      }),
    );
  }
}