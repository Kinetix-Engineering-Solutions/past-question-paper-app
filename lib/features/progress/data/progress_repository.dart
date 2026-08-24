import 'package:past_question_paper_v1/features/progress/domain/question_progress.dart';

import '../domain/topic_progress_summary.dart';

abstract interface class ProgressRepository {
  Future<QuestionProgress?> getQuestionProgress(String questionId);

  Future<QuestionProgress> setQuestionProgress({
    required String questionId,
    required QuestionProgressStatus status,
  });

  Future<List<String>> getQuestionIdsByStatus({
    required String userId,
    required QuestionProgressStatus status,
  });

  Future<List<TopicProgressSummary>> getTopicProgressSummary({
    required String userId,
  });
}
