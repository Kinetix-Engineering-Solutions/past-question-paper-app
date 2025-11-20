import 'package:past_question_paper_v1/model/user.dart';
import 'package:past_question_paper_v1/services/firestore_database_firebase.dart';
import 'package:past_question_paper_v1/services/iauthservice.dart';
import 'package:past_question_paper_v1/Exceptions/auth_exception.dart';

class UserRepository {
  final IAuthService _authService;
  final FirestoreDatabaseService _database;

  UserRepository({
    required IAuthService authService,
    FirestoreDatabaseService? database,
  }) : _authService = authService,
       _database = database ?? FirestoreDatabaseService();

  Stream<AppUser?> get userAuthState => _authService.authStateChanges;

  /// Stream that includes Firestore profile data
  Stream<AppUser?> get userAuthStateWithProfile {
    return _authService.authStateChanges.asyncMap((user) async {
      if (user == null) return null;

      try {
        // Get the user with profile from Firestore
        final userWithProfile = await getUserFromFirestore(user.id);
        return userWithProfile ??
            user; // Fallback to basic user if Firestore fails
      } catch (e) {
        // If Firestore fails, return the basic user
        return user;
      }
    });
  }

  Future<AppUser> signIn(String email, String password) async {
    try {
      final credential = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw AuthException(
          'No user found after sign in',
          code: 'user-not-found',
        );
      }

      final user = _authService.currentUser;
      if (user == null) {
        throw AuthException(
          'Please verify your email address before signing in.',
          code: 'email-not-verified',
        );
      }

      // Get user profile from Firestore
      final userWithProfile = await getUserFromFirestore(user.id);
      return userWithProfile ?? user;
    } on AuthException {
      rethrow;
    }
  }

  Future<AppUser> signUp(String email, String password) async {
    try {
      final credential = await _authService.signUpWithEmailAndPassword(
        email,
        password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw AuthException(
          'No user found after sign up',
          code: 'user-not-found',
        );
      }

      if (!firebaseUser.emailVerified) {
        await _authService.signOut();
        throw AuthException(
          '✉️ Account Created Successfully!\n\n'
          'We\'ve sent a verification link to ${firebaseUser.email ?? 'your email'}.\n\n'
          'Please check your inbox and click the link to verify your email. '
          'Once verified, you can sign in to access the app.',
          code: 'email-not-verified',
        );
      }

      // If the email is already verified (rare), return the user immediately
      final user =
          _authService.currentUser ?? AppUser.fromFirebaseAuth(firebaseUser);
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

      // Get user profile from Firestore
      final userWithProfile = await getUserFromFirestore(user.id);
      return userWithProfile ?? user;
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

  /// Updates the current user's grade and subject preferences in Firestore.
  Future<void> updateUserPreferences({
    required int grade,
    required List<String> subjects,
  }) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw AuthException(
        'No user is currently signed in.',
        code: 'no-current-user',
      );
    }

    try {
      await _database.updateUserPreferences(user.id, grade, subjects);
    } catch (e) {
      // Rethrow as a more specific exception if needed
      throw Exception('Failed to update user preferences in the repository.');
    }
  }

  Future<List<String>> getAvailableSubjects({int? grade}) async {
    try {
      return await _database.getAvailableSubjects(grade: grade);
    } catch (e) {
      throw Exception('Failed to load available subjects.');
    }
  }

  /// Deletes the user's Firestore data
  Future<void> deleteUserData(String userId) async {
    try {
      await _database.deleteUserData(userId);
    } catch (e) {
      throw AuthException(
        'Failed to delete user data',
        code: 'delete-data-error',
      );
    }
  }

  /// Deletes the user's Firebase Auth account
  Future<void> deleteAccount() async {
    try {
      await _authService.deleteAccount();
    } on AuthException {
      rethrow;
    }
  }

  /// Re-authenticate with email & password then delete auth account.
  Future<void> reauthenticateAndDelete({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.reauthenticateAndDelete(
        email: email,
        password: password,
      );
    } on AuthException {
      rethrow;
    }
  }
}
