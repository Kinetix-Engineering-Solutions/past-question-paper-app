import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/user.dart';
import 'package:past_question_paper_v1/providers/auth_providers.dart';
import 'package:past_question_paper_v1/providers/navigation_providers.dart';
import 'package:past_question_paper_v1/services/auth_service_firebase.dart';
import 'package:past_question_paper_v1/services/navigation_service.dart';
import 'package:past_question_paper_v1/Exceptions/auth_exception.dart';
import 'package:past_question_paper_v1/widgets/custom_snackbar.dart';
import 'package:past_question_paper_v1/utils/loading_state.dart';
import 'package:past_question_paper_v1/views/email_verification_screen.dart';

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

      // Show success message
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Login successful! Welcome back.',
          isError: false,
        );
      }

      // Navigate based on profile completion
      if (!context.mounted) return;

      if (user.hasCompletedProfile) {
        await NavigationService.navigateToHome();
      } else {
        await NavigationService.navigateToOnboarding();
      }
    } on AuthException catch (e) {
      final isVerificationNotice = e.code == 'email-not-verified';

      if (isVerificationNotice) {
        state = const AsyncValue.data(null);
      } else {
        // Update auth state with error
        state = AsyncValue.error(e.message, StackTrace.current);
      }

      // Show message to user
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: e.message,
          isError: !isVerificationNotice,
        );

        // Navigate to email verification screen for better UX
        if (isVerificationNotice) {
          // Delay navigation slightly so snackbar is visible
          await Future.delayed(const Duration(milliseconds: 1500));
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => EmailVerificationScreen(email: email),
              ),
            );
          }
        }
      }
    } catch (e) {
      // Handle unexpected errors
      state = AsyncValue.error(
        'An unexpected error occurred',
        StackTrace.current,
      );
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

      // Show success message
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message:
              'Account created successfully! Welcome to Past Question Papers.',
          isError: false,
        );
      }

      // Navigate based on profile completion
      if (!context.mounted) return;

      if (user.hasCompletedProfile) {
        await NavigationService.navigateToHome();
      } else {
        await NavigationService.navigateToOnboarding();
      }
    } on AuthException catch (e) {
      final isVerificationNotice = e.code == 'email-not-verified';

      if (isVerificationNotice) {
        state = const AsyncValue.data(null);
      } else {
        // Update auth state with error
        state = AsyncValue.error(e.message, StackTrace.current);
      }

      // Show message to user
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: e.message,
          isError: !isVerificationNotice,
        );

        // Navigate to email verification screen for better UX
        if (isVerificationNotice) {
          // Delay navigation slightly so snackbar is visible
          await Future.delayed(const Duration(milliseconds: 1500));
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => EmailVerificationScreen(email: email),
              ),
            );
          }
        }
      }
    } catch (e) {
      // Handle unexpected errors
      state = AsyncValue.error(
        'An unexpected error occurred',
        StackTrace.current,
      );
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

      // Reset navigation to home tab for next login
      _ref.read(bottomNavigationProvider.notifier).reset();

      // Immediately update auth state to null to trigger navigation
      state = const AsyncValue.data(null);

      // Reset loading state
      _ref.read(loadingStateProvider.notifier).state = false;

      // The AppInitializer will automatically navigate to login when user becomes null
    } on AuthException catch (e) {
      // Reset loading state on error
      _ref.read(loadingStateProvider.notifier).state = false;

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
      // Reset loading state on error
      _ref.read(loadingStateProvider.notifier).state = false;

      // Handle unexpected errors
      state = AsyncValue.error('Failed to sign out', StackTrace.current);

      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Failed to sign out',
          isError: true,
        );
      }
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

      // Keep snackbar for forgot password errors since it's triggered from a button
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

      // Show success message
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Sign-in successful! Welcome back.',
          isError: false,
        );
      }

      // Navigate based on profile completion
      if (!context.mounted) return;

      if (user.hasCompletedProfile) {
        await NavigationService.navigateToHome();
      } else {
        await NavigationService.navigateToOnboarding();
      }
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

  /// Refresh current user data (useful after profile updates)
  Future<void> refreshUser() async {
    try {
      final currentUser = state.value;
      if (currentUser?.id != null) {
        state = const AsyncValue.loading();
        final updatedUser = await _ref
            .read(userRepositoryProvider)
            .getUserFromFirestore(currentUser!.id);
        state = AsyncValue.data(updatedUser);
      }
    } catch (e) {
      state = AsyncValue.error(
        'Failed to refresh user data',
        StackTrace.current,
      );
    }
  }

  /// Check if user is currently authenticated (persists across app restarts)
  bool get isUserLoggedIn {
    return state.hasValue && state.value != null;
  }

  /// Get the current authentication state as a boolean
  bool get isAuthenticated => isUserLoggedIn;

  /// Delete user account with re-authentication (Auth only; data cleanup handled by Cloud Function trigger)
  Future<void> deleteAccountInUI({
    required BuildContext context,
    required String password,
  }) async {
    try {
      _ref.read(loadingStateProvider.notifier).state = true;
      final currentUser = state.value;
      if (currentUser == null) {
        throw AuthException(
          'No user is currently signed in',
          code: 'no-current-user',
        );
      }
      final email = currentUser.email;
      if (email == null || email.isEmpty) {
        throw AuthException(
          'Missing email for re-authentication',
          code: 'missing-email',
        );
      }

      // Re-authenticate & delete auth user (Firestore & Storage cleanup runs server-side)
      await _ref
          .read(userRepositoryProvider)
          .reauthenticateAndDelete(email: email, password: password);
      state = const AsyncValue.data(null);
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Account deleted successfully',
          isError: false,
        );
        await NavigationService.navigateToLogin();
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: e.message,
          isError: true,
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Failed to delete account: $e',
          isError: true,
        );
      }
    } finally {
      _ref.read(loadingStateProvider.notifier).state = false;
    }
  }
}
