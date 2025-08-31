import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/viewmodels/practice_viewmodel.dart';

class MCQImageWidget extends ConsumerWidget {
  final Question question;
  final String? selectedOption;

  const MCQImageWidget({Key? key, required this.question, this.selectedOption})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionImages = question.optionImages ?? [];

    if (optionImages.isEmpty) {
      return const Center(
        child: Text(
          'No image options available',
          style: TextStyle(fontSize: 16, color: AppColors.neutralMid),
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
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.neutralBorder,
                width: isSelected ? 3 : 1.5,
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                      : null,
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.neutralCard,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: AppColors.neutralMid,
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Image failed to load',
                                style: TextStyle(
                                  color: AppColors.neutralMid,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
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


