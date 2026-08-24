import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:past_question_paper_v1/features/auth/data/auth_repository.dart';
import 'package:past_question_paper_v1/features/auth/domain/account_declaration.dart';
import 'package:past_question_paper_v1/features/auth/domain/account_type.dart';
import 'package:past_question_paper_v1/features/auth/domain/app_user.dart';
import 'package:past_question_paper_v1/features/auth/domain/sign_up_result.dart';
import 'package:past_question_paper_v1/features/auth/providers/auth_providers.dart';

void main() {
  test('auth state exposes the current user', () async {
    final repository = _FakeAuthRepository(
      currentUser: const AppUser(id: 'user-id', email: 'learner@example.com'),
    );

    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);

    final user = await container.read(authStateProvider.future);

    expect(user?.id, 'user-id');
  });

  test('auth controller signs in through repository', () async {
    final repository = _FakeAuthRepository();

    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);

    await container.read(authActionControllerProvider.future);

    await container
        .read(authActionControllerProvider.notifier)
        .signIn(email: 'learner@example.com', password: 'password123');

    expect(repository.signInCalls, 1);
    expect(container.read(authActionControllerProvider).hasError, isFalse);
  });
}

final class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.currentUser});

  @override
  AppUser? currentUser;

  int signInCalls = 0;

  final _authChanges = StreamController<AppUser?>.broadcast();

  @override
  Stream<AppUser?> authStateChanges() {
    return _authChanges.stream;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalls++;
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required AccountType accountType,
    required bool declarationAccepted,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AccountDeclaration?> getAccountDeclaration() async => null;

  @override
  Future<AccountDeclaration> recordAccountDeclaration({
    required AccountType accountType,
    required bool declarationAccepted,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAccount({required String confirmation}) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordReset({required String email}) async {}
}
