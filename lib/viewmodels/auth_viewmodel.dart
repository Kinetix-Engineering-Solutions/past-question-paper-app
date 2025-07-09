import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/user.dart';
import 'package:past_question_paper_stem/providers/auth_providers.dart';

// Auth View Model Provider
final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AsyncValue<AppUser?>>((ref) {
      return AuthViewModel(ref);
    });

class AuthViewModel extends StateNotifier<AsyncValue<AppUser?>> {
  final Ref _ref;

  AuthViewModel(this._ref) : super(const AsyncValue.loading()) {
    // Initialize by listening to auth state changes
    _ref.listen(authStateProvider, (previous, next) {
      state = next;
    });
  }

  /// Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    try {
      state = const AsyncValue.loading();
      final user = await _ref
          .read(userRepositoryProvider)
          .signIn(email, password);
      state = AsyncValue.data(user);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(_getErrorMessage(e), StackTrace.current);
    }
  }

  /// Sign up with email and password
  Future<void> signUp({required String email, required String password}) async {
    try {
      state = const AsyncValue.loading();
      final user = await _ref
          .read(userRepositoryProvider)
          .signUp(email, password);
      state = AsyncValue.data(user);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(_getErrorMessage(e), StackTrace.current);
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _ref.read(userRepositoryProvider).signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  //
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      state = const AsyncValue.loading();
      await _ref.read(userRepositoryProvider).sendPasswordResetEmail(email);
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(_getErrorMessage(e), StackTrace.current);
    }
  }

  /// Get the current user
  AppUser? get currentUser => _ref.read(currentUserProvider);

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
