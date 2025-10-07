import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/viewmodels/question_create_viewmodel.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';

/// Drag and Drop Section - Items to arrange and correct order
class DragDropSection extends ConsumerWidget {
  final List<TextEditingController> dragItemControllers;
  final TextEditingController correctOrderController;
  final TextEditingController explanationController;
  final VoidCallback onAddDragItem;
  final Function(int) onRemoveDragItem;

  const DragDropSection({
    super.key,
    required this.dragItemControllers,
    required this.correctOrderController,
    required this.explanationController,
    required this.onAddDragItem,
    required this.onRemoveDragItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(questionCreateViewModelProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Students will arrange these items in the correct order',
                  style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Drag items list
        const Text('Drag Items (Steps to arrange):'),
        const SizedBox(height: 8),
        ...dragItemControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.neutralMid),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Step ${index + 1}',
                      hintText: 'Enter step description',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => onRemoveDragItem(index),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onAddDragItem,
          icon: const Icon(Icons.add),
          label: const Text('Add Step'),
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // Correct order
        const Text('Correct Order:'),
        const SizedBox(height: 8),
        Text(
          'Arrange the steps above in the correct order by entering step numbers (e.g., 1,2,3,4)',
          style: TextStyle(fontSize: 12, color: AppColors.neutralMid),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: correctOrderController,
          decoration: const InputDecoration(
            labelText: 'Correct Order *',
            hintText: '1,2,3,4',
            helperText: 'Enter step numbers separated by commas',
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Correct order is required' : null,
          onChanged: (value) => notifier.updateCorrectOrder(value),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        TextFormField(
          controller: explanationController,
          decoration: const InputDecoration(
            labelText: 'Explanation (Optional)',
            hintText: 'Explain the correct sequence or provide context',
            alignLabelWithHint: true,
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
