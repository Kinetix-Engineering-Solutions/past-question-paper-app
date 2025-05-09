import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:past_question_paper_stem/services/storage_service.dart';

class Question {
  final String id;
  final String questionType;
  final String questionText;
  final String? questionImageUrl; // New field for question image
  final List<String> options;
  final List<String>? optionImageUrls; // New field for option images
  final List<int> correctOrder; // For drag-and-drop questions
  final List<String> correctAnswer;
  final String explanation;

  Question({
    required this.id,
    required this.questionType,
    required this.questionText,
    this.questionImageUrl, // Optional image URL for the question
    required this.options,
    this.optionImageUrls, // Optional image URLs for options
    required this.correctOrder,
    required this.correctAnswer,
    required this.explanation,
  });

  factory Question.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Question(
      id: doc.id,
      questionType: data['questionType'] ?? '',
      questionText: data['questionText'] ?? '',
      questionImageUrl: data['questionImageUrl'],
      options: List<String>.from(data['options'] ?? []),
      optionImageUrls:
          data['optionImageUrls'] != null
              ? List<String>.from(data['optionImageUrls'])
              : null,
      correctOrder: List<int>.from(data['correctOrder'] ?? []),
      correctAnswer: List<String>.from(data['correctAnswer'] ?? []),
      explanation: data['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'questionType': questionType,
      'questionText': questionText,
      'options': options,
      'correctOrder': correctOrder,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };

    // Add optional fields only if they exist
    if (questionImageUrl != null) {
      map['questionImageUrl'] = questionImageUrl;
    }
    if (optionImageUrls != null) {
      map['optionImageUrls'] = optionImageUrls;
    }

    return map;
  }

  // Check if this question has image-based options
  bool get hasImageOptions =>
      optionImageUrls != null && optionImageUrls!.isNotEmpty;

  // Check if this question has an image
  bool get hasQuestionImage =>
      questionImageUrl != null && questionImageUrl!.isNotEmpty;

  // Get HTTP download URLs for all images (converting gs:// URLs if needed)
  Future<Question> withHttpUrls() async {
    final storageService = StorageService();
    String? httpQuestionImageUrl;
    List<String>? httpOptionImageUrls;

    try {
      // Convert question image URL if it exists
      if (hasQuestionImage) {
        httpQuestionImageUrl = await storageService.getDownloadUrl(
          questionImageUrl!,
        );
      }

      // Convert option image URLs if they exist
      if (hasImageOptions) {
        httpOptionImageUrls = [];
        for (String url in optionImageUrls!) {
          final httpUrl = await storageService.getDownloadUrl(url);
          httpOptionImageUrls.add(httpUrl);
        }
      }

      // Return a new Question instance with HTTP URLs
      return Question(
        id: id,
        questionType: questionType,
        questionText: questionText,
        questionImageUrl: httpQuestionImageUrl,
        options: options,
        optionImageUrls: httpOptionImageUrls,
        correctOrder: correctOrder,
        correctAnswer: correctAnswer,
        explanation: explanation,
      );
    } catch (e) {
      print('Error converting URLs: $e');
      // Return the original question if conversion fails
      return this;
    }
  }
}
