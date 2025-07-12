import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/grade.dart';
import 'package:past_question_paper_stem/model/subject.dart';
import 'package:past_question_paper_stem/model/user.dart';
import 'package:past_question_paper_stem/services/firestore_database_firebase.dart';
import 'package:past_question_paper_stem/viewmodels/auth_viewmodel.dart';

// Available Grades Provider - Fetches from Firestore
final availableGradesProvider = FutureProvider<List<Grade>>((ref) async {
  final database = ref.read(firestoreDatabaseProvider);
  return await database.getGrades();
});

// Available Subjects Provider - Fetches from Firestore
final availableSubjectsProvider = FutureProvider<List<Subject>>((ref) async {
  final database = ref.read(firestoreDatabaseProvider);
  return await database.getSubjects();
});

// Subjects for Selected Grade Provider - Fetches from Firestore
final subjectsForGradeProvider = FutureProvider.family<List<Subject>, String>((
  ref,
  gradeId,
) async {
  final database = ref.read(firestoreDatabaseProvider);
  return await database.getSubjectsForGrade(gradeId);
});

// Profile Setup State
class ProfileSetupState {
  final String? firstName;
  final String? lastName;
  final String? schoolName;
  final Grade? selectedGrade;
  final List<Subject> selectedSubjects;
  final bool isLoading;
  final String? error;

  const ProfileSetupState({
    this.firstName,
    this.lastName,
    this.schoolName,
    this.selectedGrade,
    this.selectedSubjects = const [],
    this.isLoading = false,
    this.error,
  });

  ProfileSetupState copyWith({
    String? firstName,
    String? lastName,
    String? schoolName,
    Grade? selectedGrade,
    List<Subject>? selectedSubjects,
    bool? isLoading,
    String? error,
  }) {
    return ProfileSetupState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      schoolName: schoolName ?? this.schoolName,
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

  // Update first name
  void updateFirstName(String firstName) {
    state = state.copyWith(firstName: firstName, error: null);
  }

  // Update last name
  void updateLastName(String lastName) {
    state = state.copyWith(lastName: lastName, error: null);
  }

  // Update school name
  void updateSchoolName(String schoolName) {
    state = state.copyWith(schoolName: schoolName, error: null);
  }

  // Select grade
  void selectGrade(Grade grade) {
    // Clear selected subjects if they're not available for the new grade
    final availableSubjectIds =
        grade.id == state.selectedGrade?.id
            ? state.selectedSubjects
            : state.selectedSubjects
                .where((subject) => subject.gradeIds.contains(grade.id))
                .toList();

    state = state.copyWith(
      selectedGrade: grade,
      selectedSubjects: availableSubjectIds,
      error: null,
    );
  }

  // Toggle subject selection
  void toggleSubjectSelection(Subject subject) {
    final currentSubjects = List<Subject>.from(state.selectedSubjects);

    if (currentSubjects.any((s) => s.id == subject.id)) {
      currentSubjects.removeWhere((s) => s.id == subject.id);
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

      final profile = UserProfile(
        firstName: state.firstName?.trim(),
        lastName: state.lastName?.trim(),
        schoolName: state.schoolName?.trim(),
        gradeId: state.selectedGrade!.id,
        subjectIds: state.selectedSubjects.map((s) => s.id).toList(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      final database = _ref.read(firestoreDatabaseProvider);
      await database.saveUserProfile(userId, profile);

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
