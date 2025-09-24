import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

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

  /// Load test questions from local JSON file (for testing purposes)
  ///
  /// This method loads questions from test_questions_firestore.json
  /// Useful for testing new question formats before uploading to Firestore
  Future<List<Question>> loadLocalTestQuestions() async {
    try {
      print(
        'Loading questions from local test_questions_firestore.json',
      ); // Debug

      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString(
        'test_questions_firestore.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      // Convert JSON to Question objects
      final List<Question> questions = [];

      for (final questionData in jsonList) {
        try {
          // Convert the JSON map to match Question.fromMap expected format
          final Map<String, dynamic> questionMap = {
            'id': questionData['topicId'] ?? 'local_test_${questions.length}',
            'questionText': questionData['questionText'] ?? '',
            'questionType': questionData['questionType'] ?? '',
            'format':
                questionData['questionType'] ??
                '', // Use questionType as format
            'options': questionData['options'] ?? [],
            'correctAnswer': _extractCorrectAnswer(questionData),
            'correctOrder': questionData['correctOrder'] ?? [],
            'explanation': questionData['explanation'] ?? '',
            'marks': questionData['points'] ?? 1, // Use 'points' as 'marks'
            'timeAllocation': questionData['timeAllocation'] ?? 60,
            'dragItems': questionData['dragItems'],
            'dragTargets':
                questionData['dropTargets'], // Map dropTargets to dragTargets
            'imageUrl': null,
            'optionImages': null,
            // Enhanced Short Answer fields
            'answerVariations': questionData['answerVariations'],
            'caseSensitive': questionData['caseSensitive'] ?? false,
            'hints': questionData['hints'],
            'workingSteps': questionData['workingSteps'], 
            'answerType': questionData['answerType'],
            'tolerance': questionData['tolerance'],
            'units': questionData['units'],
            'showWorking': questionData['showWorking'] ?? true,
          };

          final question = Question.fromMap(questionMap);
          questions.add(question);
          print(
            '✅ Successfully loaded ${question.format} question: ${question.questionText}',
          );
        } catch (e) {
          print('❌ Error loading question: $e');
          print('Question data: $questionData');
        }
      }

      print('📊 Loaded ${questions.length} questions from local JSON');
      return questions;
    } catch (e) {
      print('❌ Error loading local test questions: $e');
      throw Exception('Failed to load local test questions: $e');
    }
  }

  /// Load PQP mode questions from local JSON file
  ///
  /// This method loads only questions that support PQP mode and filters out
  /// questions that don't have pqpData. It processes question chains and dependencies.
  Future<List<Question>> loadPQPQuestions({
    String? paper,
    String? season,
    int? year,
    String? chainId,
  }) async {
    try {
      print('Loading PQP mode questions from local test_questions_firestore.json');

      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString(
        'test_questions_firestore.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      // Filter and convert JSON to Question objects for PQP mode
      final List<Question> pqpQuestions = [];

      for (final questionData in jsonList) {
        try {
          // Check if question supports PQP mode
          final availableInModes = questionData['availableInModes'] as List<dynamic>?;
          if (availableInModes == null || !availableInModes.contains('pqp')) {
            print('⏭️ Skipping non-PQP question: ${questionData['questionId']}');
            continue;
          }

          // Check if question has pqpData
          if (questionData['pqpData'] == null) {
            print('⏭️ Skipping PQP question without pqpData: ${questionData['questionId']}');
            continue;
          }

          // Apply filters if specified
          final pqpData = questionData['pqpData'] as Map<String, dynamic>;
          if (paper != null && pqpData['paper'] != paper) continue;
          if (season != null && pqpData['season'] != season) continue;
          if (year != null && pqpData['year'] != year) continue;
          if (chainId != null && pqpData['chainId'] != chainId) continue;

          // Convert the JSON map to match Question.fromMap expected format
          final Map<String, dynamic> questionMap = {
            'id': questionData['questionId'] ?? 'pqp_${pqpQuestions.length}',
            'questionText': pqpData['questionText'] ?? questionData['questionText'] ?? '',
            'questionType': questionData['questionType'] ?? 'short_answer',
            'format': questionData['format'] ?? questionData['questionType'] ?? 'short_answer',
            'options': questionData['options'] ?? [],
            'correctAnswer': _extractCorrectAnswer(questionData),
            'correctOrder': questionData['correctOrder'] ?? [],
            'explanation': questionData['explanation'] ?? '',
            'marks': pqpData['marks'] ?? questionData['points'] ?? 1,
            'timeAllocation': questionData['timeAllocation'] ?? 60,
            'dragItems': questionData['dragItems'],
            'dragTargets': questionData['dropTargets'],
            'imageUrl': null,
            'optionImages': null,
            // Enhanced Short Answer fields
            'answerVariations': questionData['answerVariations'],
            'caseSensitive': questionData['caseSensitive'] ?? false,
            'hints': questionData['hints'],
            'workingSteps': questionData['workingSteps'],
            'answerType': questionData['answerType'],
            'tolerance': questionData['tolerance'],
            'units': questionData['units'],
            'showWorking': questionData['showWorking'] ?? true,
            // Dual mode support
            'availableInModes': availableInModes,
            'pqpData': pqpData,
            'sprintData': questionData['sprintData'],
            // Metadata from commonData or defaults
            'subject': questionData['subject'] ?? 'mathematics',
            'paper': pqpData['paper'] ?? 'p1',
            'grade': questionData['grade'] ?? 12,
            'topic': questionData['topicId'] ?? questionData['topic'] ?? 'general',
            'cognitiveLevel': questionData['cognitiveLevel'] ?? 'Level 1',
            'year': pqpData['year'] ?? 2023,
            'season': pqpData['season'] ?? 'November',
          };

          final question = Question.fromMap(questionMap);
          pqpQuestions.add(question);
          print('✅ Loaded PQP question: ${question.getPQPQuestionText()}');
        } catch (e) {
          print('❌ Error loading PQP question: $e');
          print('Question data: $questionData');
        }
      }

      // Sort questions by dependencies and question number for proper chain order
      pqpQuestions.sort((a, b) {
        // First sort by chain ID
        final chainComparison = (a.chainId ?? '').compareTo(b.chainId ?? '');
        if (chainComparison != 0) return chainComparison;

        // Then sort by question number within the same chain
        final aNum = a.pqpData?.questionNumber ?? '0';
        final bNum = b.pqpData?.questionNumber ?? '0';
        return aNum.compareTo(bNum);
      });

      print('📊 Loaded ${pqpQuestions.length} PQP mode questions');

      // Validate question chains and dependencies
      _validatePQPQuestionChains(pqpQuestions);

      return pqpQuestions;
    } catch (e) {
      print('❌ Error loading PQP questions: $e');
      throw Exception('Failed to load PQP questions: $e');
    }
  }

  /// Load Sprint mode questions from local JSON file
  ///
  /// This method loads only questions that support Sprint mode and provides
  /// standalone context for each question.
  Future<List<Question>> loadSprintQuestions({
    String? difficulty,
    List<String>? tags,
  }) async {
    try {
      print('Loading Sprint mode questions from local test_questions_firestore.json');

      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString(
        'test_questions_firestore.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      // Filter and convert JSON to Question objects for Sprint mode
      final List<Question> sprintQuestions = [];

      for (final questionData in jsonList) {
        try {
          // Check if question supports Sprint mode
          final availableInModes = questionData['availableInModes'] as List<dynamic>?;
          if (availableInModes == null || !availableInModes.contains('sprint')) {
            print('⏭️ Skipping non-Sprint question: ${questionData['questionId']}');
            continue;
          }

          // Check if question has sprintData
          if (questionData['sprintData'] == null) {
            print('⏭️ Skipping Sprint question without sprintData: ${questionData['questionId']}');
            continue;
          }

          // Apply filters if specified
          final sprintData = questionData['sprintData'] as Map<String, dynamic>;
          if (difficulty != null && sprintData['difficulty'] != difficulty) continue;
          if (tags != null) {
            final questionTags = sprintData['tags'] as List<dynamic>?;
            if (questionTags == null || !tags.any((tag) => questionTags.contains(tag))) {
              continue;
            }
          }

          // Convert the JSON map to match Question.fromMap expected format
          final Map<String, dynamic> questionMap = {
            'id': questionData['questionId'] ?? 'sprint_${sprintQuestions.length}',
            'questionText': sprintData['questionText'] ?? questionData['questionText'] ?? '',
            'questionType': questionData['questionType'] ?? 'short_answer',
            'format': questionData['format'] ?? questionData['questionType'] ?? 'short_answer',
            'options': questionData['options'] ?? [],
            'correctAnswer': _extractCorrectAnswer(questionData),
            'correctOrder': questionData['correctOrder'] ?? [],
            'explanation': questionData['explanation'] ?? '',
            'marks': sprintData['marks'] ?? questionData['points'] ?? 1,
            'timeAllocation': sprintData['estimatedTime'] != null
                ? (sprintData['estimatedTime'] as int) * 60  // Convert minutes to seconds
                : questionData['timeAllocation'] ?? 60,
            'dragItems': questionData['dragItems'],
            'dragTargets': questionData['dropTargets'],
            'imageUrl': null,
            'optionImages': null,
            // Enhanced Short Answer fields
            'answerVariations': questionData['answerVariations'],
            'caseSensitive': questionData['caseSensitive'] ?? false,
            'hints': questionData['hints'],
            'workingSteps': questionData['workingSteps'],
            'answerType': questionData['answerType'],
            'tolerance': questionData['tolerance'],
            'units': questionData['units'],
            'showWorking': questionData['showWorking'] ?? true,
            // Dual mode support
            'availableInModes': availableInModes,
            'pqpData': questionData['pqpData'],
            'sprintData': sprintData,
            // Metadata from commonData or defaults
            'subject': questionData['subject'] ?? 'mathematics',
            'paper': 'sprint', // Mark as sprint mode
            'grade': questionData['grade'] ?? 12,
            'topic': questionData['topicId'] ?? questionData['topic'] ?? 'general',
            'cognitiveLevel': questionData['cognitiveLevel'] ?? 'Level 1',
            'year': 2024, // Current year for sprint mode
            'season': 'Sprint', // Mark as sprint season
          };

          final question = Question.fromMap(questionMap);
          sprintQuestions.add(question);
          print('✅ Loaded Sprint question: ${question.getSprintQuestionText()}');
        } catch (e) {
          print('❌ Error loading Sprint question: $e');
          print('Question data: $questionData');
        }
      }

      print('📊 Loaded ${sprintQuestions.length} Sprint mode questions');

      return sprintQuestions;
    } catch (e) {
      print('❌ Error loading Sprint questions: $e');
      throw Exception('Failed to load Sprint questions: $e');
    }
  }

  /// Validate PQP question chains and dependencies
  void _validatePQPQuestionChains(List<Question> questions) {
    print('🔍 Validating PQP question chains...');

    for (final question in questions) {
      if (question.dependencies.isNotEmpty) {
        for (final dependency in question.dependencies) {
          final dependentQuestion = questions.firstWhere(
            (q) => q.id == dependency,
            orElse: () => questions.first, // Fallback to avoid errors
          );

          if (dependentQuestion.id != dependency) {
            print('⚠️ Warning: Question ${question.id} depends on ${dependency}, but dependency not found');
          } else {
            print('✅ Dependency validated: ${question.id} -> ${dependency}');
          }
        }
      }
    }
  }

  /// Extract correct answer from question data based on question type
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
