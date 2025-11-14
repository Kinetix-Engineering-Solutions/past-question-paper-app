import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/viewmodels/question_create_viewmodel.dart';
import 'package:past_question_paper_v1/admin/widgets/image_upload_widget.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';

/// MCQ Answer Section - Options A, B, C, D and Correct Answer
/// Supports both text and image-based options
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle between text and image options
        _buildOptionTypeToggle(context, state, notifier),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        // Render text or image options based on toggle
        if (state.useImageOptions)
          _buildImageOptions(context, state, notifier)
        else
          _buildTextOptions(context, state, notifier),

        const SizedBox(height: 16),

        // Correct answer selection
        _buildCorrectAnswerDropdown(context, state, notifier),

        const SizedBox(height: 16),

        // Explanation field
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

  Widget _buildOptionTypeToggle(
    BuildContext context,
    QuestionCreateState state,
    QuestionCreateViewModel notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      child: Row(
        children: [
          Icon(
            state.useImageOptions ? Icons.image : Icons.text_fields,
            color: AppColors.accent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Option Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.useImageOptions
                      ? 'Image-based options (diagrams, graphs, etc.)'
                      : 'Text-based options (A, B, C, D)',
                  style: TextStyle(fontSize: 12, color: AppColors.neutralMid),
                ),
              ],
            ),
          ),
          Switch(
            value: state.useImageOptions,
            onChanged: (value) => notifier.toggleUseImageOptions(),
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildTextOptions(
    BuildContext context,
    QuestionCreateState state,
    QuestionCreateViewModel notifier,
  ) {
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
      ],
    );
  }

  Widget _buildImageOptions(
    BuildContext context,
    QuestionCreateState state,
    QuestionCreateViewModel notifier,
  ) {
    final optionImages = state.mcqOptionImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload images for each option (A, B, C, D)',
          style: TextStyle(fontSize: 12, color: AppColors.neutralMid),
        ),
        const SizedBox(height: 12),

        // Option A Image
        _buildImageOptionRow(
          'A',
          optionImages.length > 0 ? optionImages[0] : null,
          (url) => notifier.updateMcqOptionImage(0, url),
          () => notifier.removeMcqOptionImage(0),
        ),
        const SizedBox(height: 12),

        // Option B Image
        _buildImageOptionRow(
          'B',
          optionImages.length > 1 ? optionImages[1] : null,
          (url) => notifier.updateMcqOptionImage(1, url),
          () => notifier.removeMcqOptionImage(1),
        ),
        const SizedBox(height: 12),

        // Option C Image
        _buildImageOptionRow(
          'C',
          optionImages.length > 2 ? optionImages[2] : null,
          (url) => notifier.updateMcqOptionImage(2, url),
          () => notifier.removeMcqOptionImage(2),
        ),
        const SizedBox(height: 12),

        // Option D Image
        _buildImageOptionRow(
          'D',
          optionImages.length > 3 ? optionImages[3] : null,
          (url) => notifier.updateMcqOptionImage(3, url),
          () => notifier.removeMcqOptionImage(3),
        ),
      ],
    );
  }

  Widget _buildImageOptionRow(
    String label,
    String? imageUrl,
    Function(String) onImageUploaded,
    Function() onImageRemoved,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ImageUploadWidget(
            initialImageUrl: imageUrl,
            onImageUploaded: onImageUploaded,
            onImageRemoved: onImageRemoved,
            folder: 'mcq_option_images',
          ),
        ),
      ],
    );
  }

  Widget _buildCorrectAnswerDropdown(
    BuildContext context,
    QuestionCreateState state,
    QuestionCreateViewModel notifier,
  ) {
    // For image options, validate that all images are uploaded
    if (state.useImageOptions) {
      final optionImages = state.mcqOptionImages;
      final allImagesUploaded =
          optionImages.length >= 4 &&
          optionImages.every((url) => url.isNotEmpty);

      if (!allImagesUploaded) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please upload all 4 option images before selecting the correct answer',
                  style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }
    }

    // Ensure the value exists in the dropdown items or reset to null
    final validAnswers = ['A', 'B', 'C', 'D'];
    final currentValue =
        state.correctAnswer.isEmpty ||
            !validAnswers.contains(state.correctAnswer)
        ? null
        : state.correctAnswer;

    return DropdownButtonFormField<String>(
      value: currentValue,
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
      validator: (value) => value == null ? 'Correct answer is required' : null,
    );
  }
}
