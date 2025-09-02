import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/viewmodels/practice_viewmodel.dart';
import 'package:past_question_paper_v1/widgets/latex_text.dart';

class MCQTextWidget extends ConsumerWidget {
  final Question question;
  final String? selectedOption;

  const MCQTextWidget({Key? key, required this.question, this.selectedOption})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: question.options.map((option) {
        final isSelected = selectedOption == option;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Card(
            color: isSelected ? AppColors.accentSoft : AppColors.neutralCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? AppColors.accent : AppColors.neutralBorder,
                width: 1.5,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              title: LatexText(option),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: AppColors.accent, size: 24)
                  : null,
              onTap: () {
                ref
                    .read(practiceViewModelProvider.notifier)
                    .answerQuestion(question.id, option);
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}
