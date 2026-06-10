import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:past_question_paper_v1/features/profile/domain/entities/user.dart';
import 'package:past_question_paper_v1/core/shared/services/firestore_database_firebase.dart';
import 'package:past_question_paper_v1/features/auth/data/services/iauthservice.dart';
import 'package:past_question_paper_v1/Exceptions/auth_exception.dart';

class AuthServiceFirebase implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirestoreDatabaseService _database = FirestoreDatabaseService();
  static const String _emailForSignInKey = 'email_for_link_sign_in';
  static const String _verificationLastSentAtKeyPrefix =
      'verification_email_last_sent_at_';
  static const int _verificationCooldownSeconds = 60;

  // Configure Firebase ActionCodeSettings for email link sign-in
  final ActionCodeSettings actionCodeSettings = ActionCodeSettings(
    url: 'https://vibe-code-4c59f.firebaseapp.com',
    handleCodeInApp: true,
    //iOSBundleId: 'com.example.ios',
    androidPackageName: 'com.kinetix.past_question_paper',
    androidInstallApp: true,
    androidMinimumVersion: '12',
  );

  // Convert Firebase User to AppUser
  AppUser? _userFromFirebaseUser(User? user) {
    if (user == null) return null;
    return AppUser(id: user.uid, email: user.email ?? '');
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      if (!user.emailVerified) {
        return null;
      }
      return _userFromFirebaseUser(user);
    });
  }

  /// Get the current user from Firebase Auth
  @override
  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    if (!user.emailVerified) {
      return null;
    }
    return _userFromFirebaseUser(user);
  }

  @override
  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user != null && !user.emailVerified) {
        throw AuthException(
          '⚠️ Email Not Verified\n\n'
          'Please verify your email address first.\n\n'
          'Check your inbox (and spam folder) for the verification link '
          'we sent to ${user.email ?? 'your email'}, then sign in again.',
          code: 'email-not-verified',
        );
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    }
  }

  /// Sign up with email and password

  @override
  Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Create the user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create AppUser instance
      final appUser = _userFromFirebaseUser(result.user);
      if (appUser == null) {
        throw AuthException(
          'Failed to create user profile',
          code: 'user-creation-failed',
        );
      }

      // Save the user to Firestore
      await _database.saveUser(appUser);

      if (result.user != null && !(result.user!.emailVerified)) {
        try {
          await sendVerificationEmail();
        } catch (verificationError) {
          final isExpectedCooldown =
              verificationError is AuthException &&
              (verificationError.code == 'verification-cooldown' ||
                  verificationError.code == 'too-many-requests');

          if (kDebugMode && !isExpectedCooldown) {
            debugPrint(
              '⚠️ Failed to send verification email after sign up: $verificationError',
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Sends a password reset email to the user
  /// This method is used when the user forgets their password
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final normalizedEmail = email.trim();

    try {
      final callable = _functions.httpsCallable('createPasswordResetLink');
      await callable.call({'email': normalizedEmail});
    } on FirebaseFunctionsException catch (e) {
      final functionCode = e.code.toLowerCase();

      // Fallback to Firebase Auth built-in reset flow when the custom
      // password reset function is temporarily unavailable.
      if (functionCode == 'unavailable' ||
          functionCode == 'deadline-exceeded' ||
          functionCode == 'internal' ||
          functionCode == 'not-found') {
        try {
          await _auth.sendPasswordResetEmail(email: normalizedEmail);
          return;
        } on FirebaseAuthException catch (authError) {
          // Keep privacy-preserving behavior identical to callable function.
          if (authError.code == 'user-not-found') {
            return;
          }
          throw AuthException.fromFirebaseAuth(authError);
        }
      }

      if (functionCode == 'invalid-argument') {
        throw AuthException('The email address is not valid.', code: e.code);
      }

      if (functionCode == 'failed-precondition') {
        throw AuthException(
          e.message ?? 'Password reset service is not configured correctly.',
          code: e.code,
        );
      }

      throw AuthException(
        e.message ??
            'Unable to send password reset email right now. Please try again.',
        code: e.code,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Avoid account enumeration via explicit user-not-found errors.
        return;
      }
      throw AuthException.fromFirebaseAuth(e);
    }
  }

  /// Sends a sign-in link to the user's email
  @override
  Future<void> sendSignInLinkToEmail(String email) async {
    try {
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
      // Save the email locally to use it for sign-in completion
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_emailForSignInKey, email);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    }
  }

  @override
  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException(
        'Session expired. Please sign in again.',
        code: 'no-current-user',
      );
    }

    if (user.emailVerified) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final cooldownSecondsRemaining = await _getVerificationCooldownRemaining(
      prefs,
      user.uid,
    );
    if (cooldownSecondsRemaining > 0) {
      throw AuthException(
        'Please wait $cooldownSecondsRemaining seconds before requesting another verification email.',
        code: 'verification-cooldown',
      );
    }

    try {
      final callable = _functions.httpsCallable('createEmailVerificationLink');
      await callable.call();
      await _markVerificationEmailSent(prefs, user.uid);
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'resource-exhausted') {
        throw AuthException(
          e.message ??
              'Please wait a moment before requesting another verification email.',
          code: 'verification-cooldown',
        );
      }

      if (e.code == 'unauthenticated') {
        throw AuthException(
          'Session expired. Please sign in again.',
          code: 'no-current-user',
        );
      }

      if (e.code == 'failed-precondition') {
        throw AuthException(
          e.message ??
              'Email verification service is not configured. Please contact support.',
          code: 'verification-config-error',
        );
      }

      if (kDebugMode) {
        debugPrint(
          '❌ createEmailVerificationLink function error — '
          'code: ${e.code} | message: ${e.message} | details: ${e.details}',
        );
      }

      throw AuthException(
        e.message ?? 'Failed to send verification email. Please try again.',
        code: 'verification-email-failed',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '❌ sendVerificationEmail unexpected error — '
          'type: ${e.runtimeType} | value: $e',
        );
      }
      throw AuthException(
        'Failed to send verification email. Please try again.',
        code: 'verification-email-failed',
      );
    }
  }

  String _verificationSentAtKeyForUser(String userId) {
    return '$_verificationLastSentAtKeyPrefix$userId';
  }

  Future<int> _getVerificationCooldownRemaining(
    SharedPreferences prefs,
    String userId,
  ) async {
    final key = _verificationSentAtKeyForUser(userId);
    final lastSentAtMillis = prefs.getInt(key);
    if (lastSentAtMillis == null) {
      return 0;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedSeconds = ((now - lastSentAtMillis) / 1000).floor();
    final remaining = _verificationCooldownSeconds - elapsedSeconds;
    return remaining > 0 ? remaining : 0;
  }

  Future<void> _markVerificationEmailSent(
    SharedPreferences prefs,
    String userId,
  ) async {
    final key = _verificationSentAtKeyForUser(userId);
    await prefs.setInt(key, DateTime.now().millisecondsSinceEpoch);
  }

  /// Completes the sign-in process with the received email link
  @override
  Future<void> signInWithEmailLink(
    String email,
    String emailLink,
  ) async {
    try {
      final UserCredential result = await _auth.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );

      // If this is a new user, create their profile in Firestore
      if (result.additionalUserInfo?.isNewUser ?? false) {
        final appUser = _userFromFirebaseUser(result.user);
        if (appUser == null) {
          throw AuthException(
            'Failed to create user profile',
            code: 'user-creation-failed',
          );
        }
        await _database.saveUser(appUser);
      }

      // Clear the saved email after successful sign-in
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_emailForSignInKey);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    // Firebase Google sign in implementation...
  }

  @override
  bool isSignInWithEmailLink(String emailLink) {
    return _auth.isSignInWithEmailLink(emailLink);
  }

  /// Deletes the current user's account
  /// This permanently deletes the user from Firebase Auth
  /// Note: User data in Firestore should be deleted separately
  @override
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException(
          'No user is currently signed in',
          code: 'no-current-user',
        );
      }
      await user.delete();
    } on FirebaseAuthException catch (e) {
      // Handle re-authentication required error
      if (e.code == 'requires-recent-login') {
        throw AuthException(
          'For security, please sign out and sign in again before deleting your account',
          code: 'requires-recent-login',
        );
      }
      throw AuthException.fromFirebaseAuth(e);
    }
  }

  @override
  Future<void> reauthenticateAndDelete({
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException(
        'No user is currently signed in',
        code: 'no-current-user',
      );
    }
    try {
      // Re-authenticate first
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      // Then delete
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw AuthException('Incorrect password.', code: 'wrong-password');
      }
      if (e.code == 'user-mismatch' || e.code == 'user-not-found') {
        throw AuthException(
          'Authentication mismatch. Please sign in again.',
          code: e.code,
        );
      }
      if (e.code == 'too-many-requests') {
        throw AuthException(
          'Too many attempts. Please wait and try again.',
          code: e.code,
        );
      }
      if (e.code == 'requires-recent-login') {
        throw AuthException(
          'Session expired. Sign in again and retry.',
          code: e.code,
        );
      }
      throw AuthException.fromFirebaseAuth(e);
    }
  }
}
