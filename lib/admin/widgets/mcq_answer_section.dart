import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/viewmodels/question_create_viewmodel.dart';

/// MCQ Answer Section - Options A, B, C, D and Correct Answer
class MCQAnswerSection extends ConsumerWidget {
  final TextEditingController optionAController;
  final TextEditingController optionBController;
  final TextEditingController optionCController;
  final TextEditingController optionDController;
  final TextEditingController explanationController;

  const MCQAnswerSection({
    super.key,
    required this.optionAController,
    required this.optionBController,
    required this.optionCController,
    required this.optionDController,
    required this.explanationController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questionCreateViewModelProvider);
    final notifier = ref.read(questionCreateViewModelProvider.notifier);

    return Column(
      children: [
        TextFormField(
          controller: optionAController,
          decoration: const InputDecoration(labelText: 'Option A *'),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Option A is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: optionBController,
          decoration: const InputDecoration(labelText: 'Option B *'),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Option B is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: optionCController,
          decoration: const InputDecoration(labelText: 'Option C *'),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Option C is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: optionDController,
          decoration: const InputDecoration(labelText: 'Option D *'),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Option D is required' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: state.correctAnswer.isEmpty ? null : state.correctAnswer,
          decoration: const InputDecoration(labelText: 'Correct Answer *'),
          items: const [
            DropdownMenuItem(value: 'A', child: Text('A')),
            DropdownMenuItem(value: 'B', child: Text('B')),
            DropdownMenuItem(value: 'C', child: Text('C')),
            DropdownMenuItem(value: 'D', child: Text('D')),
          ],
          onChanged: (value) {
            if (value != null) notifier.updateCorrectAnswer(value);
          },
          validator: (value) =>
              value == null ? 'Correct answer is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: explanationController,
          decoration: const InputDecoration(
            labelText: 'Explanation (Optional)',
            hintText: 'Explain why this is the correct answer...',
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
