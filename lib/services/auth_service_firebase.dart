import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:past_question_paper_v1/model/user.dart';
import 'package:past_question_paper_v1/services/firestore_database_firebase.dart';
import 'package:past_question_paper_v1/services/iauthservice.dart';
import 'package:past_question_paper_v1/Exceptions/auth_exception.dart';

class AuthServiceFirebase implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreDatabaseService _database = FirestoreDatabaseService();
  static const String _emailForSignInKey = 'email_for_link_sign_in';

  // Configure Firebase ActionCodeSettings for email link sign-in
  final ActionCodeSettings actionCodeSettings = ActionCodeSettings(
    url: 'https://vibe-code-4c59f.firebaseapp.com',
    handleCodeInApp: true,
    //iOSBundleId: 'com.example.ios',
    androidPackageName: 'com.example.past_question_paper_v1',
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
  Future<UserCredential> signInWithEmailAndPassword(
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
        try {
          await user.sendEmailVerification();
        } catch (verificationError) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ Failed to send verification email: $verificationError',
            );
          }
        }

        await _auth.signOut();

        throw AuthException(
          '⚠️ Email Not Verified\n\n'
          'Please verify your email address first.\n\n'
          'We\'ve sent a verification link to ${user.email ?? 'your email'}. '
          'Check your inbox (and spam folder), click the link, then sign in again.',
          code: 'email-not-verified',
        );
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    }
  }

  /// Sign up with email and password

  @override
  Future<UserCredential> signUpWithEmailAndPassword(
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
          await result.user!.sendEmailVerification();
        } catch (verificationError) {
          if (kDebugMode) {
            debugPrint(
              '⚠️ Failed to send verification email after sign up: $verificationError',
            );
          }
        }
      }

      return result;
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
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
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

  /// Completes the sign-in process with the received email link
  @override
  Future<UserCredential> signInWithEmailLink(
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

      return result;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    }
  }

  /// Checks if the given link is a valid email sign-in link
  @override
  bool isSignInWithEmailLink(String emailLink) {
    return _auth.isSignInWithEmailLink(emailLink);
  }

  /// Checks if a user is currently logged in
  /// This persists across app restarts automatically via Firebase
  bool isUserLoggedIn() {
    final user = _auth.currentUser;
    return user != null && user.emailVerified;
  }

  /// Gets the current authentication state
  /// Returns true if user is authenticated, false otherwise
  bool get isAuthenticated {
    final user = _auth.currentUser;
    return user != null && user.emailVerified;
  }

  /// Wait for the initial auth state to be determined
  /// Useful for splash screens or app initialization
  Future<AppUser?> waitForAuthInitialization() async {
    // Firebase Auth automatically restores the user session
    // This just waits for the first auth state change
    return await authStateChanges.first;
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
