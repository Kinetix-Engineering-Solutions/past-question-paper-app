import 'package:flutter_riverpod/flutter_riverpod.dart';

// Bottom Navigation Provider
final bottomNavigationProvider =
    StateNotifierProvider<BottomNavigationNotifier, int>((ref) {
      return BottomNavigationNotifier();
    });

class BottomNavigationNotifier extends StateNotifier<int> {
  BottomNavigationNotifier() : super(0);

  void setIndex(int index) {
    state = index;
  }

  void navigateToHome() => state = 0;
  void navigateToSubjects() => state = 1;
  void navigateToHistory() => state = 1;
  void navigateToPractice() => state = 2;
  void navigateToProfile() => state = 3;

  // Reset to home tab (useful for logout/login scenarios)
  void reset() => state = 0;
}
