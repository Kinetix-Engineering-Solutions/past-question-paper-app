import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/user.dart';
import 'package:past_question_paper_stem/model/grade.dart';
import 'package:past_question_paper_stem/model/subject.dart';
// import 'package:past_question_paper_stem/providers/auth_providers.dart';
import 'package:past_question_paper_stem/providers/navigation_providers.dart';
import 'package:past_question_paper_stem/services/firestore_database_firebase.dart';
import 'package:past_question_paper_stem/viewmodels/auth_viewmodel.dart';
import 'package:past_question_paper_stem/services/navigation_service.dart';

// Home View Model Provider
final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((
  ref,
) {
  return HomeViewModel(ref);
});

// Home State
class HomeState {
  final bool isLoading;
  final String? error;
  final AppUser? currentUser;
  final List<Grade> availableGrades;
  final List<Subject> userSubjects;
  final bool isSigningOut;

  const HomeState({
    this.isLoading = false,
    this.error,
    this.currentUser,
    this.availableGrades = const [],
    this.userSubjects = const [],
    this.isSigningOut = false,
  });

  HomeState copyWith({
    bool? isLoading,
    String? error,
    AppUser? currentUser,
    List<Grade>? availableGrades,
    List<Subject>? userSubjects,
    bool? isSigningOut,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentUser: currentUser ?? this.currentUser,
      availableGrades: availableGrades ?? this.availableGrades,
      userSubjects: userSubjects ?? this.userSubjects,
      isSigningOut: isSigningOut ?? this.isSigningOut,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  final Ref _ref;
  final FirestoreDatabaseService _database = FirestoreDatabaseService();

  HomeViewModel(this._ref) : super(const HomeState()) {
    _initializeHome();

    // Listen to auth state changes
    _ref.listen(authViewModelProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user == null) {
            // User logged out - reset state
            state = const HomeState();
          } else {
            // User logged in or profile updated - update user and load data
            state = state.copyWith(currentUser: user, isLoading: true);
            _loadUserData();
          }
        },
        loading: () {
          // Auth state is loading
          state = state.copyWith(isLoading: true, error: null);
        },
        error: (error, stackTrace) {
          // Auth error
          state = state.copyWith(
            isLoading: false,
            error: 'Authentication error: $error',
          );
        },
      );
    });

    // Safety net: after initial build/navigation, ensure we load with the latest
    // auth state in case of a timing race right after onboarding.
    Future.microtask(() {
      final auth = _ref.read(authViewModelProvider);
      auth.whenOrNull(data: (user) {
        if (user != null) {
          state = state.copyWith(currentUser: user, isLoading: true);
          _loadUserData();
        }
      });
    });
  }

  /// Initialize home screen data
  Future<void> _initializeHome() async {
    try {
  // Read AuthViewModel state (reflects refreshes after onboarding)
  final authState = _ref.read(authViewModelProvider);
      authState.whenOrNull(
        data: (currentUser) async {
          if (currentUser != null) {
            state = state.copyWith(currentUser: currentUser, isLoading: true);
            await _loadUserData();
          } else {
            // No user, keep default state (not loading)
            state = const HomeState();
          }
        },
        loading: () {
          state = state.copyWith(isLoading: true);
        },
        error: (error, stackTrace) {
          state = state.copyWith(
            error: 'Failed to load home data: ${error.toString()}',
            isLoading: false,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load home data: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Load user-specific data
  Future<void> _loadUserData() async {
    try {
      // Load available grades
      final grades = await _database.getGrades();

      // Load user's subjects if they have selected any
      List<Subject> userSubjects = [];
      if (state.currentUser?.profile?.subjectIds.isNotEmpty == true) {
        // Get all subjects from Firestore
        final allSubjects = await _database.getSubjects();

        // Filter subjects for the current user
        final userSubjectIds = state.currentUser!.profile!.subjectIds;
        userSubjects =
            allSubjects
                .where((subject) => userSubjectIds.contains(subject.id))
                .toList();
      }

      state = state.copyWith(
        availableGrades: grades,
        userSubjects: userSubjects,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load user data: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Get current user
  AppUser? get currentUser => state.currentUser;

  /// Get user's selected grade
  Grade? get userGrade {
    if (state.currentUser?.profile?.gradeId == null ||
        state.availableGrades.isEmpty) {
      return null;
    }

    try {
      return state.availableGrades.firstWhere(
        (grade) => grade.id == state.currentUser!.profile!.gradeId,
      );
    } catch (e) {
      // If no matching grade found, return null
      return null;
    }
  }

  /// Get user's subjects
  List<Subject> get userSubjects => state.userSubjects;

  /// Check if user has completed profile
  bool get hasCompletedProfile =>
      state.currentUser?.hasCompletedProfile ?? false;

  /// Get user's display name
  String get userDisplayName {
    if (state.currentUser?.profile?.firstName != null) {
      return state.currentUser!.profile!.firstName!;
    }
    return state.currentUser?.email.split('@').first ?? 'User';
  }

  /// Navigate to profile setup/edit
  Future<void> navigateToProfileSetup() async {
    await NavigationService.navigateToOnboarding();
  }

  /// Navigate to subjects screen
  void navigateToSubjects() {
    _ref.read(bottomNavigationProvider.notifier).navigateToSubjects();
  }

  /// Navigate to practice screen
  void navigateToPractice() {
    _ref.read(bottomNavigationProvider.notifier).navigateToPractice();
  }

  /// Show sign out confirmation dialog
  void showSignOutDialog(BuildContext context) {
    NavigationService.showCustomDialog(
      child: AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => NavigationService.navigateBack(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              NavigationService.navigateBack();
              await signOut(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  /// Sign out user
  Future<void> signOut(BuildContext context) async {
    state = state.copyWith(isSigningOut: true);

    try {
      await _ref
          .read(authViewModelProvider.notifier)
          .signOutUserInUI(context: context);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to sign out: ${e.toString()}',
        isSigningOut: false,
      );
    }
  }

  /// Refresh home data
  Future<void> refresh() async {
    await _initializeHome();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
