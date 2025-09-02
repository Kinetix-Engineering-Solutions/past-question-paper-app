import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/services/auth_service_firebase.dart';
import 'package:past_question_paper_v1/services/firestore_database_firebase.dart';
import 'package:past_question_paper_v1/repositories/user_repository.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthServiceFirebase>((ref) {
  final service = AuthServiceFirebase();
  return service;
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
