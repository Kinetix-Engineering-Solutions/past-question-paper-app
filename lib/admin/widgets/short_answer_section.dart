import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/viewmodels/question_create_viewmodel.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';

/// Short Answer Section - Correct Answer and Variations
class ShortAnswerSection extends ConsumerWidget {
  final TextEditingController correctAnswerController;
  final TextEditingController explanationController;
  final List<TextEditingController> variationControllers;
  final VoidCallback onAddVariation;
  final Function(int) onRemoveVariation;

  const ShortAnswerSection({
    super.key,
    required this.correctAnswerController,
    required this.explanationController,
    required this.variationControllers,
    required this.onAddVariation,
    required this.onRemoveVariation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questionCreateViewModelProvider);
    final notifier = ref.read(questionCreateViewModelProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: correctAnswerController,
          decoration: const InputDecoration(
            labelText: 'Correct Answer *',
            hintText: 'Enter the primary correct answer',
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Correct answer is required' : null,
          onChanged: (value) => notifier.updateCorrectAnswer(value),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: state.caseSensitive,
              onChanged: (value) {
                if (value != null) notifier.updateCaseSensitive(value);
              },
            ),
            const Text('Case Sensitive'),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        const Text(
          'Answer Variations (Optional):',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Add alternative correct answers (e.g., "H2O", "water")',
          style: TextStyle(fontSize: 12, color: AppColors.neutralMid),
        ),
        const SizedBox(height: 12),
        ...variationControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Variation ${index + 1}',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => onRemoveVariation(index),
                ),
              ],
            ),
          );
        }).toList(),
        TextButton.icon(
          onPressed: onAddVariation,
          icon: const Icon(Icons.add),
          label: const Text('Add Variation'),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        TextFormField(
          controller: explanationController,
          decoration: const InputDecoration(
            labelText: 'Explanation (Optional)',
            hintText: 'Explain the answer or provide context',
            alignLabelWithHint: true,
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
