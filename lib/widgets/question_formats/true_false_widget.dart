import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'package:past_question_paper_v1/viewmodels/practice_viewmodel.dart';

class TrueFalseWidget extends ConsumerWidget {
  final Question question;
  final String? selectedOption;

  const TrueFalseWidget({Key? key, required this.question, this.selectedOption})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
                colorScheme.primary,
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
                colorScheme.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (selectedOption != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'You selected: $selectedOption',
                  style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ) ??
                      TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? colorScheme.primary
              : colorScheme.surface,
          foregroundColor:
              isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          elevation: isSelected ? 4 : 1,
          shadowColor:
              isSelected ? colorScheme.primary.withOpacity(0.3) : null,
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
              style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ) ??
                  TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
