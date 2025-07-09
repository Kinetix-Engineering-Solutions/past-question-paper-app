import 'package:firebase_auth/firebase_auth.dart';
import 'package:past_question_paper_stem/model/user.dart';
import 'package:past_question_paper_stem/services/data%20source/firestore_database_firebase.dart';
import 'package:past_question_paper_stem/services/data%20source/iauthservice.dart';

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
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found after sign in',
        );
      }
      return user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<AppUser> signUp(String email, String password) async {
    try {
      await _authService.signUpWithEmailAndPassword(email, password);
      final user = _authService.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found after sign up',
        );
      }
      return user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  AppUser? get currentUser => _authService.currentUser;

  Future<AppUser?> getUserFromFirestore(String userId) async {
    return _database.getUser(userId);
  }
}
