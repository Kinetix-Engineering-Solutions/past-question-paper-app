import 'package:firebase_auth/firebase_auth.dart';
import 'package:past_question_paper_v1/model/user.dart';

abstract class IAuthService {
  Stream<AppUser?> get authStateChanges;
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  );

  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  );

  Future<void> signOut();
  AppUser? get currentUser;
  Future<void> sendPasswordResetEmail(String email);

  /// Sends a sign-in link to the user's email
  Future<void> sendSignInLinkToEmail(String email);

  /// Completes the sign-in process with the received email link
  Future<UserCredential> signInWithEmailLink(String email, String emailLink);

  /// Checks if the given link is a valid email sign-in link
  bool isSignInWithEmailLink(String emailLink);
}
