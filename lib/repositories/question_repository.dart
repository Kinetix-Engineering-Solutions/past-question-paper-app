import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:past_question_paper_stem/model/question.dart';
import 'package:past_question_paper_stem/model/question_type.dart';

class QuestionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'questions';

  /// Load all questions for a specific topic
  Future<List<Question>> getQuestionsForTopic(String topicId) async {
    try {
      print('🔍 QuestionRepository: Querying questions for topicId: $topicId');

      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('topicId', isEqualTo: topicId)
              .get();

      print(
        '🔍 QuestionRepository: Found ${querySnapshot.docs.length} documents',
      );

      if (querySnapshot.docs.isNotEmpty) {
        // Debug: Print the first document's data
        final firstDoc = querySnapshot.docs.first;
        final firstDocData = firstDoc.data();
        print('🔍 First document ID: ${firstDoc.id}');
        print('🔍 First document topicId: ${firstDocData['topicId']}');
        print(
          '🔍 First document questionType: ${firstDocData['questionType']}',
        );
      }

      return querySnapshot.docs
          .map((doc) => Question.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ QuestionRepository error: $e');
      print('Error loading questions for topic $topicId: $e');
      return [];
    }
  }

  /// Load questions of a specific type for a topic
  Future<List<Question>> getQuestionsByType(
    String topicId,
    QuestionType type,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('topicId', isEqualTo: topicId)
              .where('questionType', isEqualTo: type.value)
              .get();

      return querySnapshot.docs
          .map((doc) => Question.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error loading ${type.value} questions for topic $topicId: $e');
      return [];
    }
  }

  /// Load drag and drop questions specifically
  Future<List<Question>> getDragDropQuestionsForTopic(String topicId) async {
    return getQuestionsByType(topicId, QuestionType.dragAndDrop);
  }

  /// Load questions for practice session with mixed types
  Future<List<Question>> getQuestionsForPractice(
    String topicId, {
    int? limit,
    List<QuestionType>? types,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('topicId', isEqualTo: topicId);

      // Add type filter if specified
      if (types != null && types.isNotEmpty) {
        final typeValues = types.map((t) => t.value).toList();
        query = query.where('questionType', whereIn: typeValues);
      }

      // Add limit if specified
      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => Question.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error loading practice questions for topic $topicId: $e');
      return [];
    }
  }

  /// Save a question
  Future<bool> saveQuestion(Question question) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(question.id)
          .set(question.toMap());
      return true;
    } catch (e) {
      print('Error saving question ${question.id}: $e');
      return false;
    }
  }

  /// Update a question
  Future<bool> updateQuestion(Question question) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(question.id)
          .update(question.toMap());
      return true;
    } catch (e) {
      print('Error updating question ${question.id}: $e');
      return false;
    }
  }

  /// Delete a question
  Future<bool> deleteQuestion(String questionId) async {
    try {
      await _firestore.collection(_collection).doc(questionId).delete();
      return true;
    } catch (e) {
      print('Error deleting question $questionId: $e');
      return false;
    }
  }

  /// Get question statistics for a topic
  Future<Map<String, int>> getQuestionStats(String topicId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('topicId', isEqualTo: topicId)
              .get();

      final questions =
          querySnapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();

      Map<String, int> stats = {
        'total': questions.length,
        'multiple_choice': 0,
        'true_false': 0,
        'drag_and_drop': 0,
      };

      for (final question in questions) {
        // Count by type
        stats[question.questionType] = (stats[question.questionType] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      print('Error getting question stats for topic $topicId: $e');
      return {'total': 0};
    }
  }
}
