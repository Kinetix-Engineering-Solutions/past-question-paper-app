import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/features/comments/providers/question_comments_controller.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../data/question_comments_repository.dart';
import '../data/supabase_question_comments_repository.dart';
import 'question_comments_state.dart';

final questionCommentsRepositoryProvider = Provider<QuestionCommentsRepository>(
  (ref) {
    return SupabaseQuestionCommentsRepository(
      ref.watch(supabaseClientProvider),
    );
  },
);

final questionCommentsControllerProvider = AsyncNotifierProvider.autoDispose
    .family<QuestionCommentsController, QuestionCommentsState, String>(
      QuestionCommentsController.new,
    );
