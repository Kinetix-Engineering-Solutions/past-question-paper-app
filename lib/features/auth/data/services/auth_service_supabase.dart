import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:past_question_paper_v1/features/auth/data/services/iauthservice.dart';
import 'package:past_question_paper_v1/features/profile/domain/entities/user.dart';

class AuthServiceSupabase implements IAuthService {
  final sb.SupabaseClient _supabase = sb.Supabase.instance.client;

  @override
  Stream<AppUser?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      return user != null ? AppUser.fromSupabase(user) : null;
    });
  }

  @override
  AppUser? get currentUser {
    final user = _supabase.auth.currentUser;
    return user != null ? AppUser.fromSupabase(user) : null;
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    await _supabase.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> deleteAccount() async {
    // Supabase doesn't have a direct client-side delete account for the current user 
    // without administrative privileges or a custom Edge Function.
    // For now, we sign out.
    await signOut();
  }

  @override
  Future<void> reauthenticateAndDelete({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
    await deleteAccount();
  }

  @override
  Future<void> sendSignInLinkToEmail(String email) async {
    await _supabase.auth.signInWithOtp(email: email);
  }

  @override
  Future<void> sendVerificationEmail() async {
    // Supabase sends verification emails automatically on sign up if configured.
  }

  @override
  Future<dynamic> signInWithEmailLink(String email, String emailLink) async {
    // Supabase handles this via deep links and onAuthStateChange
    return null;
  }

  @override
  bool isSignInWithEmailLink(String emailLink) {
    return emailLink.contains('type=magiclink') || emailLink.contains('type=signup');
  }

  @override
  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(sb.OAuthProvider.google);
  }
}
