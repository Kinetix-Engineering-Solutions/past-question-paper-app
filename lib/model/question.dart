import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:past_question_paper_stem/services/storage_service.dart';

class Question {
  final String id;
  final String questionType;
  final String questionText;
  final String? questionImage; // New field for question image
  final List<String> options; // Text options (used when no option images)
  final List<String>? optionImages; // New field for option images
  final List<int> correctOrder; // For drag-and-drop questions
  final List<String> correctAnswer;
  final String explanation;
  Question({
    required this.id,
    required this.questionType,
    required this.questionText,
    this.questionImage, // Optional image URL for the question
    this.options =
        const <String>[], // Default to empty list when using image options
    this.optionImages, // Optional image URLs for options
    required this.correctOrder,
    required this.correctAnswer,
    required this.explanation,
  });
  factory Question.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    final hasImageBasedOptions =
        data['optionImages'] != null &&
        (data['optionImages'] as List).isNotEmpty;

    return Question(
      id: doc.id,
      questionType: data['questionType'] ?? '',
      questionText: data['questionText'] ?? '',
      questionImage: data['questionImage'],
      // Load text options only if there are no option images
      options:
          hasImageBasedOptions
              ? <String>[] // Empty list when using image options
              : List<String>.from(data['options'] ?? []),
      // Load image options if present
      optionImages:
          hasImageBasedOptions ? List<String>.from(data['optionImages']) : null,
      correctOrder: List<int>.from(data['correctOrder'] ?? []),
      correctAnswer: List<String>.from(data['correctAnswer'] ?? []),
      explanation: data['explanation'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'questionType': questionType,
      'questionText': questionText,
      'correctOrder': correctOrder,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };

    // Add optional fields only if they exist
    if (questionImage != null) {
      map['questionImage'] = questionImage;
    }

    // Save option images if they exist, otherwise save text options
    if (optionImages != null && optionImages!.isNotEmpty) {
      map['optionImages'] = optionImages;
    } else {
      map['options'] = options;
    }

    return map;
  }

  // Check if this question has image-based options
  bool get hasImageOptions => optionImages != null && optionImages!.isNotEmpty;

  // Check if this question has an image
  bool get hasQuestionImage =>
      questionImage != null && questionImage!.isNotEmpty;

  // Check if should use text options (when no image options are available)
  bool get useTextOptions => !hasImageOptions && options.isNotEmpty;

  // Check if should display question image instead of text
  bool get useQuestionImage => hasQuestionImage;

  // Get the appropriate options to display
  List<String> get displayOptions {
    if (hasImageOptions) {
      return optionImages!;
    }
    return options;
  }

  // Validate drag-and-drop question
  bool get isValidDragAndDrop {
    if (questionType != 'drag-and-drop') return false;

    // For drag-and-drop, we need either image options or text options
    if (!hasImageOptions && options.isEmpty) return false;

    // Validate that correctOrder indices are valid
    final maxIndex = hasImageOptions ? optionImages!.length : options.length;
    for (int index in correctOrder) {
      if (index < 0 || index >= maxIndex) {
        return false;
      }
    }

    return true;
  }

  // Validate options length matches correctOrder length for drag-and-drop
  bool get hasValidOptionCount {
    if (questionType != 'drag-and-drop') return true;

    // Use option images count if they exist, otherwise use text options count
    final optionCount = hasImageOptions ? optionImages!.length : options.length;
    return optionCount == correctOrder.length;
  }

  // Get the count of available options (either image or text)
  int get optionCount {
    return hasImageOptions ? optionImages!.length : options.length;
  }

  // Get HTTP download URLs for all images (converting gs:// URLs if needed)
  Future<Question> withHttpUrls() async {
    final storageService = StorageService();
    String? httpQuestionImage;
    List<String>? httpOptionImages;

    try {
      // Convert question image URL if it exists
      if (hasQuestionImage) {
        httpQuestionImage = await storageService.getDownloadUrl(questionImage!);
      }

      // Convert option image URLs if they exist
      if (hasImageOptions) {
        httpOptionImages = [];
        for (String url in optionImages!) {
          final httpUrl = await storageService.getDownloadUrl(url);
          httpOptionImages.add(httpUrl);
        }
      } // Return a new Question instance with HTTP URLs
      return Question(
        id: id,
        questionType: questionType,
        questionText: questionText,
        questionImage: httpQuestionImage,
        options: options, // Keep original text options
        optionImages: httpOptionImages,
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
