import 'package:flutter/material.dart';

class SubmitQuizDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const SubmitQuizDialog({
    super.key,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Submit Quiz?'),
      content: const Text('Are you sure you want to submit your quiz? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}