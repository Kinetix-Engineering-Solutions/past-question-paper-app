import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:past_question_paper_stem/model/user.dart';

class FirestoreDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Saves a user to Firestore
  Future<void> saveUser(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves a user from Firestore by userId
  Future<AppUser?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;

      return AppUser(id: doc.id, email: doc.data()!['email'] as String);
    } catch (e) {
      rethrow;
    }
  }
}
