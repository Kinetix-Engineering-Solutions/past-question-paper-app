import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/app_user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Create new user
  Future<void> createUser(AppUser user) async {
    await _firestore.collection(_collection).doc(user.id).set(user.toJson());
  }

  // Get user by ID
  Future<AppUser?> getUserById(String userId) async {
    final doc = await _firestore.collection(_collection).doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return AppUser.fromJson({'id': doc.id, ...doc.data()!});
    }
    return null;
  }

  // Update user
  Future<void> updateUser(AppUser user) async {
    final userData = user.toJson();
    userData['updatedAt'] = DateTime.now().toIso8601String();
    await _firestore.collection(_collection).doc(user.id).update(userData);
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    await _firestore.collection(_collection).doc(userId).delete();
  }

  // Update specific user fields
  Future<void> updateUserFields(
    String userId,
    Map<String, dynamic> fields,
  ) async {
    fields['updatedAt'] = DateTime.now();
    await _firestore.collection(_collection).doc(userId).update(fields);
  }
}
