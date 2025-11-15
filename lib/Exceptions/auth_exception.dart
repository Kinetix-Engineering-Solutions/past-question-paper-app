import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  final String message;
  final String code;

  AuthException(this.message, {required this.code});

  /// Factory constructor to create AuthException from FirebaseAuthException
  factory AuthException.fromFirebaseAuth(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email.';
        break;
      case 'weak-password':
        message = 'The password provided is too weak.';
        break;
      case 'invalid-email':
        message = 'The email address is not valid.';
        break;
      case 'user-disabled':
        message = 'This user account has been disabled.';
        break;
      case 'operation-not-allowed':
        message = 'Operation not allowed. Please contact support.';
        break;
      case 'too-many-requests':
        message = 'Too many requests. Try again later.';
        break;
      case 'invalid-email-link':
        message = 'The email link is invalid or has expired.';
        break;
      case 'user-creation-failed':
        message = 'Failed to create user profile.';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your internet connection and try again.';
        break;
      case 'invalid-credential':
        message = 'Invalid email or password. Please try again.';
        break;
      case 'account-exists-with-different-credential':
        message = 'An account already exists with the same email but different sign-in credentials.';
        break;
      default:
        message = e.message ?? 'An error occurred. Please try again.';
    }
    return AuthException(message, code: e.code);
  }

  @override
  String toString() => 'AuthException($code): $message';
}
