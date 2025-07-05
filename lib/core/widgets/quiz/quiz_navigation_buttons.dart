import 'package:flutter/material.dart';

class QuizNavigationButtons extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onSubmit;
  final bool showNext;

  const QuizNavigationButtons({
    super.key,
    this.onPrevious,
    this.onNext,
    required this.onSubmit,
    this.showNext = true, // New property to control visibility of Next button
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: onPrevious,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF6C5CE7),
            side: const BorderSide(color: Color(0xFF6C5CE7)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Previous'),
        ),
        if (showNext) // Conditionally render the Next button
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Next'),
          ),
        ElevatedButton(
          onPressed: onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}