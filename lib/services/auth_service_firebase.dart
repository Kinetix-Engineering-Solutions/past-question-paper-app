import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:past_question_paper_stem/model/user.dart';
import 'package:past_question_paper_stem/services/firestore_database_firebase.dart';
import 'package:past_question_paper_stem/services/iauthservice.dart';
import 'package:past_question_paper_stem/Exceptions/auth_exception.dart';

class AuthServiceFirebase implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreDatabaseService _database = FirestoreDatabaseService();
  static const String _emailForSignInKey = 'email_for_link_sign_in';

  // Configure Firebase ActionCodeSettings for email link sign-in
  final ActionCodeSettings actionCodeSettings = ActionCodeSettings(
    url: 'https://vibe-code-4c59f.firebaseapp.com',
    handleCodeInApp: true,
    //iOSBundleId: 'com.example.ios',
    androidPackageName: 'com.example.past_question_paper_stem',
    androidInstallApp: true,
    androidMinimumVersion: '12',
  );

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
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    }
  }

  /// Sign up with email and password

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
        throw AuthException(
          'Failed to create user profile',
          code: 'user-creation-failed',
        );
      }

      // Save the user to Firestore
      await _database.saveUser(appUser);

      return result;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Sends a password reset email to the user
  /// This method is used when the user forgets their password
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    }
  }

  /// Sends a sign-in link to the user's email
  @override
  Future<void> sendSignInLinkToEmail(String email) async {
    try {
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
      // Save the email locally to use it for sign-in completion
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_emailForSignInKey, email);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    }
  }

  /// Completes the sign-in process with the received email link
  @override
  Future<UserCredential> signInWithEmailLink(
    String email,
    String emailLink,
  ) async {
    try {
      final UserCredential result = await _auth.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );

      // If this is a new user, create their profile in Firestore
      if (result.additionalUserInfo?.isNewUser ?? false) {
        final appUser = _userFromFirebaseUser(result.user);
        if (appUser == null) {
          throw AuthException(
            'Failed to create user profile',
            code: 'user-creation-failed',
          );
        }
        await _database.saveUser(appUser);
      }

      // Clear the saved email after successful sign-in
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_emailForSignInKey);

      return result;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuth(e);
    }
  }

  /// Checks if the given link is a valid email sign-in link
  @override
  bool isSignInWithEmailLink(String emailLink) {
    return _auth.isSignInWithEmailLink(emailLink);
  }
}
