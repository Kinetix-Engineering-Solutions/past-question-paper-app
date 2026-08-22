import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../questions/data/models/question.dart';
import '../../questions/providers/question_providers.dart';
import 'bookmark_providers.dart';

final savedQuestionsProvider = FutureProvider.autoDispose
    .family<List<Question>, String>((ref, userId) async {
      final questionIds = await ref
          .watch(bookmarkRepositoryProvider)
          .getBookmarkedQuestionIds(userId: userId);

      if (questionIds.isEmpty) {
        return const [];
      }

      return ref
          .watch(questionRepositoryProvider)
          .getQuestionsByIds(questionIds: questionIds);
    });
