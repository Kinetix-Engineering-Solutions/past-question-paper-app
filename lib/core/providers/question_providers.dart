import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/models/question.dart';
import 'package:past_question_paper_stem/services/firestore_service.dart';

// Provider to get the FirestoreService instance
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Provider to get all subjects
final subjectsProvider = FutureProvider<List<String>>((ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getSubjects();
});

// Provider for exam types based on selected subject
final examTypesProvider = FutureProvider.family<List<String>, String>((
  ref,
  subjectId,
) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getExamTypes(subjectId);
});

// Provider for topics based on selected subject and exam type
final topicsProvider = FutureProvider.family<
  List<String>,
  ({String subjectId, String examTypeId})
>((ref, params) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getTopics(params.subjectId, params.examTypeId);
});

// Provider for questions based on selected subject, exam type, and topic
final questionsProvider = FutureProvider.family<
  List<Question>,
  ({String subjectId, String examTypeId, String topicId})
>((ref, params) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getQuestions(
    params.subjectId,
    params.examTypeId,
    params.topicId,
  );
});

// Provider for a single question
final questionProvider = FutureProvider.family<
  Question?,
  ({String subjectId, String examTypeId, String topicId, String questionId})
>((ref, params) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getQuestion(
    params.subjectId,
    params.examTypeId,
    params.topicId,
    params.questionId,
  );
});

// State notifier to track user's progress
class UserProgressNotifier extends StateNotifier<Map<String, dynamic>> {
  UserProgressNotifier()
    : super({
        'totalAttempted': 0,
        'totalCorrect': 0,
        'questionStats': <String, dynamic>{},
      });
  void recordAttempt(String questionId, bool isCorrect) {
    final questionStats = Map<String, dynamic>.from(
      state['questionStats'] as Map<String, dynamic>,
    );

    questionStats[questionId] = {
      'attempted': true,
      'correct': isCorrect,
      'lastAttempt': DateTime.now().toIso8601String(),
    };

    state = {
      'totalAttempted': (state['totalAttempted'] as int) + 1,
      'totalCorrect': (state['totalCorrect'] as int) + (isCorrect ? 1 : 0),
      'questionStats': questionStats,
    };
  }

  bool hasAttempted(String questionId) {
    final questionStats = state['questionStats'] as Map<String, dynamic>;
    return questionStats.containsKey(questionId) &&
        (questionStats[questionId] as Map<String, dynamic>)['attempted'] ==
            true;
  }

  bool wasCorrect(String questionId) {
    final questionStats = state['questionStats'] as Map<String, dynamic>;
    if (!questionStats.containsKey(questionId)) return false;
    return (questionStats[questionId] as Map<String, dynamic>)['correct'] ==
        true;
  }

  double get overallScore {
    final totalAttempted = state['totalAttempted'] as int;
    if (totalAttempted == 0) return 0.0;
    return (state['totalCorrect'] as int) / totalAttempted;
  }
}

// Provider for user progress
final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, Map<String, dynamic>>((ref) {
      return UserProgressNotifier();
    });
