import 'package:flutter/material.dart';
import '../domain/question_query.dart';

Future<QuestionQuery?> showQuestionFilterDialog({
  required BuildContext context,
  required QuestionQuery currentQuery,
}) {
  return showDialog<QuestionQuery>(
    context: context,
    builder: (_) => _QuestionFilterDialog(currentQuery: currentQuery),
  );
}

class _QuestionFilterDialog extends StatefulWidget {
  const _QuestionFilterDialog({required this.currentQuery});

  final QuestionQuery currentQuery;

  @override
  State<_QuestionFilterDialog> createState() => _QuestionFilterDialogState();
}

class _QuestionFilterDialogState extends State<_QuestionFilterDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _yearController;
  late final TextEditingController _seasonController;
  late final TextEditingController _questionNumberController;

  @override
  void initState() {
    super.initState();

    _yearController = TextEditingController(
      text: widget.currentQuery.examYear?.toString() ?? '',
    );
    _seasonController = TextEditingController(
      text: widget.currentQuery.season ?? '',
    );
    _questionNumberController = TextEditingController(
      text: widget.currentQuery.questionNumber ?? '',
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _seasonController.dispose();
    _questionNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter questions'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Exam year',
                  hintText: 'For example, 2022',
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';

                  if (text.isEmpty) {
                    return null;
                  }

                  final year = int.tryParse(text);

                  if (year == null || year < 1996 || year > 2100) {
                    return 'Enter a year from 1996 to 2100.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _seasonController,
                decoration: const InputDecoration(
                  labelText: 'Exam season',
                  hintText: 'For example, May-June',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _questionNumberController,
                decoration: const InputDecoration(
                  labelText: 'Question number',
                  hintText: 'For example, 1.2',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(
              context,
            ).pop(QuestionQuery(topicId: widget.currentQuery.topicId));
          },
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _apply, child: const Text('Apply')),
      ],
    );
  }

  void _apply() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final yearText = _yearController.text.trim();
    final season = _seasonController.text.trim();
    final questionNumber = _questionNumberController.text.trim();

    Navigator.of(context).pop(
      QuestionQuery(
        topicId: widget.currentQuery.topicId,
        examYear: yearText.isEmpty ? null : int.parse(yearText),
        season: season.isEmpty ? null : season,
        questionNumber: questionNumber.isEmpty ? null : questionNumber,
      ),
    );
  }
}
