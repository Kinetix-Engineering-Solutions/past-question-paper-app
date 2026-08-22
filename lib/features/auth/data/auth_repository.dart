import '../domain/app_user.dart';
import '../domain/sign_up_result.dart';

abstract interface class AuthRepository {
  AppUser? get currentUser;

  Stream<AppUser?> authStateChanges();

  Future<void> signIn({required String email, required String password});

  Future<SignUpResult> signUp({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendPasswordReset({required String email});
}
