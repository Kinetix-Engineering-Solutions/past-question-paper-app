import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';

/// Traditional list view for topics (alternative to 3D carousel)
class TopicListView extends StatelessWidget {
  final List<String> topics;
  final Function(String topic, int index) onTopicSelected;
  final String? loadingTopicId;
  final Color? modeColor;

  const TopicListView({
    Key? key,
    required this.topics,
    required this.onTopicSelected,
    this.loadingTopicId,
    this.modeColor,
  }) : super(key: key);

  // Color palette for topics - PQP brand colors
  static const List<Color> _topicColors = [
    AppColors.brandCyan, // Cyan - question mark highlight
    AppColors.brandMagenta, // Magenta - playful accent
    AppColors.brandLavender, // Lavender - supportive accent
    AppColors.brandTeal, // Teal - geometric accent
    AppColors.accent, // Orange - primary action
    AppColors.brandCyan,
    AppColors.brandMagenta,
    AppColors.brandLavender,
    AppColors.brandTeal,
    AppColors.accent,
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Title and description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              Text(
                'Select a Topic',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to select a topic',
                style: textTheme.bodyMedium?.copyWith(
                  color: textTheme.bodyMedium?.color?.withOpacity(0.75),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Topic list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              final buttonId = 'topic_$index';
              final isLoading = loadingTopicId == buttonId;
              final color =
                  modeColor ?? _topicColors[index % _topicColors.length];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: isLoading
                        ? null
                        : () => onTopicSelected(topic, index),
                    child: Row(
                      children: [
                        // Colored vertical bar
                        Container(
                          width: 4,
                          height: 60,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Topic name
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              topic,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Loading or arrow
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: color,
                                  ),
                                )
                              : Icon(
                                  Icons.arrow_forward_ios,
                                  color: color,
                                  size: 18,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
