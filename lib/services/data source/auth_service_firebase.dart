import 'package:firebase_auth/firebase_auth.dart';
import 'package:past_question_paper_stem/model/user.dart';
import 'package:past_question_paper_stem/services/data%20source/firestore_database_firebase.dart';
import 'package:past_question_paper_stem/services/data%20source/iauthservice.dart';

class AuthServiceFirebase implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreDatabaseService _database = FirestoreDatabaseService();

  // Convert Firebase User to AppUser
  AppUser? _userFromFirebaseUser(User? user) {
    if (user == null) return null;
    return AppUser(id: user.uid, email: user.email ?? '');
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  /// Get the current user from Firebase Auth
  @override
  AppUser? get currentUser => _userFromFirebaseUser(_auth.currentUser);

  @override
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Create the user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create AppUser instance
      final appUser = _userFromFirebaseUser(result.user);
      if (appUser == null) {
        throw FirebaseAuthException(
          code: 'user-creation-failed',
          message: 'Failed to create user profile',
        );
      }

      // Save the user to Firestore
      await _database.saveUser(appUser);

      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
