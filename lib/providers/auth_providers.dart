import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/services/data%20source/auth_service_firebase.dart';
import 'package:past_question_paper_stem/services/data%20source/firestore_database_firebase.dart';
import 'package:past_question_paper_stem/services/data%20source/iauthservice.dart';
import 'package:past_question_paper_stem/services/user_repository.dart';

// Auth Service Provider
final authServiceProvider = Provider<IAuthService>((ref) {
  return AuthServiceFirebase();
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

// Auth State Provider - Streams the current auth state
final authStateProvider = StreamProvider((ref) {
  return ref.watch(userRepositoryProvider).userAuthState;
});

// Current User Provider
final currentUserProvider = Provider((ref) {
  return ref.watch(userRepositoryProvider).currentUser;
});
