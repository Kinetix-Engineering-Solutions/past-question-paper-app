import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/user.dart';
import 'package:past_question_paper_v1/utils/app_constants.dart';
import 'package:past_question_paper_v1/viewmodels/auth_viewmodel.dart';

// Riverpod provider for the HomeViewModel
final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((
  ref,
) {
  final authState = ref.watch(authViewModelProvider);
  return HomeViewModel(authState.asData?.value);
});

// State class for the home screen
class HomeState {
  final AppUser? user;
  final int selectedGrade;

  const HomeState({this.user, this.selectedGrade = 12});

  HomeState copyWith({AppUser? user, int? selectedGrade}) {
    return HomeState(
      user: user ?? this.user,
      selectedGrade: selectedGrade ?? this.selectedGrade,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel(AppUser? currentUser) : super(const HomeState()) {
    _initialize(currentUser);
  }

  void _initialize(AppUser? currentUser) {
    if (currentUser != null) {
      // If the user has a grade saved in their profile, use it.
      // Otherwise, default to the last grade in our constants list (e.g., 12).
      final initialGrade = currentUser.grade ?? AppConstants.grades.last;
      state = state.copyWith(user: currentUser, selectedGrade: initialGrade);
    }
  }

  /// Updates the selected grade in the UI.
  void selectGrade(int grade) {
    state = state.copyWith(selectedGrade: grade);
  }
}
