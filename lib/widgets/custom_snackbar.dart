import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/utils/haptic_feedback.dart';

class CustomSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    bool isError = false,
    int durationSeconds = 3,
  }) {
    // Add haptic feedback
    if (isError) {
      AppHaptics.error();
    } else {
      AppHaptics.success();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
        duration: Duration(seconds: durationSeconds),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(8),
        dismissDirection: DismissDirection.horizontal,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
