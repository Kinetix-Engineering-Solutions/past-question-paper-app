import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:past_question_paper_stem/model/user.dart';
import 'package:past_question_paper_stem/model/grade.dart';
import 'package:past_question_paper_stem/model/subject.dart';

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

      final data = doc.data()!;
      return AppUser(
        id: doc.id,
        email: data['email'] as String,
        profile:
            data['profile'] != null
                ? UserProfile.fromJson(data['profile'] as Map<String, dynamic>)
                : null,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Saves user profile to Firestore
  Future<void> saveUserProfile(String userId, UserProfile profile) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profile': profile.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Updates the user document with profile information
  Future<void> updateUserWithProfile(AppUser user) async {
    try {
      final data = {
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (user.profile != null) {
        data['profile'] = user.profile!.toJson();
      }

      await _firestore
          .collection('users')
          .doc(user.id)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches all grades from Firestore
  Future<List<Grade>> getGrades() async {
    try {
      final snapshot = await _firestore.collection('grades').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Grade(
          id: doc.id,
          name: data['name'] as String? ?? '',
          level: data['level'] as int? ?? 0,
          description: data['description'] as String? ?? '',
          createdAt:
              data['createdAt'] != null
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.now(),
          updatedAt:
              data['updatedAt'] != null
                  ? (data['updatedAt'] as Timestamp).toDate()
                  : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches all subjects from Firestore
  Future<List<Subject>> getSubjects() async {
    try {
      final snapshot = await _firestore.collection('subjects').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Subject(
          id: doc.id,
          name: data['name'] as String? ?? '',
          description: data['description'] as String? ?? '',
          iconPath: data['iconPath'] as String? ?? '',
          gradeIds: List<String>.from(data['gradeIds'] ?? []),
          createdAt:
              data['createdAt'] != null
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.now(),
          updatedAt:
              data['updatedAt'] != null
                  ? (data['updatedAt'] as Timestamp).toDate()
                  : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches subjects available for a specific grade
  Future<List<Subject>> getSubjectsForGrade(String gradeId) async {
    try {
      final snapshot =
          await _firestore
              .collection('subjects')
              .where('gradeIds', arrayContains: gradeId)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Subject(
          id: doc.id,
          name: data['name'] as String? ?? '',
          description: data['description'] as String? ?? '',
          iconPath: data['iconPath'] as String? ?? '',
          gradeIds: List<String>.from(data['gradeIds'] ?? []),
          createdAt:
              data['createdAt'] != null
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.now(),
          updatedAt:
              data['updatedAt'] != null
                  ? (data['updatedAt'] as Timestamp).toDate()
                  : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
