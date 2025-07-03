import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/app_user.dart';
import '../../services/user_service.dart';
import '../state/user_state.dart';

// UserViewModel
class UserViewModel extends StateNotifier<UserState> {
  final UserService _userService;

  UserViewModel(this._userService) : super(const UserState());

  // Method to handle user creation, retrieval, update, and deletion
  Future<void> createUser(AppUser user) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _userService.createUser(user);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Method to retrieve a user by ID
  Future<void> getUser(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final user = await _userService.getUserById(userId);
      if (user != null) {
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(error: 'User not found', isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Method to update user information
  Future<void> updateUser(AppUser user) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _userService.updateUser(user);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Method to delete a user
  Future<void> deleteUser(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _userService.deleteUser(userId);
      state = const UserState();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Method to update specific fields of a user
  Future<void> updateUserFields(
    String userId,
    Map<String, dynamic> fields,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _userService.updateUserFields(userId, fields);
      final updatedUser = await _userService.getUserById(userId);
      if (updatedUser != null) {
        state = state.copyWith(user: updatedUser, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
