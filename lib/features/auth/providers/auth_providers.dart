import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/features/profile/domain/entities/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:past_question_paper_v1/features/auth/data/services/auth_service_supabase.dart';
import 'package:past_question_paper_v1/features/auth/data/services/iauthservice.dart';
import 'package:past_question_paper_v1/core/shared/services/firestore_database_firebase.dart';
import 'package:past_question_paper_v1/features/profile/data/repositories/user_repository.dart';

// Auth Service Provider
final authServiceProvider = Provider<IAuthService>((ref) {
  return AuthServiceSupabase();
});

// Firestore Database Service Provider
final firestoreDatabaseProvider = Provider<FirestoreDatabaseService>((ref) {
  return FirestoreDatabaseService();
});

// User Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
    authService: ref.read(authServiceProvider),
    database: ref.read(firestoreDatabaseProvider),
  );
});

// Auth State Provider - Streams the current auth state with Firestore profile data
final authStateProvider = StreamProvider((ref) {
  return ref.watch(userRepositoryProvider).userAuthStateWithProfile;
});

// Current User Provider
final currentUserProvider = Provider((ref) {
  return ref.watch(userRepositoryProvider).currentUser;
});
