import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/viewmodels/question_create_viewmodel.dart';

/// Metadata Section - Marks, Cognitive Level, Difficulty
class MetadataSection extends ConsumerWidget {
  final TextEditingController marksController;

  const MetadataSection({super.key, required this.marksController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questionCreateViewModelProvider);
    final notifier = ref.read(questionCreateViewModelProvider.notifier);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: marksController,
                decoration: const InputDecoration(labelText: 'Marks *'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Marks is required';
                  if (int.tryParse(value!) == null) return 'Must be a number';
                  return null;
                },
                onChanged: (value) {
                  final marks = int.tryParse(value);
                  if (marks != null) notifier.updateMarks(marks);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: state.cognitiveLevel,
                decoration: const InputDecoration(labelText: 'Cognitive Level'),
                items: const [
                  DropdownMenuItem(
                    value: 'Level 1',
                    child: Text('Level 1 - Knowledge'),
                  ),
                  DropdownMenuItem(
                    value: 'Level 2',
                    child: Text('Level 2 - Comprehension'),
                  ),
                  DropdownMenuItem(
                    value: 'Level 3',
                    child: Text('Level 3 - Application'),
                  ),
                  DropdownMenuItem(
                    value: 'Level 4',
                    child: Text('Level 4 - Analysis'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) notifier.updateCognitiveLevel(value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: state.difficulty,
          decoration: const InputDecoration(labelText: 'Difficulty'),
          items: const [
            DropdownMenuItem(value: 'easy', child: Text('Easy')),
            DropdownMenuItem(value: 'medium', child: Text('Medium')),
            DropdownMenuItem(value: 'hard', child: Text('Hard')),
          ],
          onChanged: (value) {
            if (value != null) notifier.updateDifficulty(value);
          },
        ),
      ],
    );
  }
}
