import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/viewmodels/practice_viewmodel.dart';

class TrueFalseWidget extends ConsumerWidget {
  final Question question;
  final String? selectedOption;

  const TrueFalseWidget({Key? key, required this.question, this.selectedOption})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOptionButton(
                context,
                ref,
                'True',
                selectedOption == 'True',
                Icons.check_circle_outline,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOptionButton(
                context,
                ref,
                'False',
                selectedOption == 'False',
                Icons.cancel_outlined,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (selectedOption != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'You selected: $selectedOption',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    WidgetRef ref,
    String option,
    bool isSelected,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? AppColors.accent : AppColors.neutralCard,
          foregroundColor: isSelected ? Colors.white : AppColors.ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppColors.accent : AppColors.neutralBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          elevation: isSelected ? 4 : 1,
          shadowColor: isSelected ? AppColors.accent.withOpacity(0.3) : null,
        ),
        onPressed: () {
          ref
              .read(practiceViewModelProvider.notifier)
              .answerQuestion(question.id, option);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : iconColor, size: 24),
            const SizedBox(width: 8),
            Text(
              option,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


