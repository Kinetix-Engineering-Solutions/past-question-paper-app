import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/topic.dart';
import 'package:past_question_paper_stem/model/practice_mode.dart';
import 'package:past_question_paper_stem/utils/app_colors.dart';
import 'package:past_question_paper_stem/views/practice_instructions_screen.dart';

class PracticeModesWidget extends ConsumerWidget {
  final Topic topic;

  const PracticeModesWidget({super.key, required this.topic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Practice Modes Section
          Text(
            'Practice Modes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPracticeModeItem(
                  context,
                  ref,
                  topic,
                  PracticeMode.standard,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPracticeModeItem(
                  context,
                  ref,
                  topic,
                  PracticeMode.extended,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeModeItem(
    BuildContext context,
    WidgetRef ref,
    Topic topic,
    PracticeMode mode,
  ) {
    // Use solid colors per mode (no gradients)
    final Color modeColor = switch (mode) {
      PracticeMode.standard => AppColors.ink,
      PracticeMode.extended => AppColors.neutralMid,
      _ => AppColors.ink,
    };

    return Container(
      decoration: BoxDecoration(
        color: modeColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _startPractice(context, ref, topic, mode),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon and duration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.neutralCard.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.neutralCard.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      mode.icon,
                      color: AppColors.neutralCard,
                      size: 18,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutralCard.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.neutralCard.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      mode.durationText,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutralCard,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Mode name
              Text(
                mode.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutralCard,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                mode.description,
                style: TextStyle(
                  color: AppColors.neutralCard.withOpacity(0.8),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Play button
              Icon(
                Icons.play_circle_outline,
                color: AppColors.neutralCard,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startPractice(
    BuildContext context,
    WidgetRef ref,
    Topic topic,
    PracticeMode mode,
  ) async {
    // Navigate to instructions screen where questions will be loaded
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => PracticeInstructionsScreen(topic: topic, mode: mode),
        ),
      );
    }
  }
}
