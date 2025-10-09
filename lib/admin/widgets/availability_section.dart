import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/viewmodels/question_create_viewmodel.dart';

/// Availability Section - PQP, Sprint, By Topic toggles and PQP Number
class AvailabilitySection extends ConsumerWidget {
  final TextEditingController pqpNumberController;

  const AvailabilitySection({super.key, required this.pqpNumberController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questionCreateViewModelProvider);
    final notifier = ref.read(questionCreateViewModelProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available In:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('PQP (Past Question Paper) Mode'),
          value: state.availableInPQP,
          onChanged: (value) => notifier.togglePQPMode(),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        if (state.availableInPQP) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: TextFormField(
              controller: pqpNumberController,
              decoration: const InputDecoration(
                labelText: 'PQP Question Number',
                hintText: 'e.g., 4.2.1',
                helperText: 'Optional - will auto-generate if empty',
              ),
              onChanged: notifier.updatePqpNumber,
            ),
          ),
        ],
        CheckboxListTile(
          title: const Text('Sprint (Quick Practice) Mode'),
          value: state.availableInSprint,
          onChanged: (value) => notifier.toggleSprintMode(),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('By Topic Mode'),
          value: state.availableInByTopic,
          onChanged: (value) => notifier.toggleByTopicMode(),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
