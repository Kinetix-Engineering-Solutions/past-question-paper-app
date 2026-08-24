import '../domain/account_declaration.dart';
import '../domain/account_type.dart';
import '../domain/app_user.dart';
import '../domain/sign_up_result.dart';

abstract interface class AuthRepository {
  AppUser? get currentUser;

  Stream<AppUser?> authStateChanges();

  Future<void> signIn({required String email, required String password});

  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required AccountType accountType,
    required bool declarationAccepted,
  });

  Future<AccountDeclaration?> getAccountDeclaration();

  Future<AccountDeclaration> recordAccountDeclaration({
    required AccountType accountType,
    required bool declarationAccepted,
  });

  Future<void> deleteAccount({required String confirmation});

  Future<void> signOut();

  Future<void> sendPasswordReset({required String email});
}
