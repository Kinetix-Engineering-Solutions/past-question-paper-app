import 'package:past_question_paper_v1/features/auth/data/auth_repository.dart';
import 'package:past_question_paper_v1/features/auth/domain/sign_up_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/account_declaration.dart';
import '../domain/account_type.dart';
import '../domain/app_user.dart';

final class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository({required SupabaseClient client})
    : _client = client;

  final SupabaseClient _client;

  @override
  AppUser? get currentUser {
    return _mapUser(_client.auth.currentUser);
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _client.auth.onAuthStateChange
        .map((event) => _mapUser(event.session?.user))
        .distinct((previous, next) => previous?.id == next?.id);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required AccountType accountType,
    required bool declarationAccepted,
  }) async {
    if (!declarationAccepted) {
      throw ArgumentError('The account declaration must be accepted.');
    }

    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'account_type': accountType.apiValue,
        'account_declaration_accepted': declarationAccepted,
      },
    );

    final user = _mapUser(response.user);

    if (user == null) {
      throw StateError('Supabase did not return the created user.');
    }

    return SignUpResult(
      user: user,
      requiresEmailConfirmation: response.session == null,
    );
  }

  @override
  Future<AccountDeclaration?> getAccountDeclaration() async {
    if (_client.auth.currentUser == null) {
      return null;
    }

    final data = await _client.rpc('get_my_account_declaration');

    if (data == null) {
      return null;
    }

    if (data is! Map) {
      throw const FormatException(
        'Account declaration RPC returned an invalid response.',
      );
    }

    return AccountDeclaration.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<AccountDeclaration> recordAccountDeclaration({
    required AccountType accountType,
    required bool declarationAccepted,
  }) async {
    final data = await _client.rpc(
      'record_account_declaration',
      params: {
        'p_account_type': accountType.apiValue,
        'p_declaration_accepted': declarationAccepted,
      },
    );

    if (data is! Map) {
      throw const FormatException(
        'Account declaration RPC returned an invalid response.',
      );
    }

    return AccountDeclaration.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> deleteAccount({required String confirmation}) async {
    if (_client.auth.currentUser == null) {
      throw StateError('Authentication is required.');
    }

    final response = await _client.functions.invoke(
      'delete-account',
      body: {'confirmation': confirmation},
    );

    final data = response.data;

    if (response.status < 200 ||
        response.status >= 300 ||
        data is! Map ||
        data['deleted'] != true) {
      throw StateError('The account could not be deleted.');
    }

    // The server account is now deleted. Clear the local Flutter session.
    await _client.auth.signOut(scope: SignOutScope.local);
  }

  @override
  Future<void> signOut() {
    return _client.auth.signOut();
  }

  @override
  Future<void> sendPasswordReset({required String email}) {
    return _client.auth.resetPasswordForEmail(email.trim());
  }

  AppUser? _mapUser(User? user) {
    if (user == null) {
      return null;
    }

    return AppUser(id: user.id, email: user.email);
  }
}
