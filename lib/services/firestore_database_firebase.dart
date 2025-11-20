import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:past_question_paper_v1/model/user.dart';
import 'package:past_question_paper_v1/model/question.dart';

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

  /// Deletes a user's data from Firestore
  /// This removes the user document and related data
  Future<void> deleteUserData(String userId) async {
    try {
      // Delete the user document
      await _firestore.collection('users').doc(userId).delete();

      // TODO: Delete other user-related data if needed
      // (e.g., test sessions, progress, etc.)
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
      final doc = await _firestore
          .collection('questions')
          .doc(questionId)
          .get();
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
      final subjects = snapshot.docs
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
      final papers = snapshot.docs
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
      final topics = snapshot.docs
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
      final grades = snapshot.docs
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
        'submissions': answers, // Use 'submissions' key for new format
        'subject': subject,
        'paper': paper,
      });

      final responseData = result.data;
      if (responseData is Map) {
        // Handle new response format with statistics
        if (responseData.containsKey('statistics')) {
          final statistics = responseData['statistics'] as Map;
          return {
            'score': (statistics['marksAwarded'] as num?)?.toInt() ?? 0,
            'totalMarks': (statistics['totalMarks'] as num?)?.toInt() ?? 0,
            'percentage': (statistics['percentage'] as num?)?.toDouble() ?? 0.0,
            'grade': statistics['grade']?.toString() ?? 'F',
            'results': responseData['results'] ?? [],
            'gradedAt': responseData['gradedAt']?.toString() ?? '',
          };
        }
        // Fallback to legacy format
        return Map<String, dynamic>.from(responseData);
      }

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
      print(
        '🔥 FirestoreDatabaseService.getUserTestResults: Fetching for userId: $userId',
      );

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('testResults')
          .orderBy('testDate', descending: true)
          .get();

      print(
        '📊 FirestoreDatabaseService: Found ${snapshot.docs.length} documents',
      );

      if (snapshot.docs.isEmpty) {
        print('⚠️ No testResults found at path: users/$userId/testResults');
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final testDateRaw = data['testDate'];
        final savedAtRaw = data['savedAt'];

        DateTime? testDate;
        if (testDateRaw is Timestamp) {
          testDate = testDateRaw.toDate();
        } else if (testDateRaw is DateTime) {
          testDate = testDateRaw;
        }

        DateTime? savedAt;
        if (savedAtRaw is Timestamp) {
          savedAt = savedAtRaw.toDate();
        } else if (savedAtRaw is DateTime) {
          savedAt = savedAtRaw;
        }

        return {
          'id': doc.id,
          ...data,
          'testDate': testDate,
          'savedAt': savedAt,
        };
      }).toList();
    } catch (e) {
      print('❌ Error in getUserTestResults: $e');
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

  // ===== Option 3: Parent-Child Question Methods =====

  /// Fetches a parent question by ID
  /// Used when displaying questions that reference a parent
  Future<Question?> getParentQuestion(String parentId) async {
    try {
      final doc = await _firestore.collection('questions').doc(parentId).get();

      if (!doc.exists) {
        print('⚠️ Parent question not found: $parentId');
        return null;
      }

      return Question.fromFirestore(doc);
    } catch (e) {
      print('❌ Error fetching parent question $parentId: $e');
      rethrow;
    }
  }

  /// Fetches all child questions of a parent question
  /// Returns list of questions that have parentQuestionId == parentId
  Future<List<Question>> getChildQuestions(String parentId) async {
    try {
      // First get the parent to retrieve childQuestionIds
      final parent = await getParentQuestion(parentId);

      if (parent == null) {
        print('⚠️ Parent question not found, cannot fetch children');
        return [];
      }

      // Get childQuestionIds from parent's data
      final parentDoc = await _firestore
          .collection('questions')
          .doc(parentId)
          .get();

      final parentData = parentDoc.data();
      if (parentData == null || !parentData.containsKey('childQuestionIds')) {
        print('⚠️ Parent question has no childQuestionIds field');
        return [];
      }

      final childIds = List<String>.from(parentData['childQuestionIds']);

      if (childIds.isEmpty) {
        return [];
      }

      // Fetch children in batches (Firestore 'in' query limit is 10)
      final List<Question> children = [];

      for (int i = 0; i < childIds.length; i += 10) {
        final batch = childIds.skip(i).take(10).toList();

        final snapshot = await _firestore
            .collection('questions')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        children.addAll(
          snapshot.docs.map((doc) => Question.fromFirestore(doc)).toList(),
        );
      }

      // Sort by question number if available
      children.sort((a, b) {
        final aNum = a.pqpData?.questionNumber ?? '';
        final bNum = b.pqpData?.questionNumber ?? '';
        return aNum.compareTo(bNum);
      });

      return children;
    } catch (e) {
      print('❌ Error fetching child questions for parent $parentId: $e');
      rethrow;
    }
  }

  /// Fetches complete question family (parent + all children)
  /// Returns a map with parent question and list of child questions
  Future<Map<String, dynamic>> getQuestionFamily(String parentId) async {
    try {
      final parent = await getParentQuestion(parentId);

      if (parent == null) {
        throw Exception('Parent question not found: $parentId');
      }

      final children = await getChildQuestions(parentId);

      // Calculate total marks from parent data or sum of children
      int totalMarks = parent.marks;
      if (totalMarks == 0 && children.isNotEmpty) {
        totalMarks = children.fold(0, (sum, child) => sum + child.marks);
      }

      return {
        'parent': parent,
        'children': children,
        'imageUrl': parent.imageUrl,
        'totalMarks': totalMarks,
        'childCount': children.length,
      };
    } catch (e) {
      print('❌ Error fetching question family for parent $parentId: $e');
      rethrow;
    }
  }

  /// Enriches a question with its parent context
  /// Called when displaying a child question to show parent information
  Future<Question> enrichQuestionWithParent(Question question) async {
    if (!question.hasParent) {
      return question; // No parent, return as-is
    }

    try {
      // Check if already has parent context from backend
      if (question.parentContext != null) {
        return question; // Already enriched by Cloud Function
      }

      // Fetch parent and add context
      final parent = await getParentQuestion(question.parentQuestionId!);

      if (parent == null) {
        print('⚠️ Could not enrich question ${question.id} - parent not found');
        return question;
      }

      // Create enriched parent context
      final parentContextMap = {
        'id': parent.id,
        'questionText': parent.questionText,
        'imageUrl': parent.imageUrl,
        'pqpData': parent.pqpData != null
            ? {'questionNumber': parent.pqpData!.questionNumber}
            : null,
        'marks': parent.marks,
      };

      // Return new question instance with parent context
      return Question(
        id: question.id,
        subject: question.subject,
        paper: question.paper,
        grade: question.grade,
        topic: question.topic,
        cognitiveLevel: question.cognitiveLevel,
        marks: question.marks,
        year: question.year,
        season: question.season,
        availableInModes: question.availableInModes,
        pqpData: question.pqpData,
        sprintData: question.sprintData,
        parentQuestionId: question.parentQuestionId,
        usesParentImage: question.usesParentImage,
        parentContext: parentContextMap, // Add enriched context
        format: question.format,
        questionText: question.questionText,
        imageUrl: question.imageUrl,
        options: question.options,
        optionImages: question.optionImages,
        correctOrder: question.correctOrder,
        correctAnswer: question.correctAnswer,
        explanation: question.explanation,
        points: question.points,
        timeAllocation: question.timeAllocation,
        dragItems: question.dragItems,
        dragTargets: question.dragTargets,
      );
    } catch (e) {
      print('❌ Error enriching question with parent: $e');
      return question; // Return original on error
    }
  }
}
