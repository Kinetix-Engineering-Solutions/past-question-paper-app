import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/question_query.dart';
import '../providers/question_providers.dart';

Future<QuestionQuery?> showQuestionFilterDialog({
  required BuildContext context,
  required QuestionQuery currentQuery,
}) {
  return showModalBottomSheet<QuestionQuery>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _QuestionFilterSheet(currentQuery: currentQuery),
  );
}

class _QuestionFilterSheet extends ConsumerStatefulWidget {
  const _QuestionFilterSheet({required this.currentQuery});

  final QuestionQuery currentQuery;

  @override
  ConsumerState<_QuestionFilterSheet> createState() =>
      _QuestionFilterSheetState();
}

class _QuestionFilterSheetState extends ConsumerState<_QuestionFilterSheet> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedYear;
  String? _selectedSeason;
  late final TextEditingController _questionNumberController;

  @override
  void initState() {
    super.initState();

    _selectedYear = widget.currentQuery.examYear;
    _selectedSeason = widget.currentQuery.season;
    _questionNumberController = TextEditingController(
      text: widget.currentQuery.questionNumber ?? '',
    );
  }

  @override
  void dispose() {
    _questionNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final options = ref.watch(
      questionFilterOptionsProvider(widget.currentQuery.topicId),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filter questions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  if (widget.currentQuery.hasFilters)
                    TextButton(
                      onPressed: _clear,
                      child: const Text('Clear all'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Narrow the questions shown for this topic.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              options.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stackTrace) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      const Text('Unable to load filter options.'),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          ref.invalidate(
                            questionFilterOptionsProvider(
                              widget.currentQuery.topicId,
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
                data: (filterOptions) => Column(
                  children: [
                    DropdownButtonFormField<int?>(
                      initialValue: _selectedYear,
                      decoration: const InputDecoration(
                        labelText: 'Exam year',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Any year'),
                        ),
                        for (final year in filterOptions.examYears)
                          DropdownMenuItem<int?>(
                            value: year,
                            child: Text(year.toString()),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      initialValue: _selectedSeason,
                      decoration: const InputDecoration(
                        labelText: 'Exam season',
                        prefixIcon: Icon(Icons.event_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Any season'),
                        ),
                        for (final season in filterOptions.examSeasons)
                          DropdownMenuItem<String?>(
                            value: season,
                            child: Text(season),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSeason = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _questionNumberController,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _apply(),
                decoration: const InputDecoration(
                  labelText: 'Question number',
                  hintText: 'For example, 1.2',
                  helperText: 'Matches this question-number prefix.',
                  prefixIcon: Icon(Icons.tag_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _apply,
                      child: const Text('Apply filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clear() {
    Navigator.of(
      context,
    ).pop(QuestionQuery(topicId: widget.currentQuery.topicId));
  }

  void _apply() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final questionNumber = _questionNumberController.text.trim();

    Navigator.of(context).pop(
      QuestionQuery(
        topicId: widget.currentQuery.topicId,
        examYear: _selectedYear,
        season: _selectedSeason,
        questionNumber: questionNumber.isEmpty ? null : questionNumber,
      ),
    );
  }
}
