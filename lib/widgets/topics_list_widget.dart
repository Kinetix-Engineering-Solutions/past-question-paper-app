import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/topic.dart';
import 'package:past_question_paper_stem/model/subject.dart';
import 'package:past_question_paper_stem/utils/app_colors.dart';
import 'package:past_question_paper_stem/utils/app_theme.dart';
import 'package:past_question_paper_stem/widgets/topic_card.dart';

class TopicsListWidget extends ConsumerWidget {
  final List<Topic> topics;
  final Subject subject;
  final String? expandedTopicId;
  final Function(String?) onTopicExpanded;

  const TopicsListWidget({
    super.key,
    required this.topics,
    required this.subject,
    required this.expandedTopicId,
    required this.onTopicExpanded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (topics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.topic_outlined, size: 64, color: AppColors.accent),
              const SizedBox(height: 16),
              Text(
                'No Topics Available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Topics for ${subject.name} will appear here when they are added.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.neutralMid),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return TopicCard(
          topic: topic,
          isExpanded: expandedTopicId == topic.id,
          onTap: () {
            if (expandedTopicId == topic.id) {
              onTopicExpanded(null);
            } else {
              onTopicExpanded(topic.id);
            }
          },
        );
      },
    );
  }
}
