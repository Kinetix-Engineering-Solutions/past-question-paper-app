import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/features/progress/domain/topic_progress.dart';
import '../../discovery/providers/discovery_providers.dart';
import 'progress_providers.dart';

final topicProgressProvider = FutureProvider.autoDispose
    .family<List<TopicProgress>, String>((ref, userId) async {
      final discovery = await ref.watch(discoveryControllerProvider.future);

      final summaries = await ref
          .watch(progressRepositoryProvider)
          .getTopicProgressSummary(userId: userId);

      final topicsById = {
        for (final topic in discovery.topics) topic.id: topic,
      };

      return summaries
          .map((summary) {
            final topic = topicsById[summary.topicId];

            if (topic == null) {
              return null;
            }

            return TopicProgress(topic: topic, summary: summary);
          })
          .whereType<TopicProgress>()
          .toList(growable: false);
    });
