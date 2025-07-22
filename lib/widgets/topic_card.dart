import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/topic.dart';
import 'package:past_question_paper_stem/utils/app_theme.dart';
import 'package:past_question_paper_stem/viewmodels/practice_viewmodel.dart';
import 'package:past_question_paper_stem/widgets/practice_modes_widget.dart';

class TopicCard extends ConsumerWidget {
  final Topic topic;
  final bool isExpanded;
  final VoidCallback onTap;

  const TopicCard({
    super.key,
    required this.topic,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: ChalkboardGradients.classic,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.chalkWhite.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(Icons.topic, color: AppColors.chalkWhite, size: 24),
            ),
            title: Text(
              topic.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.inkBlack,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  topic.description,
                  style: TextStyle(
                    color: AppColors.graphite.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.chalkboardLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.chalkboardLight.withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        topic.season,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.chalkboard,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (!isExpanded)
                      Text(
                        'Tap to practice',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.inkBlack.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            trailing: AnimatedRotation(
              turns: isExpanded ? 0.25 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.graphite,
              ),
            ),
            onTap: () {
              onTap();
              if (!isExpanded) {
                // Load questions for this topic when expanding
                ref
                    .read(practiceViewModelProvider.notifier)
                    .loadQuestionsForTopic(topic);
              }
            },
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: PracticeModesWidget(topic: topic),
            crossFadeState:
                isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
