import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/services/firestore_database_firebase.dart';
import 'package:past_question_paper_v1/viewmodels/auth_viewmodel.dart';

// Available Grades Provider - Gets from questions collection
final availableGradesProvider = FutureProvider<List<int>>((ref) async {
  final database = ref.read(firestoreDatabaseProvider);
  return await database.getAvailableGrades();
});

// Available Subjects Provider - Gets from questions collection
final availableSubjectsProvider = FutureProvider<List<String>>((ref) async {
  final database = ref.read(firestoreDatabaseProvider);
  return await database.getAvailableSubjects();
});

// Subjects for Selected Grade Provider
final subjectsForGradeProvider = FutureProvider.family<List<String>, int>((
  ref,
  grade,
) async {
  final database = ref.read(firestoreDatabaseProvider);
  return await database.getAvailableSubjects(grade: grade);
});

// Profile Setup State
class ProfileSetupState {
  final String? name;
  final int? selectedGrade;
  final List<String> selectedSubjects;
  final bool isLoading;
  final String? error;

  const ProfileSetupState({
    this.name,
    this.selectedGrade,
    this.selectedSubjects = const [],
    this.isLoading = false,
    this.error,
  });

  ProfileSetupState copyWith({
    String? name,
    int? selectedGrade,
    List<String>? selectedSubjects,
    bool? isLoading,
    String? error,
  }) {
    return ProfileSetupState(
      name: name ?? this.name,
      selectedGrade: selectedGrade ?? this.selectedGrade,
      selectedSubjects: selectedSubjects ?? this.selectedSubjects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Check if profile is valid for submission
  bool get isValid {
    return selectedGrade != null && selectedSubjects.isNotEmpty;
  }
}

// Profile Setup ViewModel
class ProfileSetupViewModel extends StateNotifier<ProfileSetupState> {
  final Ref _ref;

  ProfileSetupViewModel(this._ref) : super(const ProfileSetupState());

  // Update name
  void updateName(String name) {
    state = state.copyWith(name: name, error: null);
  }

  // Select grade
  void selectGrade(int grade) {
    // Clear selected subjects when changing grade since they might not be available
    state = state.copyWith(
      selectedGrade: grade,
      selectedSubjects: [],
      error: null,
    );
  }

  // Toggle subject selection
  void toggleSubjectSelection(String subject) {
    final currentSubjects = List<String>.from(state.selectedSubjects);

    if (currentSubjects.contains(subject)) {
      currentSubjects.remove(subject);
    } else {
      currentSubjects.add(subject);
    }

    state = state.copyWith(selectedSubjects: currentSubjects, error: null);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Save profile
  Future<bool> saveProfile(String userId) async {
    if (!state.isValid) {
      state = state.copyWith(
        error: 'Please select a grade and at least one subject',
      );
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      // Update user with new preferences
      final database = _ref.read(firestoreDatabaseProvider);
      await database.updateUserPreferences(
        userId,
        state.selectedGrade!,
        state.selectedSubjects,
      );

      // Refresh auth state to reflect the new profile
      await _ref.read(authViewModelProvider.notifier).refreshUser();

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save profile: ${e.toString()}',
      );
      return false;
    }
  }
}

// Profile Setup Provider
final profileSetupProvider =
    StateNotifierProvider<ProfileSetupViewModel, ProfileSetupState>((ref) {
      return ProfileSetupViewModel(ref);
    });

// Firestore Database Provider (if not already exists)
final firestoreDatabaseProvider = Provider<FirestoreDatabaseService>((ref) {
  return FirestoreDatabaseService();
});
