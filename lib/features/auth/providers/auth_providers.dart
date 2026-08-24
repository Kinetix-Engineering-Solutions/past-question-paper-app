import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';
import '../data/supabase_auth_repository.dart';
import '../domain/account_declaration.dart';
import '../domain/account_type.dart';
import '../domain/app_user.dart';
import '../domain/sign_up_result.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(client: ref.watch(supabaseClientProvider));
});

final authStateProvider = StreamProvider<AppUser?>((ref) async* {
  final repository = ref.watch(authRepositoryProvider);

  yield repository.currentUser;
  yield* repository.authStateChanges();
});

final accountDeclarationProvider =
    FutureProvider.autoDispose<AccountDeclaration?>((ref) async {
      final user = ref.watch(authStateProvider).asData?.value;

      if (user == null) {
        return null;
      }

      return ref.watch(authRepositoryProvider).getAccountDeclaration();
    });

final authActionControllerProvider =
    AsyncNotifierProvider<AuthActionController, void>(AuthActionController.new);

class AuthActionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signIn({required String email, required String password}) {
    return _run(
      () => ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password),
    );
  }

  Future<SignUpResult?> signUp({
    required String email,
    required String password,
    required AccountType accountType,
    required bool declarationAccepted,
  }) async {
    if (state.isLoading) {
      return null;
    }

    state = const AsyncLoading();

    try {
      final result = await ref
          .read(authRepositoryProvider)
          .signUp(
            email: email,
            password: password,
            accountType: accountType,
            declarationAccepted: declarationAccepted,
          );

      state = const AsyncData(null);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }

  Future<bool> deleteAccount({required String confirmation}) async {
    if (state.isLoading) {
      return false;
    }

    state = const AsyncLoading();

    try {
      await ref
          .read(authRepositoryProvider)
          .deleteAccount(confirmation: confirmation);

      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<bool> recordAccountDeclaration({
    required AccountType accountType,
    required bool declarationAccepted,
  }) async {
    if (state.isLoading) {
      return false;
    }

    state = const AsyncLoading();

    try {
      await ref
          .read(authRepositoryProvider)
          .recordAccountDeclaration(
            accountType: accountType,
            declarationAccepted: declarationAccepted,
          );

      ref.invalidate(accountDeclarationProvider);

      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<void> signOut() {
    return _run(() => ref.read(authRepositoryProvider).signOut());
  }

  Future<void> sendPasswordReset({required String email}) {
    return _run(
      () => ref.read(authRepositoryProvider).sendPasswordReset(email: email),
    );
  }

  Future<void> _run(Future<void> Function() operation) async {
    if (state.isLoading) {
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(operation);
  }
}
