import 'package:past_question_paper_v1/features/progress/domain/question_progress.dart';

abstract interface class ProgressRepository {
  Future<QuestionProgress?> getQuestionProgress(String questionId);

  Future<QuestionProgress> setQuestionProgress({
    required String questionId,
    required QuestionProgressStatus status,
  });
}
