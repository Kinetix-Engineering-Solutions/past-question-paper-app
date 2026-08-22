import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/features/progress/data/progress_repository.dart';
import 'package:past_question_paper_v1/features/progress/data/supabase_progress_repository.dart';
import 'package:past_question_paper_v1/features/progress/domain/question_progress.dart';
import 'package:past_question_paper_v1/features/progress/providers/question_progress_controller.dart';
import '../../../core/supabase/supabase_providers.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);

  return SupabaseProgressRepository(supabase);
});

final questionProgressControllerProvider = AsyncNotifierProvider.autoDispose
    .family<QuestionProgressController, QuestionProgress?, String>(
      QuestionProgressController.new,
    );
