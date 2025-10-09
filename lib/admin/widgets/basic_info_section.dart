import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/viewmodels/question_create_viewmodel.dart';
import 'package:past_question_paper_v1/utils/app_constants.dart';

/// Basic Information Section - Subject, Grade, Topic, Paper, Year, Season
class BasicInfoSection extends ConsumerWidget {
  const BasicInfoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questionCreateViewModelProvider);
    final notifier = ref.read(questionCreateViewModelProvider.notifier);

    // When a parent is selected, these fields are read-only (auto-filled from parent)
    final isReadOnly = state.isChildQuestion && state.parentQuestionId != null;

    return Column(
      children: [
        // Show info banner if fields are auto-filled from parent
        if (isReadOnly)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
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
                    'These fields are automatically filled from the parent question',
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: state.subject,
                decoration: InputDecoration(
                  labelText: 'Subject *',
                  enabled: !isReadOnly,
                ),
                items: AppConstants.subjects
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: isReadOnly
                    ? null
                    : (value) {
                        if (value != null) notifier.updateSubject(value);
                      },
                validator: (value) =>
                    value == null ? 'Subject is required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: state.grade,
                decoration: InputDecoration(
                  labelText: 'Grade *',
                  enabled: !isReadOnly,
                ),
                items: AppConstants.grades
                    .map((g) => DropdownMenuItem(value: g, child: Text('$g')))
                    .toList(),
                onChanged: isReadOnly
                    ? null
                    : (value) {
                        if (value != null) notifier.updateGrade(value);
                      },
                validator: (value) =>
                    value == null ? 'Grade is required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: state.topic.isEmpty ? null : state.topic,
          decoration: InputDecoration(
            labelText: 'Topic *',
            enabled: !isReadOnly,
          ),
          items: (AppConstants.topicsBySubject[state.subject] ?? [])
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: isReadOnly
              ? null
              : (value) {
                  if (value != null) notifier.updateTopic(value);
                },
          validator: (value) => value == null ? 'Topic is required' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: state.paper,
                decoration: InputDecoration(
                  labelText: 'Paper',
                  enabled: !isReadOnly,
                ),
                items: const [
                  DropdownMenuItem(value: 'p1', child: Text('Paper 1')),
                  DropdownMenuItem(value: 'p2', child: Text('Paper 2')),
                  DropdownMenuItem(value: 'p3', child: Text('Paper 3')),
                ],
                onChanged: isReadOnly
                    ? null
                    : (value) {
                        if (value != null) notifier.updatePaper(value);
                      },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                initialValue: state.year.toString(),
                decoration: InputDecoration(
                  labelText: 'Year',
                  enabled: !isReadOnly,
                ),
                keyboardType: TextInputType.number,
                enabled: !isReadOnly,
                onChanged: (value) {
                  final year = int.tryParse(value);
                  if (year != null) notifier.updateYear(year);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: state.season,
                decoration: InputDecoration(
                  labelText: 'Season',
                  enabled: !isReadOnly,
                ),
                items: const [
                  DropdownMenuItem(value: 'November', child: Text('November')),
                  DropdownMenuItem(value: 'June', child: Text('June')),
                  DropdownMenuItem(value: 'March', child: Text('March')),
                ],
                onChanged: isReadOnly
                    ? null
                    : (value) {
                        if (value != null) notifier.updateSeason(value);
                      },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
