import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/widgets/latex_text.dart';

/// Widget that displays parent question context for child questions
/// Shows parent question text and image when viewing a child question
class ParentQuestionContextCard extends StatelessWidget {
  final Question question;

  const ParentQuestionContextCard({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    // Only show if question has parent context
    if (!question.hasParent || question.parentContext == null) {
      return const SizedBox.shrink();
    }

    // Safely extract parent data
    final parentText = question.parentQuestionText ?? '';
    final parentImageUrl = question.parentContext!['imageUrl'] as String?;
    final parentNumber = question.parentQuestionNumber;

    // Don't show card if there's no content to display
    if (parentText.isEmpty &&
        (parentImageUrl == null || parentImageUrl.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutralCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Icon(Icons.link, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                parentNumber != null
                    ? 'Question $parentNumber'
                    : 'Parent Question',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Parent question text
          if (parentText.isNotEmpty) ...[
            LatexText(
              parentText,
              textStyle: TextStyle(
                fontSize: 16,
                color: AppColors.ink,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Parent question image
          if (parentImageUrl != null && parentImageUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                parentImageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: AppColors.paper,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: AppColors.paper,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            size: 48,
                            color: AppColors.ink.withOpacity(0.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image not available',
                            style: TextStyle(
                              color: AppColors.ink.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Info text
          const SizedBox(height: 12),
          Text(
            'This question relates to the context above',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppColors.ink.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
