import 'package:past_question_paper_stem/model/user.dart';
import 'package:past_question_paper_stem/services/firestore_database_firebase.dart';
import 'package:past_question_paper_stem/services/iauthservice.dart';
import 'package:past_question_paper_stem/Exceptions/auth_exception.dart';

class UserRepository {
  final IAuthService _authService;
  final FirestoreDatabaseService _database;

  UserRepository({
    required IAuthService authService,
    FirestoreDatabaseService? database,
  }) : _authService = authService,
       _database = database ?? FirestoreDatabaseService();

  Stream<AppUser?> get userAuthState => _authService.authStateChanges;

  Future<AppUser> signIn(String email, String password) async {
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      final user = _authService.currentUser;
      if (user == null) {
        throw AuthException(
          'No user found after sign in',
          code: 'user-not-found',
        );
      }
      return user;
    } on AuthException {
      rethrow;
    }
  }

  Future<AppUser> signUp(String email, String password) async {
    try {
      await _authService.signUpWithEmailAndPassword(email, password);
      final user = _authService.currentUser;
      if (user == null) {
        throw AuthException(
          'No user found after sign up',
          code: 'user-not-found',
        );
      }
      return user;
    } on AuthException {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } on AuthException {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } on AuthException {
      rethrow;
    }
  }

  Future<AppUser> signInWithEmailLink(String email, String emailLink) async {
    try {
      await _authService.signInWithEmailLink(email, emailLink);
      final user = _authService.currentUser;
      if (user == null) {
        throw AuthException(
          'No user found after email link sign in',
          code: 'user-not-found',
        );
      }
      return user;
    } on AuthException {
      rethrow;
    }
  }

  AppUser? get currentUser => _authService.currentUser;

  Future<AppUser?> getUserFromFirestore(String userId) async {
    try {
      return await _database.getUser(userId);
    } catch (e) {
      throw AuthException(
        'Failed to fetch user profile',
        code: 'profile-fetch-error',
      );
    }
  }
}
