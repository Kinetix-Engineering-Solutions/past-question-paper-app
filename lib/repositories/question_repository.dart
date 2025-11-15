import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:past_question_paper_v1/model/question.dart';

// Riverpod provider to make the repository available throughout the app
final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  // You can specify the region if your functions are not in us-central1
  final functions = FirebaseFunctions.instance;

  // For development, you might want to connect to the emulator
  // Uncomment the following line if you're using the Firebase emulator
  // functions.useFunctionsEmulator('localhost', 5001);

  return QuestionRepository(functions);
});

/// This repository is the bridge between the Flutter app and the backend Cloud Functions.
/// It does NOT contain any direct Firestore query logic.
class QuestionRepository {
  final FirebaseFunctions _functions;

  QuestionRepository(this._functions);

  /// Helper method to safely cast Map<Object?, Object?> to Map<String, dynamic>
  static Map<String, dynamic> _safeMapCast(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map) {
      final Map<String, dynamic> result = {};
      data.forEach((key, value) {
        if (key is String) {
          result[key] = value;
        }
      });
      return result;
    }
    return {};
  }

  /// Generates a test by calling the 'generateTest' Cloud Function.
  ///
  /// Takes a map of options (e.g., grade, subject, mode) and returns a list of questions.
  Future<List<Question>> generateTest(Map<String, dynamic> options) async {
    try {
      // Authentication checks temporarily disabled for testing
      // Wait for auth state to be ready and check if user is authenticated
      // final user = FirebaseAuth.instance.currentUser;
      // print('Current user: ${user?.uid}'); // Debug
      // if (user == null) {
      //   throw Exception('You must be logged in to generate a test.');
      // }

      // Wait for the ID token to ensure it's ready for the function call
      // final token = await user.getIdToken(true); // Force refresh the token
      // print('Got ID token: ${token?.isNotEmpty ?? false}'); // Debug

      // Get a reference to the Cloud Function
      final callable = _functions.httpsCallable('generateTest');

      print('Calling generateTest with options: $options'); // Debug
      print(
        'Grade: ${options['grade']} (type: ${options['grade'].runtimeType}), Subject: ${options['subject']}',
      ); // More detailed debug

      // Validate that required parameters are present
      if (options['grade'] == null || options['subject'] == null) {
        throw Exception('Grade and subject are required parameters');
      }

      // Call the function with the user's selected options
      final result = await callable.call(options);

      print('Cloud Function result type: ${result.data.runtimeType}'); // Debug
      print('Cloud Function result: ${result.data}'); // Debug

      // The new modular function returns an object with questions array
      final Map<String, dynamic> responseData = _safeMapCast(result.data);
      final List<dynamic> questionDataList =
          responseData['questions'] as List<dynamic>;

      if (questionDataList.isEmpty) {
        return [];
      }

      // Parse the raw map data into a list of Question objects with safe casting
      return questionDataList.map((data) {
        // Convert Map<Object?, Object?> to Map<String, dynamic>
        if (data is Map) {
          final Map<String, dynamic> safeMap = {};
          data.forEach((key, value) {
            if (key is String) {
              safeMap[key] = value;
            }
          });
          return Question.fromMap(safeMap);
        }
        throw Exception('Invalid question data format');
      }).toList();
    } on FirebaseFunctionsException catch (e) {
      // Handle specific cloud function errors
      print(
        'FirebaseFunctionsException: ${e.code} - ${e.message} - ${e.details}',
      );
      
      // Extract more details from the error for user-friendly messages
      final year = options['year'];
      final season = options['season'];
      final paper = options['paper'];
      final subject = options['subject'];
      final mode = options['mode'];
      
      // Provide user-friendly error messages based on error code
      switch (e.code) {
        case 'unauthenticated':
          throw Exception(
            'Authentication failed. Please log out and log back in.',
          );
        case 'not-found':
          // Question paper not available
          if (mode == 'full_exam' && year != null && season != null) {
            throw Exception(
              'The $season $year $subject $paper past paper is not yet available in our database. Please try a different year or season.',
            );
          } else if (mode == 'by_topic') {
            final topic = options['topic'];
            throw Exception(
              'No questions found for the topic "$topic". This topic may not have questions available yet.',
            );
          } else {
            throw Exception(
              'No questions found for your selection. Please try different criteria.',
            );
          }
        case 'invalid-argument':
          throw Exception(
            'Invalid selection. Please check your choices and try again.',
          );
        case 'unavailable':
        case 'deadline-exceeded':
          throw Exception(
            'Server is taking too long to respond. Please check your internet connection and try again.',
          );
        case 'resource-exhausted':
          throw Exception(
            'Too many requests. Please wait a moment and try again.',
          );
        default:
          // Check if error message contains helpful info
          if (e.message?.toLowerCase().contains('blueprint') ?? false) {
            throw Exception(
              'This past paper configuration is not yet available. Our team is working on adding more papers.',
            );
          } else if (e.message?.toLowerCase().contains('no questions') ?? false) {
            if (mode == 'full_exam' && year != null && season != null) {
              throw Exception(
                'The $season $year past paper for $subject is not available yet. Try a different year or season.',
              );
            } else {
              throw Exception(
                'No questions available for your selection. Please try different options.',
              );
            }
          }
          throw Exception(
            e.message ?? 'Failed to load questions. Please try again.',
          );
      }
    } catch (e) {
      // Handle any other errors
      print('An unexpected error occurred while generating test: $e');
      
      // Check if it's a network error
      if (e.toString().toLowerCase().contains('socket') ||
          e.toString().toLowerCase().contains('network')) {
        throw Exception(
          'Network connection problem. Please check your internet and try again.',
        );
      }
      
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Submits user's answers to the 'gradeTest' Cloud Function for marking.
  ///
  /// Returns the complete grading results including statistics and detailed breakdown.
  Future<Map<String, dynamic>> gradeTest({
    required Map<String, dynamic> userAnswers,
    required String subject,
    String? paper, // Paper might be optional for some test modes
    String mode = 'Practice',
    int? totalQuestions,
    int? durationMinutes,
    int? sessionDurationSeconds,
    Map<String, dynamic>? sessionMetadata,
    bool isPQPMode = false,
    bool isSprintMode = false,
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
        'submissions': userAnswers, // Use 'submissions' key for new format
        'subject': subject,
        'paper': paper,
        'mode': mode,
        'totalQuestions': totalQuestions,
        'durationMinutes': durationMinutes,
        'sessionDurationSeconds': sessionDurationSeconds,
        'sessionMetadata': sessionMetadata,
        'flags': {'isPQPMode': isPQPMode, 'isSprintMode': isSprintMode},
        'userId': user.uid, // Pass userId so results are saved to Firestore
      });

      // Handle the response data safely
      final responseData = result.data;
      if (responseData is Map) {
        // Return the full response data for detailed results
        return Map<String, dynamic>.from(responseData);
      } else {
        throw Exception('Invalid response format from gradeTest function');
      }
    } on FirebaseFunctionsException catch (e) {
      print('FirebaseFunctionsException: ${e.code} - ${e.message}');
      if (e.code == 'unauthenticated') {
        throw Exception(
          'Authentication failed. Please log out and log back in.',
        );
      }
      throw Exception('Failed to submit test results.');
    } catch (e) {
      print('An unexpected error occurred while grading test: $e');
      throw Exception('An unexpected error occurred.');
    }
  }

  /// Validate PQP question chains and parent relationships (Option 3)
  // ignore: unused_element
  void _validatePQPQuestionChains(List<Question> questions) {
    print('🔍 Validating PQP question parent relationships...');

    for (final question in questions) {
      if (question.hasParent) {
        final parentQuestion = questions.firstWhere(
          (q) => q.id == question.parentQuestionId,
          orElse: () => questions.first, // Fallback to avoid errors
        );

        if (parentQuestion.id != question.parentQuestionId) {
          print(
            '⚠️ Warning: Question ${question.id} has parent ${question.parentQuestionId}, but parent not found',
          );
        } else {
          print(
            '✅ Parent relationship validated: ${question.id} -> ${question.parentQuestionId}',
          );
        }
      }
    }
  }

  /// Extract correct answer from question data based on question type
  // ignore: unused_element
  String _extractCorrectAnswer(Map<String, dynamic> questionData) {
    final questionType =
        questionData['questionType']?.toString().toLowerCase() ?? '';

    switch (questionType) {
      case 'short-answer':
      case 'short_answer':
      case 'essay':
        // For text-based questions, correctAnswer is already a string
        return questionData['correctAnswer']?.toString() ?? '';

      case 'multiple-choice':
      case 'true-false':
        // For choice questions, correctAnswer is usually an array, take first element
        final correctAnswer = questionData['correctAnswer'];
        if (correctAnswer is List && correctAnswer.isNotEmpty) {
          return correctAnswer.first.toString();
        }
        return correctAnswer?.toString() ?? '';

      case 'drag-and-drop':
        // For drag-and-drop, correctAnswer might be an array of expected order
        final correctAnswer = questionData['correctAnswer'];
        if (correctAnswer is List) {
          return correctAnswer.join(',');
        }
        return correctAnswer?.toString() ?? '';

      default:
        return questionData['correctAnswer']?.toString() ?? '';
    }
  }
}
