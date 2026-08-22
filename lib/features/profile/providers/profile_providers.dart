import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../data/profile_repository.dart';
import '../data/supabase_profile_repository.dart';
import '../domain/learner_profile.dart';
import 'profile_controller.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return SupabaseProfileRepository(ref.watch(supabaseClientProvider));
});

final profileControllerProvider = AsyncNotifierProvider.autoDispose
    .family<ProfileController, LearnerProfile, String>(ProfileController.new);
