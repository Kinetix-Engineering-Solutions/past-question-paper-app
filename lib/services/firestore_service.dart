import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:past_question_paper_stem/models/question.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get a list of all subjects
  Future<List<String>> getSubjects() async {
    QuerySnapshot snapshot = await _firestore.collection('subjects').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Get exam types for a subject
  Future<List<String>> getExamTypes(String subjectId) async {
    QuerySnapshot snapshot =
        await _firestore
            .collection('subjects')
            .doc(subjectId)
            .collection('examtype')
            .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Get topics for a specific exam type
  Future<List<String>> getTopics(String subjectId, String examTypeId) async {
    QuerySnapshot snapshot =
        await _firestore
            .collection('subjects')
            .doc(subjectId)
            .collection('examtype')
            .doc(examTypeId)
            .collection('topics')
            .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Get all questions for a specific topic
  Future<List<Question>> getQuestions(
    String subjectId,
    String examTypeId,
    String topicId,
  ) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('subjects')
              .doc(subjectId)
              .collection('examtype')
              .doc(examTypeId)
              .collection('topics')
              .doc(topicId)
              .collection('questions')
              .get();

      // Create question objects from Firestore documents
      List<Question> questions =
          snapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();

      // Convert gs:// URLs to HTTP URLs
      List<Question> processedQuestions = [];
      for (Question question in questions) {
        // Use the new withHttpUrls method to convert gs:// URLs
        final processedQuestion = await question.withHttpUrls();
        processedQuestions.add(processedQuestion);
      }

      return processedQuestions;
    } catch (e) {
      print('Error getting questions: $e');
      rethrow;
    }
  }

  // Get a specific question
  Future<Question?> getQuestion(
    String subjectId,
    String examTypeId,
    String topicId,
    String questionId,
  ) async {
    try {
      DocumentSnapshot doc =
          await _firestore
              .collection('subjects')
              .doc(subjectId)
              .collection('examtype')
              .doc(examTypeId)
              .collection('topics')
              .doc(topicId)
              .collection('questions')
              .doc(questionId)
              .get();

      if (doc.exists) {
        Question question = Question.fromFirestore(doc);
        // Convert gs:// URLs to HTTP URLs
        return await question.withHttpUrls();
      }
      return null;
    } catch (e) {
      print('Error getting question: $e');
      rethrow;
    }
  }
}
