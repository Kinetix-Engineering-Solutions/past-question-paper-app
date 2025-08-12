import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:past_question_paper_stem/services/storage_service.dart';
import 'package:past_question_paper_stem/model/drag_and_drop%20models/drag_Item.dart';
import 'package:past_question_paper_stem/model/drag_and_drop%20models/drop_target.dart';

class Question {
  final String id;
  final String topicId; // Add this - links question to topic
  final String questionType;
  final String questionText;
  final String? questionImage; // New field for question image
  final List<String> options; // Text options (used when no option images)
  final List<String>? optionImages; // New field for option images
  final List<int> correctOrder; // For drag-and-drop questions
  final List<String> correctAnswer;
  final String explanation;
  final int? points; // Add this - question points
  final int? timeAllocation; // Add this - seconds allocated for question

  // Drag and Drop specific fields
  final List<DragItem>? dragItems; // For drag-and-drop questions
  final List<DropTarget>? dragTargets; // For drag-and-drop questions

  Question({
    required this.id,
    required this.topicId, // Add this parameter
    required this.questionType,
    required this.questionText,
    this.questionImage, // Optional image URL for the question
    this.options =
        const <String>[], // Default to empty list when using image options
    this.optionImages, // Optional image URLs for options
    required this.correctOrder,
    required this.correctAnswer,
    required this.explanation,
    this.points, // Add optional points
    this.timeAllocation, // Add optional time allocation
    this.dragItems, // Add drag items for drag-and-drop questions
    this.dragTargets, // Add drop targets for drag-and-drop questions
  });
  factory Question.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    final hasImageBasedOptions =
        data['optionImages'] != null &&
        (data['optionImages'] as List).isNotEmpty;

    return Question(
      id: doc.id,
      topicId: data['topicId'] ?? '', // Add this field
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
      points: data['points'],
      timeAllocation: data['timeAllocation'],
      // Load drag-and-drop specific data if present
      dragItems:
          data['dragItems'] != null
              ? (data['dragItems'] as List<dynamic>)
                  .map((item) => DragItem.fromMap(item))
                  .toList()
              : null,
      dragTargets:
          data['dragTargets'] != null
              ? (data['dragTargets'] as List<dynamic>)
                  .map((target) => DropTarget.fromMap(target))
                  .toList()
              : null,
    );
  }
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'topicId': topicId, // Add this field
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

    if (points != null) {
      map['points'] = points;
    }

    if (timeAllocation != null) {
      map['timeAllocation'] = timeAllocation;
    }

    // Add drag-and-drop specific data if present
    if (dragItems != null && dragItems!.isNotEmpty) {
      map['dragItems'] =
          dragItems!
              .map(
                (item) => {
                  'id': item.id,
                  'text': item.text,
                  'image': item.image,
                },
              )
              .toList();
    }

    if (dragTargets != null && dragTargets!.isNotEmpty) {
      map['dropTargets'] =
          dragTargets!
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
  bool get isDragAndDrop => questionType == 'drag-and-drop';

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

  // Validate options length matches correctOrder length for drag-and-drop
  bool get hasValidOptionCount {
    if (isDragAndDrop && hasDragDropData) {
      // For new drag-and-drop with dragItems/dropTargets
      return dragItems!.length == dragTargets!.length;
    }
    if (questionType == 'drag-and-drop') {
      // For legacy drag-and-drop with options/correctOrder
      final optionCount =
          hasImageOptions ? optionImages!.length : options.length;
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
        httpQuestionImage = await storageService.getDownloadUrl(questionImage!);
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
        topicId: topicId,
        questionType: questionType,
        questionText: questionText,
        questionImage: httpQuestionImage,
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
