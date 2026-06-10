import 'package:past_question_paper_v1/features/profile/domain/entities/user.dart';

abstract class IAuthService {
  Stream<AppUser?> get authStateChanges;
  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
  );

  Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
  );

  Future<void> signOut();
  AppUser? get currentUser;
  Future<void> sendPasswordResetEmail(String email);

  Future<void> deleteAccount();

  /// Re-authenticates the current user with email & password then deletes the auth account.
  /// Throws if re-auth fails or deletion is blocked by security rules.
  Future<void> reauthenticateAndDelete({
    required String email,
    required String password,
  });

  /// Sends a sign-in link to the user's email
  Future<void> sendSignInLinkToEmail(String email);

  /// Sends a custom branded email verification message via backend callable.
  Future<void> sendVerificationEmail();

  /// Completes the sign-in process with the received email link
  Future<void> signInWithEmailLink(String email, String emailLink);

  /// Checks if the given link is a valid email sign-in link
  bool isSignInWithEmailLink(String emailLink);

  Future<void> signInWithGoogle();
}
