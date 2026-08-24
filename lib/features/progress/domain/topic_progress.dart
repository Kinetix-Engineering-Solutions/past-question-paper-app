import '../../discovery/data/models/topic.dart';
import 'topic_progress_summary.dart';

final class TopicProgress {
  const TopicProgress({required this.topic, required this.summary});

  final Topic topic;
  final TopicProgressSummary summary;

  int get totalQuestionCount => topic.questionCount;

  double get reviewCoverage {
    if (totalQuestionCount == 0) {
      return 0;
    }

    return (summary.reviewedCount / totalQuestionCount)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  double get understoodCoverage {
    if (totalQuestionCount == 0) {
      return 0;
    }

    return (summary.understoodCount / totalQuestionCount)
        .clamp(0.0, 1.0)
        .toDouble();
  }
}
