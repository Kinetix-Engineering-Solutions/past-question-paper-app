import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the FirebaseAuth instance used by the admin portal.
final adminFirebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Stream of authentication state changes for the admin portal.
///
/// The admin UI listens to this provider to determine whether to display the
/// login screen or the management dashboard.
final adminAuthStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(adminFirebaseAuthProvider);
  return auth.authStateChanges();
});
