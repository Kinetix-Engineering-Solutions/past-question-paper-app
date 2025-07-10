import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/user.dart';
import 'package:past_question_paper_stem/providers/auth_providers.dart';
import 'package:past_question_paper_stem/services/auth_service_firebase.dart';
import 'package:past_question_paper_stem/Exceptions/auth_exception.dart';
import 'package:past_question_paper_stem/views/home_screen.dart';
import 'package:past_question_paper_stem/views/login.dart';
import 'package:past_question_paper_stem/widgets/custom_snackbar.dart';
import 'package:past_question_paper_stem/utils/loading_state.dart';

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

  // Expose the auth service for email link sign-in
  AuthServiceFirebase get authService => _ref.read(authServiceProvider);

  /// Sign in with email and password in the UI
  Future<void> signInUserInUI({
    required String email,
    required String password,
    required BuildContext context,
    required GlobalKey<FormState> formKey,
  }) async {
    // Validate form
    if (!formKey.currentState!.validate()) return;

    try {
      // Set loading state
      _ref.read(loadingStateProvider.notifier).state = true;

      // Set auth state to loading
      state = const AsyncValue.loading();

      // Attempt sign in
      final user = await _ref
          .read(userRepositoryProvider)
          .signIn(email, password);

      // Update auth state with user data
      state = AsyncValue.data(user);

      // Navigate to home screen after successful sign in
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on AuthException catch (e) {
      // Update auth state with error
      state = AsyncValue.error(e.message, StackTrace.current);

      // Show error message
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: e.message,
          isError: true,
        );
      }
    } catch (e) {
      // Handle unexpected errors
      state = AsyncValue.error(
        'An unexpected error occurred',
        StackTrace.current,
      );

      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'An unexpected error occurred',
          isError: true,
        );
      }
    } finally {
      // Reset loading state
      _ref.read(loadingStateProvider.notifier).state = false;
    }
  }

  /// Sign up with email and password in the UI
  Future<void> signUpUserInUI({
    required String email,
    required String password,
    required BuildContext context,
    required GlobalKey<FormState> formKey,
  }) async {
    // Validate form
    if (!formKey.currentState!.validate()) return;

    try {
      // Set loading state
      _ref.read(loadingStateProvider.notifier).state = true;

      // Set auth state to loading
      state = const AsyncValue.loading();

      // Attempt sign up
      final user = await _ref
          .read(userRepositoryProvider)
          .signUp(email, password);

      // Update auth state with user data
      state = AsyncValue.data(user);

      // Navigate to home screen after successful sign up
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on AuthException catch (e) {
      // Update auth state with error
      state = AsyncValue.error(e.message, StackTrace.current);

      // Show error message
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: e.message,
          isError: true,
        );
      }
    } catch (e) {
      // Handle unexpected errors
      state = AsyncValue.error(
        'An unexpected error occurred',
        StackTrace.current,
      );

      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'An unexpected error occurred',
          isError: true,
        );
      }
    } finally {
      // Reset loading state
      _ref.read(loadingStateProvider.notifier).state = false;
    }
  }

  /// Sign out the current user in the UI
  Future<void> signOutUserInUI({required BuildContext context}) async {
    try {
      // Set loading state
      _ref.read(loadingStateProvider.notifier).state = true;

      // Attempt sign out
      await _ref.read(userRepositoryProvider).signOut();

      // Update auth state
      state = const AsyncValue.data(null);

      // Navigate to login screen after successful sign out
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, // Remove all previous routes
      );
    } on AuthException catch (e) {
      // Update auth state with error
      state = AsyncValue.error(e.message, StackTrace.current);

      // Show error message
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: e.message,
          isError: true,
        );
      }
    } catch (e) {
      // Handle unexpected errors
      state = AsyncValue.error('Failed to sign out', StackTrace.current);

      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Failed to sign out',
          isError: true,
        );
      }
    } finally {
      // Reset loading state
      _ref.read(loadingStateProvider.notifier).state = false;
    }
  }

  /// Send password reset email in the UI
  Future<void> sendPasswordResetEmailInUI({
    required String email,
    required BuildContext context,
    required GlobalKey<FormState> formKey,
  }) async {
    // Validate form
    if (!formKey.currentState!.validate()) return;

    try {
      // Set loading state
      _ref.read(loadingStateProvider.notifier).state = true;

      // Set auth state to loading
      state = const AsyncValue.loading();

      // Attempt to send password reset email
      await _ref.read(userRepositoryProvider).sendPasswordResetEmail(email);

      // Update auth state
      state = const AsyncValue.data(null);

      // Show success message
      if (!context.mounted) return;
      CustomSnackBar.show(
        context: context,
        message: 'Password reset email sent. Please check your inbox.',
        isError: false,
      );
    } on AuthException catch (e) {
      // Update auth state with error
      state = AsyncValue.error(e.message, StackTrace.current);

      // Show error message
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: e.message,
          isError: true,
        );
      }
    } catch (e) {
      // Handle unexpected errors
      state = AsyncValue.error(
        'An unexpected error occurred',
        StackTrace.current,
      );

      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'An unexpected error occurred',
          isError: true,
        );
      }
    } finally {
      // Reset loading state
      _ref.read(loadingStateProvider.notifier).state = false;
    }
  }

  /// Get the current user from the repository
  AppUser? get currentUser => _ref.read(currentUserProvider);

  /// Sign in with email link in the UI
  Future<void> signInWithEmailLinkInUI({
    required String email,
    required String emailLink,
    required BuildContext context,
  }) async {
    try {
      // Set loading state
      _ref.read(loadingStateProvider.notifier).state = true;

      // Set auth state to loading
      state = const AsyncValue.loading();

      // Attempt sign in with email link
      final user = await _ref
          .read(userRepositoryProvider)
          .signInWithEmailLink(email, emailLink);

      // Update auth state with user data
      state = AsyncValue.data(user);

      // Navigate to home screen after successful sign in
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on AuthException catch (e) {
      // Update auth state with error
      state = AsyncValue.error(e.message, StackTrace.current);

      // Show error message
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: e.message,
          isError: true,
        );
      }
    } catch (e) {
      // Handle unexpected errors
      state = AsyncValue.error(
        'An unexpected error occurred',
        StackTrace.current,
      );

      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'An unexpected error occurred',
          isError: true,
        );
      }
    } finally {
      // Reset loading state
      _ref.read(loadingStateProvider.notifier).state = false;
    }
  }
}
