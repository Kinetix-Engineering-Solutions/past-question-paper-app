import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:past_question_paper_stem/model/user.dart';
import 'package:past_question_paper_stem/model/question.dart';

class FirestoreDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

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

      return AppUser.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  /// Updates the user document with user information
  Future<void> updateUser(AppUser user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches questions directly from Firestore with optional filters
  Future<List<Question>> getQuestions({
    String? subject,
    String? paper,
    int? grade,
    String? topic,
    int? year,
    String? season,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('questions');

      // Apply filters if provided
      if (subject != null) {
        query = query.where('subject', isEqualTo: subject);
      }
      if (paper != null) {
        query = query.where('paper', isEqualTo: paper);
      }
      if (grade != null) {
        query = query.where('grade', isEqualTo: grade);
      }
      if (topic != null) {
        query = query.where('topic', isEqualTo: topic);
      }
      if (year != null) {
        query = query.where('year', isEqualTo: year);
      }
      if (season != null) {
        query = query.where('season', isEqualTo: season);
      }
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Gets a single question by ID
  Future<Question?> getQuestion(String questionId) async {
    try {
      final doc =
          await _firestore.collection('questions').doc(questionId).get();
      if (!doc.exists) return null;
      return Question.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  /// Gets available subjects from questions collection (denormalized approach)
  Future<List<String>> getAvailableSubjects({int? grade}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('questions');

      if (grade != null) {
        query = query.where('grade', isEqualTo: grade);
      }

      final snapshot = await query.get();
      final subjects =
          snapshot.docs
              .map((doc) => doc.data()['subject'] as String)
              .where((subject) => subject.isNotEmpty)
              .toSet()
              .toList();

      subjects.sort();
      return subjects;
    } catch (e) {
      rethrow;
    }
  }

  /// Gets available papers for a subject from questions collection
  Future<List<String>> getAvailablePapers({
    required String subject,
    int? grade,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('questions')
          .where('subject', isEqualTo: subject);

      if (grade != null) {
        query = query.where('grade', isEqualTo: grade);
      }

      final snapshot = await query.get();
      final papers =
          snapshot.docs
              .map((doc) => doc.data()['paper'] as String)
              .where((paper) => paper.isNotEmpty)
              .toSet()
              .toList();

      papers.sort();
      return papers;
    } catch (e) {
      rethrow;
    }
  }

  /// Gets available topics for a subject/paper from questions collection
  Future<List<String>> getAvailableTopics({
    required String subject,
    String? paper,
    int? grade,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('questions')
          .where('subject', isEqualTo: subject);

      if (paper != null) {
        query = query.where('paper', isEqualTo: paper);
      }
      if (grade != null) {
        query = query.where('grade', isEqualTo: grade);
      }

      final snapshot = await query.get();
      final topics =
          snapshot.docs
              .map((doc) => doc.data()['topic'] as String)
              .where((topic) => topic.isNotEmpty)
              .toSet()
              .toList();

      topics.sort();
      return topics;
    } catch (e) {
      rethrow;
    }
  }

  /// Gets available grades from questions collection
  Future<List<int>> getAvailableGrades({String? subject}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('questions');

      if (subject != null) {
        query = query.where('subject', isEqualTo: subject);
      }

      final snapshot = await query.get();
      final grades =
          snapshot.docs
              .map((doc) => doc.data()['grade'] as int)
              .where((grade) => grade > 0)
              .toSet()
              .toList();

      grades.sort();
      return grades;
    } catch (e) {
      rethrow;
    }
  }

  /// Calls the generateTest Cloud Function to create a test
  Future<Map<String, dynamic>> generateTest({
    required int grade,
    required String subject,
    required String paper,
    int? year,
    String? season,
    required String mode, // 'full_exam', 'quick_practice', 'topic_specific'
    String? topicId,
    int questionCount = 20,
  }) async {
    try {
      // Wait for auth state to be ready and check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('You must be logged in to generate a test.');
      }

      // Wait for the ID token to ensure it's ready for the function call
      await user.getIdToken(true); // Force refresh the token

      final callable = _functions.httpsCallable('generateTest');
      final result = await callable.call({
        'grade': grade,
        'subject': subject,
        'paper': paper,
        'year': year,
        'season': season,
        'mode': mode,
        'topicId': topicId,
        'questionCount': questionCount,
      });

      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'unauthenticated') {
        throw Exception(
          'Authentication failed. Please log out and log back in.',
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Calls the gradeTest Cloud Function to grade a completed test
  Future<Map<String, dynamic>> gradeTest({
    required Map<String, String> answers, // questionId -> userAnswer
    required String subject,
    required String paper,
  }) async {
    try {
      // Wait for auth state to be ready and check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('You must be logged in to submit test results.');
      }

      // Wait for the ID token to ensure it's ready for the function call
      await user.getIdToken(true); // Force refresh the token

      final callable = _functions.httpsCallable('gradeTest');
      final result = await callable.call({
        'answers': answers,
        'subject': subject,
        'paper': paper,
      });

      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'unauthenticated') {
        throw Exception(
          'Authentication failed. Please log out and log back in.',
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Gets user's test results from their sub-collection
  Future<List<Map<String, dynamic>>> getUserTestResults(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('testResults')
              .orderBy('testDate', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'testDate': (data['testDate'] as Timestamp?)?.toDate(),
        };
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Updates the user's document with their selected grade and subjects.
  Future<void> updateUserPreferences(
    String userId,
    int grade,
    List<String> subjects,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'grade': grade,
        'selectedSubjects': subjects,
      });
    } catch (e) {
      // Handle potential errors, e.g., permissions issues
      print('Error updating user preferences: $e');
      rethrow;
    }
  }
}
