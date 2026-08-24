import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../questions/data/models/question.dart';
import '../../questions/providers/question_providers.dart';
import '../domain/question_progress.dart';
import 'progress_providers.dart';

final needsReviewQuestionsProvider = FutureProvider.autoDispose
    .family<List<Question>, String>((ref, userId) async {
      final questionIds = await ref
          .watch(progressRepositoryProvider)
          .getQuestionIdsByStatus(
            userId: userId,
            status: QuestionProgressStatus.needsReview,
          );

      if (questionIds.isEmpty) {
        return const [];
      }

      return ref
          .watch(questionRepositoryProvider)
          .getQuestionsByIds(questionIds: questionIds);
    });
