import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:past_question_paper_v1/core/models/quiz_type.dart';

import 'package:past_question_paper_v1/features/quiz/quiz_flow_screen.dart';
import 'package:past_question_paper_v1/features/quiz/quiz_type_selector.dart';
import '../../core/models/subject.dart';

class QuizModeDialog extends StatelessWidget {
  final Subject subject;
  final Function(String) onModeSelected;

  const QuizModeDialog({
    super.key,
    required this.subject,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start ${subject.name} Quiz',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select the perfect study experience for you!',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF636E72),
              ),
            ),
            const SizedBox(height: 24),

            // ✅ Rapid Session opens a nested selector
            _buildQuizModeOption(
              context,
              title: 'Rapid Session',
              description:
                  'Quick fire questions for active recall practice. Perfect for daily reviews and reinforcing knowledge on the go.',
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: SizedBox(
                      height: 400,
                      child:QuizTypeSelector(
  subjectId: subject.id,
  onSelect: (quizType, subjectId) {
  Navigator.of(context).pop(); // First close the dialog

  final selectedGrade = 'Grade 10'; // You should determine this from actual selection

  Future.microtask(() {
    context.goNamed(
      'QuizFlowScreen', // make sure this matches your route name
      queryParameters: {
        'subjectId': subjectId,
        'type': quizType.name,
        'grade': selectedGrade,
      },
    );
  });
},
)

                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Exam Session uses fixed route
            _buildQuizModeOption(
              context,
              title: 'Exam Session',
              description:
                  'Comprehensive testing environment to simulate real exam conditions and track your progress.',
              onTap: () {
                Navigator.pop(context);
                onModeSelected('/exam?subjectId=${subject.id}');
              },
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6C5CE7),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizModeOption(
    BuildContext context, {
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF636E72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
