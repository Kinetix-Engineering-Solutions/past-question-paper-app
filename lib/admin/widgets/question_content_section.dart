import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/viewmodels/question_create_viewmodel.dart';

/// Question Content Section - Format and Question Text
class QuestionContentSection extends ConsumerWidget {
  final TextEditingController questionTextController;

  const QuestionContentSection({
    super.key,
    required this.questionTextController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questionCreateViewModelProvider);
    final notifier = ref.read(questionCreateViewModelProvider.notifier);

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: state.format,
          decoration: const InputDecoration(labelText: 'Question Format *'),
          items: const [
            DropdownMenuItem(
              value: 'MCQ',
              child: Text('Multiple Choice (MCQ)'),
            ),
            DropdownMenuItem(
              value: 'short_answer',
              child: Text('Short Answer'),
            ),
            DropdownMenuItem(value: 'drag_drop', child: Text('Drag & Drop')),
            DropdownMenuItem(value: 'true_false', child: Text('True/False')),
            DropdownMenuItem(value: 'essay', child: Text('Essay')),
          ],
          onChanged: (value) {
            if (value != null) notifier.updateFormat(value);
          },
          validator: (value) => value == null ? 'Format is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: questionTextController,
          decoration: const InputDecoration(
            labelText: 'Question Text *',
            hintText: 'Enter the question text...',
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Question text is required' : null,
          onChanged: (value) => notifier.updateQuestionText(value),
        ),
      ],
    );
  }
}
