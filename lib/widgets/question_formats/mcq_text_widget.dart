import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'package:past_question_paper_v1/viewmodels/practice_viewmodel.dart';
import 'package:past_question_paper_v1/widgets/latex_text.dart';

class MCQTextWidget extends ConsumerWidget {
  final Question question;
  final String? selectedOption;

  const MCQTextWidget({super.key, required this.question, this.selectedOption});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        // [ADDED] Show question text 09-sept
        // if (question.questionText.isNotEmpty)
        //   Padding(
        //     padding: const EdgeInsets.only(bottom: 12.0),
        //     child: LatexText(question.questionText),
        //   ),

        // [ADDED] Show question image if available 09-sept
        // if (question.hasQuestionImage)
        //   Padding(
        //     padding: const EdgeInsets.only(bottom: 12.0),
        //     child: Image.network(question.imageUrl!),
        //   ),


        ...question.options.map((option) {
          final isSelected = selectedOption == option;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Card(
              color: isSelected
                  ? colorScheme.primary.withOpacity(0.08)
                  : colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide.none,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                title: LatexText(option),
                trailing: isSelected
          ? Icon(Icons.check_circle, color: colorScheme.primary, size: 24)
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
      ],
    );
  }
}
