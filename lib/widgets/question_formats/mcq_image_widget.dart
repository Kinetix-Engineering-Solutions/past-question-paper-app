import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'package:past_question_paper_v1/viewmodels/practice_viewmodel.dart';

class MCQImageWidget extends ConsumerWidget {
  final Question question;
  final String? selectedOption;

  const MCQImageWidget({Key? key, required this.question, this.selectedOption})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionImages = question.optionImages ?? [];
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (optionImages.isEmpty) {
      return Center(
        child: Text(
          'No image options available',
          style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ) ??
              TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: optionImages.length > 4 ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: optionImages.length,
      itemBuilder: (context, index) {
        final imageUrl = optionImages[index];
        final isSelected = selectedOption == imageUrl;

        return GestureDetector(
          onTap: () {
            ref
                .read(practiceViewModelProvider.notifier)
                .answerQuestion(question.id, imageUrl);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1, // Keeps images in square tiles
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          color: colorScheme.surface,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit
                                .contain, // shows the whole image without cropping
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: colorScheme.primary,
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Image failed to load',
                                      style: textTheme.bodySmall?.copyWith(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                      ) ??
                                          TextStyle(
                                            fontSize: 12,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
