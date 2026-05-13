import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/viewmodels/question_create_viewmodel.dart';
import 'package:past_question_paper_v1/admin/widgets/image_upload_widget.dart';

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
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 12),
        Text(
          'OCR Assist (Mathpix)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Upload one question image to auto-populate this form. Review all fields before saving.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        ImageUploadWidget(
          initialImageUrl: state.ocrSourceImageUrl,
          onImageUploaded: notifier.setOcrSourceImageUrl,
          onImageRemoved: () => notifier.setOcrSourceImageUrl(null),
          folder: 'ocr_source_images',
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                state.isExtractingOcr ||
                    state.ocrSourceImageUrl == null ||
                    state.ocrSourceImageUrl!.isEmpty
                ? null
                : notifier.extractDraftFromOcrImage,
            icon: state.isExtractingOcr
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(
              state.isExtractingOcr
                  ? 'Extracting Draft...'
                  : 'Extract And Auto-Populate',
            ),
          ),
        ),
        if (state.ocrErrorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            state.ocrErrorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        if (state.ocrDraft != null) ...[
          const SizedBox(height: 8),
          Text(
            'Last draft confidence: ${(state.ocrDraft!.confidence * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (state.ocrDraft!.warnings.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                state.ocrDraft!.warnings.join('  |  '),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ],
    );
  }
}
