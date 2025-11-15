import 'package:flutter/material.dart';

/// A reusable banner widget for displaying success or error messages
class MessageBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const MessageBanner({
    super.key,
    required this.message,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isError ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red.shade800 : Colors.green.shade800,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? Colors.red.shade800 : Colors.green.shade800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
