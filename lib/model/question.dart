import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:past_question_paper_v1/model/drag_and_drop%20models/drag_item.dart';
import 'package:past_question_paper_v1/model/drag_and_drop%20models/drop_target.dart';
import 'package:past_question_paper_v1/services/storage_service.dart';

class Question {
  final String id;
  // --- Essential Metadata ---
  final String subject;
  final String paper;
  final int grade;
  final String topic; // Renamed from topicId
  final String cognitiveLevel;
  final int marks;
  final int year;
  final String season;

  // --- Question Content ---
  final String format; // Renamed from questionType
  final String questionText; // Will contain plain text and LaTeX
  final String? imageUrl; // Renamed from questionImage
  final List<String> options; // Text options (used when no option images)
  final List<String>? optionImages; // New field for option images
  final List<int> correctOrder; // For drag-and-drop questions
  final String correctAnswer; // Simplified from List<String> to String
  final String explanation;
  final int? points; // Legacy field - question points
  final int? timeAllocation; // Legacy field - seconds allocated for question

  // Drag and Drop specific fields (preserved for backward compatibility)
  final List<DragItem>? dragItems; // For drag-and-drop questions
  final List<DropTarget>? dragTargets; // For drag-and-drop questions

  // Backward compatibility getters for old field names
  String get topicId => topic;
  String get questionType => format;
  String? get questionImage => imageUrl;
  List<String> get correctAnswerList => [
    correctAnswer,
  ]; // For backward compatibility

  Question({
    required this.id,
    required this.subject,
    required this.paper,
    required this.grade,
    required this.topic,
    required this.cognitiveLevel,
    required this.marks,
    required this.year,
    required this.season,
    required this.format,
    required this.questionText,
    this.imageUrl,
    required this.options,
    this.optionImages, // Optional image URLs for options
    required this.correctOrder,
    required this.correctAnswer,
    required this.explanation,
    this.points, // Legacy field - optional points
    this.timeAllocation, // Legacy field - optional time allocation
    this.dragItems, // For drag-and-drop questions
    this.dragTargets, // For drag-and-drop questions
  });

  /// Factory constructor to create Question from Cloud Function data
  factory Question.fromMap(Map<String, dynamic> data) {
    // Handle correctAnswer as both String and List for backward compatibility
    String correctAnswerValue = '';
    if (data['correctAnswer'] != null) {
      if (data['correctAnswer'] is List) {
        List<String> answerList = List<String>.from(data['correctAnswer']);
        correctAnswerValue = answerList.isNotEmpty ? answerList.first : '';
      } else {
        correctAnswerValue = data['correctAnswer'].toString();
      }
    }

    return Question(
      id: data['id'] ?? '',
      subject: data['subject'] ?? '',
      paper: data['paper'] ?? '',
      grade: data['grade'] ?? 12,
      topic: data['topic'] ?? '',
      cognitiveLevel: data['cognitiveLevel'] ?? '',
      marks: data['marks'] ?? 0,
      year: data['year'] ?? 0,
      season: data['season'] ?? '',
      format: data['format'] ?? 'MCQ',
      questionText: data['questionText'] ?? '',
      imageUrl: data['imageUrl'],
      options: List<String>.from(data['options'] ?? []),
      optionImages: data['optionImages'] != null
          ? List<String>.from(data['optionImages'])
          : null,
      correctOrder: List<int>.from(data['correctOrder'] ?? []),
      // Correct answer and explanation might not be sent from the cloud function
      // for security reasons (to prevent cheating), so we provide default values
      correctAnswer: correctAnswerValue,
      explanation: data['explanation'] ?? '',
      points: data['points'],
      timeAllocation: data['timeAllocation'],
      // Load drag-and-drop specific data if present
      dragItems: data['dragItems'] != null
          ? (data['dragItems'] as List<dynamic>)
                .map((item) => DragItem.fromMap(item))
                .toList()
          : null,
      dragTargets: data['dragTargets'] != null
          ? (data['dragTargets'] as List<dynamic>)
                .map((target) => DropTarget.fromMap(target))
                .toList()
          : null,
    );
  }

  factory Question.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    final hasImageBasedOptions =
        data['optionImages'] != null &&
        (data['optionImages'] as List).isNotEmpty;

    // Handle both old and new field names for backward compatibility
    String topicValue = data['topic'] ?? data['topicId'] ?? '';
    String formatValue = data['format'] ?? data['questionType'] ?? 'MCQ';
    String? imageUrlValue = data['imageUrl'] ?? data['questionImage'];

    // Handle correctAnswer as both String and List for backward compatibility
    String correctAnswerValue = '';
    if (data['correctAnswer'] != null) {
      if (data['correctAnswer'] is List) {
        List<String> answerList = List<String>.from(data['correctAnswer']);
        correctAnswerValue = answerList.isNotEmpty ? answerList.first : '';
      } else {
        correctAnswerValue = data['correctAnswer'].toString();
      }
    }

    return Question(
      id: doc.id,
      subject: data['subject'] ?? '',
      paper: data['paper'] ?? '',
      grade: data['grade'] ?? 12,
      topic: topicValue,
      cognitiveLevel: data['cognitiveLevel'] ?? '',
      marks: data['marks'] ?? 0,
      year: data['year'] ?? 0,
      season: data['season'] ?? '',
      format: formatValue,
      questionText: data['questionText'] ?? '',
      imageUrl: imageUrlValue,
      // Load text options only if there are no option images
      options: hasImageBasedOptions
          ? <String>[] // Empty list when using image options
          : List<String>.from(data['options'] ?? []),
      // Load image options if present
      optionImages: hasImageBasedOptions
          ? List<String>.from(data['optionImages'])
          : null,
      correctOrder: List<int>.from(data['correctOrder'] ?? []),
      correctAnswer: correctAnswerValue,
      explanation: data['explanation'] ?? '',
      points: data['points'],
      timeAllocation: data['timeAllocation'],
      // Load drag-and-drop specific data if present
      dragItems: data['dragItems'] != null
          ? (data['dragItems'] as List<dynamic>)
                .map((item) => DragItem.fromMap(item))
                .toList()
          : null,
      dragTargets: data['dragTargets'] != null
          ? (data['dragTargets'] as List<dynamic>)
                .map((target) => DropTarget.fromMap(target))
                .toList()
          : null,
    );
  }
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'subject': subject,
      'paper': paper,
      'grade': grade,
      'topic': topic,
      'cognitiveLevel': cognitiveLevel,
      'marks': marks,
      'year': year,
      'season': season,
      'format': format,
      'questionText': questionText,
      'correctOrder': correctOrder,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };

    // Add optional fields only if they exist
    if (imageUrl != null) {
      map['imageUrl'] = imageUrl;
    }

    if (points != null) {
      map['points'] = points;
    }

    if (timeAllocation != null) {
      map['timeAllocation'] = timeAllocation;
    }

    // Add drag-and-drop specific data if present
    if (dragItems != null && dragItems!.isNotEmpty) {
      map['dragItems'] = dragItems!
          .map(
            (item) => {'id': item.id, 'text': item.text, 'image': item.image},
          )
          .toList();
    }

    if (dragTargets != null && dragTargets!.isNotEmpty) {
      map['dropTargets'] = dragTargets!
          .map(
            (target) => {
              'id': target.id,
              'text': target.text,
              'image': target.image,
              'correctPair': target.correctPair,
            },
          )
          .toList();
    }

    // Save option images if they exist, otherwise save text options
    if (optionImages != null && optionImages!.isNotEmpty) {
      map['optionImages'] = optionImages;
    } else {
      map['options'] = options;
    }

    return map;
  }

  // Check if this is a drag-and-drop question
  bool get isDragAndDrop => format == 'drag-and-drop';

  // Check if drag-and-drop data is present and valid
  bool get hasDragDropData =>
      isDragAndDrop &&
      dragItems != null &&
      dragTargets != null &&
      dragItems!.isNotEmpty &&
      dragTargets!.isNotEmpty;

  // Validate drag-and-drop question
  bool get isValidDragAndDrop {
    if (!isDragAndDrop) return false;
    if (!hasDragDropData) return false;

    // Check that all drop targets have valid correct pairs
    for (final target in dragTargets!) {
      final hasMatchingDragItem = dragItems!.any(
        (item) => item.id == target.correctPair,
      );
      if (!hasMatchingDragItem) return false;
    }

    return true;
  }

  // Get drag item by ID
  DragItem? getDragItemById(String id) {
    if (!hasDragDropData) return null;
    return dragItems!.where((item) => item.id == id).firstOrNull;
  }

  // Get drop target by ID
  DropTarget? getDropTargetById(String id) {
    if (!hasDragDropData) return null;
    return dragTargets!.where((target) => target.id == id).firstOrNull;
  }

  // Check if this question has image-based options
  bool get hasImageOptions => optionImages != null && optionImages!.isNotEmpty;

  // Check if this question has an image
  bool get hasQuestionImage => imageUrl != null && imageUrl!.isNotEmpty;

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

  // Format type checkers for UI rendering
  bool get isMCQ => format.toLowerCase() == 'mcq';
  bool get isTrueFalse =>
      format.toLowerCase() == 'true_false' ||
      format.toLowerCase() == 'true-false';
  bool get isShortAnswer =>
      format.toLowerCase() == 'short_answer' ||
      format.toLowerCase() == 'short-answer';
  bool get isEssay => format.toLowerCase() == 'essay';
  bool get isFillInBlank =>
      format.toLowerCase() == 'fill_blank' ||
      format.toLowerCase() == 'fill-blank';

  // Validate options length matches correctOrder length for drag-and-drop
  bool get hasValidOptionCount {
    if (isDragAndDrop && hasDragDropData) {
      // For new drag-and-drop with dragItems/dropTargets
      return dragItems!.length == dragTargets!.length;
    }
    if (format == 'drag-and-drop') {
      // For legacy drag-and-drop with options/correctOrder
      final optionCount = hasImageOptions
          ? optionImages!.length
          : options.length;
      return optionCount == correctOrder.length;
    }
    return true;
  }

  // Get the count of available options (either image, text, or drag items)
  int get optionCount {
    if (isDragAndDrop && hasDragDropData) {
      return dragItems!.length;
    }
    return hasImageOptions ? optionImages!.length : options.length;
  }

  // Get HTTP download URLs for all images (converting gs:// URLs if needed)
  Future<Question> withHttpUrls() async {
    final storageService = StorageService();
    String? httpQuestionImage;
    List<String>? httpOptionImages;
    List<DragItem>? httpDragItems;
    List<DropTarget>? httpDragTargets;

    try {
      // Convert question image URL if it exists
      if (hasQuestionImage) {
        httpQuestionImage = await storageService.getDownloadUrl(imageUrl!);
      }

      // Convert option image URLs if they exist
      if (hasImageOptions) {
        httpOptionImages = [];
        for (String url in optionImages!) {
          final httpUrl = await storageService.getDownloadUrl(url);
          httpOptionImages.add(httpUrl);
        }
      }

      // Convert drag items image URLs if they exist
      if (dragItems != null) {
        httpDragItems = [];
        for (DragItem item in dragItems!) {
          if (item.image != null) {
            final httpUrl = await storageService.getDownloadUrl(item.image!);
            httpDragItems.add(
              DragItem(id: item.id, text: item.text, image: httpUrl),
            );
          } else {
            httpDragItems.add(item);
          }
        }
      }

      // Convert drop targets image URLs if they exist
      if (dragTargets != null) {
        httpDragTargets = [];
        for (DropTarget target in dragTargets!) {
          if (target.image != null) {
            final httpUrl = await storageService.getDownloadUrl(target.image!);
            httpDragTargets.add(
              DropTarget(
                id: target.id,
                text: target.text,
                image: httpUrl,
                correctPair: target.correctPair,
              ),
            );
          } else {
            httpDragTargets.add(target);
          }
        }
      }

      // Return a new Question instance with HTTP URLs
      return Question(
        id: id,
        subject: subject,
        paper: paper,
        grade: grade,
        topic: topic,
        cognitiveLevel: cognitiveLevel,
        marks: marks,
        year: year,
        season: season,
        format: format,
        questionText: questionText,
        imageUrl: httpQuestionImage,
        options: options, // Keep original text options
        optionImages: httpOptionImages,
        correctOrder: correctOrder,
        correctAnswer: correctAnswer,
        explanation: explanation,
        points: points,
        timeAllocation: timeAllocation,
        dragItems: httpDragItems,
        dragTargets: httpDragTargets,
      );
    } catch (e) {
      print('Error converting URLs: $e');
      // Return the original question if conversion fails
      return this;
    }
  }
}
