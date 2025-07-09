import 'package:firebase_auth/firebase_auth.dart';
import 'package:past_question_paper_stem/model/user.dart';

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
}
