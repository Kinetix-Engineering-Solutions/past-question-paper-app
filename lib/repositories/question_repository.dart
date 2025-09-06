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
      final Map<String, dynamic> responseData =
          result.data as Map<String, dynamic>;
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
      if (e.code == 'unauthenticated') {
        throw Exception(
          'Authentication failed. Please log out and log back in.',
        );
      }
      throw Exception('Failed to generate test. Please try again.');
    } catch (e) {
      // Handle any other errors
      print('An unexpected error occurred while generating test: $e');
      throw Exception('An unexpected error occurred.');
    }
  }

  /// Submits user's answers to the 'gradeTest' Cloud Function for marking.
  ///
  /// Returns the complete grading results including statistics and detailed breakdown.
  Future<Map<String, dynamic>> gradeTest({
    required Map<String, dynamic> userAnswers,
    required String subject,
    String? paper, // Paper might be optional for some test modes
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
}
