import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/user.dart';
import 'package:past_question_paper_v1/repositories/user_repository.dart';
import 'package:past_question_paper_v1/providers/auth_providers.dart'; // Assuming your userRepo provider is here

// Riverpod provider for the ProfileViewModel
final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, AsyncValue<AppUser?>>((ref) {
      final userRepository = ref.watch(userRepositoryProvider);
      return ProfileViewModel(userRepository);
    });

class ProfileViewModel extends StateNotifier<AsyncValue<AppUser?>> {
  final UserRepository _userRepository;

  ProfileViewModel(this._userRepository) : super(const AsyncValue.loading()) {
    _loadUserData();
  }

  /// Fetches the current user's profile data from the repository.
  Future<void> _loadUserData() async {
    try {
      final user = await _userRepository.getUserFromFirestore(
        _userRepository.currentUser!.id,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Updates user preferences and refreshes the state.
  Future<void> updateUserPreferences({
    required int grade,
    required List<String> subjects,
  }) async {
    // Set state to loading while updating
    state = const AsyncValue.loading();
    try {
      await _userRepository.updateUserPreferences(
        grade: grade,
        subjects: subjects,
      );
      // Reload the user data to reflect the changes
      await _loadUserData();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final availableSubjectsProvider =
    FutureProvider.autoDispose.family<List<String>, int?>((ref, grade) async {
      final userRepository = ref.watch(userRepositoryProvider);
      return userRepository.getAvailableSubjects(grade: grade);
    });
