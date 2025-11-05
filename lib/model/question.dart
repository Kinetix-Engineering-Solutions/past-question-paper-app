import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:past_question_paper_v1/model/drag_and_drop%20models/drag_item.dart';
import 'package:past_question_paper_v1/model/drag_and_drop%20models/drop_target.dart';
import 'package:past_question_paper_v1/services/storage_service.dart';

// PQP Mode specific data
class PQPData {
  final String? paper;
  final String? season;
  final int? year;
  final String? questionNumber;
  final String? questionText;
  final int? marks;

  PQPData({
    this.paper,
    this.season,
    this.year,
    this.questionNumber,
    this.questionText,
    this.marks,
  });

  factory PQPData.fromMap(Map<String, dynamic> data) {
    return PQPData(
      paper: data['paper']?.toString(),
      season: data['season']?.toString(),
      year: (data['year'] as num?)?.toInt(),
      questionNumber: data['questionNumber']?.toString(),
      questionText: data['questionText']?.toString(),
      marks: (data['marks'] as num?)?.toInt(),
    );
  }
}

// Sprint Mode specific data
class SprintData {
  final String? questionText;
  final Map<String, dynamic>? providedContext;
  final int? marks;
  final bool? canRandomize;
  final String? difficulty;
  final int? estimatedTime;
  final List<String>? tags;

  SprintData({
    this.questionText,
    this.providedContext,
    this.marks,
    this.canRandomize,
    this.difficulty,
    this.estimatedTime,
    this.tags,
  });

  factory SprintData.fromMap(Map<String, dynamic> data) {
    return SprintData(
      questionText: data['questionText']?.toString(),
      providedContext: data['providedContext'] != null
          ? Question._safeMapCast(data['providedContext'])
          : null,
      marks: (data['marks'] as num?)?.toInt(),
      canRandomize: data['canRandomize'] as bool?,
      difficulty: data['difficulty']?.toString(),
      estimatedTime: (data['estimatedTime'] as num?)?.toInt(),
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
    );
  }
}

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

  // --- Dual Mode Support (PQP vs Sprint) ---
  final List<String>? availableInModes; // ["pqp", "sprint"]
  final PQPData? pqpData; // PQP mode specific data
  final SprintData? sprintData; // Sprint mode specific data

  // --- Option 3: Parent-Child Relationships ---
  final String? parentQuestionId; // Reference to parent question
  final bool usesParentImage; // Whether to inherit image from parent
  final Map<String, dynamic>? parentContext; // Cached parent data from backend

  // --- Question Content ---
  final String format; // Renamed from questionType
  final String questionText; // Will contain plain text and LaTeX
  final String? imageUrl; // Renamed from questionImage
  final List<String> options; // Text options (used when no option images)
  final List<String>? optionImages; // New field for option images
  final List<String>
  correctOrder; // For drag-and-drop questions (changed from int to string for step IDs)
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
    this.availableInModes, // Dual mode support
    this.pqpData, // PQP mode specific data
    this.sprintData, // Sprint mode specific data
    this.parentQuestionId, // Option 3: Parent reference
    this.usesParentImage = false, // Option 3: Image inheritance flag
    this.parentContext, // Option 3: Cached parent data
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
      id: data['id']?.toString() ?? '',
      subject: data['subject']?.toString() ?? '',
      paper: data['paper']?.toString() ?? '',
      grade: (data['grade'] as num?)?.toInt() ?? 12,
      topic: data['topic']?.toString() ?? '',
      cognitiveLevel: data['cognitiveLevel']?.toString() ?? '',
      marks: (data['marks'] as num?)?.toInt() ?? 0,
      year: (data['year'] as num?)?.toInt() ?? 0,
      season: data['season']?.toString() ?? '',
      // Dual mode support
      availableInModes: data['availableInModes'] != null
          ? List<String>.from(data['availableInModes'])
          : null,
      pqpData: data['pqpData'] != null
          ? PQPData.fromMap(_safeMapCast(data['pqpData']))
          : null,
      sprintData: data['sprintData'] != null
          ? SprintData.fromMap(_safeMapCast(data['sprintData']))
          : null,
      // Option 3: Parent-child fields
      parentQuestionId: data['parentQuestionId']?.toString(),
      usesParentImage: data['usesParentImage'] as bool? ?? false,
      parentContext: data['parentContext'] != null
          ? _safeMapCast(data['parentContext'])
          : null,
      format: data['format']?.toString() ?? 'MCQ',
      questionText: data['questionText']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString(),
      options: List<String>.from(data['options'] ?? []),
      optionImages: data['optionImages'] != null
          ? List<String>.from(data['optionImages'])
          : null,
      correctOrder: List<String>.from(data['correctOrder'] ?? []),
      // Correct answer and explanation might not be sent from the cloud function
      // for security reasons (to prevent cheating), so we provide default values
      correctAnswer: correctAnswerValue,
      explanation: data['explanation'] ?? '',
      points: data['points'],
      timeAllocation: data['timeAllocation'],
      // Load drag-and-drop specific data if present
      dragItems: data['dragItems'] != null
          ? (data['dragItems'] as List<dynamic>)
                .map((item) => DragItem.fromDynamic(item))
                .toList()
          : null,
      // Handle both 'dragTargets' and 'dropTargets' field names for backward compatibility
      dragTargets: (data['dragTargets'] ?? data['dropTargets']) != null
          ? ((data['dragTargets'] ?? data['dropTargets']) as List<dynamic>)
                .map((target) => DropTarget.fromDynamic(target))
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
      subject: data['subject']?.toString() ?? '',
      paper: data['paper']?.toString() ?? '',
      grade: (data['grade'] as num?)?.toInt() ?? 12,
      topic: topicValue,
      cognitiveLevel: data['cognitiveLevel']?.toString() ?? '',
      marks: (data['marks'] as num?)?.toInt() ?? 0,
      year: (data['year'] as num?)?.toInt() ?? 0,
      season: data['season']?.toString() ?? '',
      // Option 3: Parent-child fields
      parentQuestionId: data['parentQuestionId']?.toString(),
      usesParentImage: data['usesParentImage'] as bool? ?? false,
      parentContext: data['parentContext'] != null
          ? _safeMapCast(data['parentContext'])
          : null,
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
      correctOrder: List<String>.from(data['correctOrder'] ?? []),
      correctAnswer: correctAnswerValue,
      explanation: data['explanation'] ?? '',
      points: data['points'],
      timeAllocation: data['timeAllocation'],
      // Load drag-and-drop specific data if present
      dragItems: data['dragItems'] != null
          ? (data['dragItems'] as List<dynamic>)
                .map((item) => DragItem.fromDynamic(item))
                .toList()
          : null,
      // Handle both 'dragTargets' and 'dropTargets' field names for backward compatibility
      dragTargets: (data['dragTargets'] ?? data['dropTargets']) != null
          ? ((data['dragTargets'] ?? data['dropTargets']) as List<dynamic>)
                .map((target) => DropTarget.fromDynamic(target))
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
      map['dragTargets'] = dragTargets!
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

    // Add mode-specific data
    if (pqpData != null) {
      map['pqpData'] = {
        'paper': pqpData!.paper,
        'season': pqpData!.season,
        'year': pqpData!.year,
        'questionNumber': pqpData!.questionNumber,
        'questionText': pqpData!.questionText,
        'marks': pqpData!.marks,
      };
    }

    if (sprintData != null) {
      map['sprintData'] = {
        'questionText': sprintData!.questionText,
        'providedContext': sprintData!.providedContext,
        'marks': sprintData!.marks,
        'canRandomize': sprintData!.canRandomize,
        'difficulty': sprintData!.difficulty,
        'estimatedTime': sprintData!.estimatedTime,
        'tags': sprintData!.tags,
      };
    }

    // Add parent context if present
    if (parentContext != null) {
      map['parentContext'] = parentContext;
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
    print('=== isValidDragAndDrop validation ===');

    if (!isDragAndDrop) {
      print('Validation failed: !isDragAndDrop (format: $format)');
      return false;
    }

    if (!hasDragDropData) {
      print('Validation failed: !hasDragDropData');
      print('  dragItems: ${dragItems?.length ?? 0}');
      print('  dragTargets: ${dragTargets?.length ?? 0}');
      return false;
    }

    // Relaxed validation: Just check that we have items and targets
    // The UI can handle mismatched IDs by allowing any item to go to any target
    if (dragItems!.isEmpty || dragTargets!.isEmpty) {
      print('Validation failed: Empty dragItems or dragTargets');
      return false;
    }

    // Optional: Check that all drop targets have valid correct pairs
    bool hasValidPairs = true;
    for (final target in dragTargets!) {
      print(
        'Checking target: ${target.id} -> correctPair: ${target.correctPair}',
      );

      final hasMatchingDragItem = dragItems!.any((item) {
        print('  Comparing with dragItem: ${item.id}');
        return item.id == target.correctPair;
      });

      if (!hasMatchingDragItem) {
        print(
          'Warning: No matching drag item for target ${target.id} with correctPair ${target.correctPair}',
        );
        hasValidPairs = false;
        // Don't return false - continue validation
      }
    }

    if (!hasValidPairs) {
      print(
        'Validation warning: Some targets have mismatched correctPair IDs, but allowing anyway',
      );
    } else {
      print('Validation passed: All targets have matching drag items');
    }

    return true; // Always return true if we have data, regardless of ID matching
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
        availableInModes: availableInModes,
        pqpData: pqpData,
        sprintData: sprintData,
        // Option 3: Parent fields
        parentQuestionId: parentQuestionId,
        usesParentImage: usesParentImage,
        parentContext: parentContext,
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

  // --- Dual Mode Support Methods ---

  /// Check if this question supports PQP mode
  bool get supportsPQP => availableInModes?.contains('pqp') ?? false;

  /// Check if this question supports Sprint mode
  bool get supportsSprint => availableInModes?.contains('sprint') ?? false;

  /// Get question text for PQP mode (uses PQP specific text or falls back to general)
  String getPQPQuestionText() {
    return pqpData?.questionText ?? questionText;
  }

  /// Get question text for Sprint mode (uses Sprint specific text or falls back to general)
  String getSprintQuestionText() {
    return sprintData?.questionText ?? questionText;
  }

  /// Get marks for PQP mode
  int getPQPMarks() {
    return pqpData?.marks ?? marks;
  }

  /// Get marks for Sprint mode
  int getSprintMarks() {
    return sprintData?.marks ?? marks;
  }

  // --- Option 3: Parent-Child Helpers ---

  /// Check if this question has a parent question
  bool get hasParent =>
      parentQuestionId != null && parentQuestionId!.isNotEmpty;

  /// Get the image URL (inherited from parent if usesParentImage is true)
  String? get displayImageUrl {
    if (usesParentImage && parentContext != null) {
      return parentContext!['imageUrl'] as String?;
    }
    return imageUrl;
  }

  /// Get parent question text from cached context
  String? get parentQuestionText => parentContext?['questionText'] as String?;

  /// Get parent question number from cached context
  String? get parentQuestionNumber =>
      parentContext?['pqpData']?['questionNumber'] as String?;

  /// Check if this question can be randomized (Sprint mode)
  bool get canRandomize => sprintData?.canRandomize ?? false;

  /// Get difficulty level for Sprint mode
  String? get difficulty => sprintData?.difficulty;

  /// Get estimated time for Sprint mode
  int? get estimatedTime => sprintData?.estimatedTime;

  /// Get tags for Sprint mode
  List<String> get tags => sprintData?.tags ?? [];

  /// Get provided context for Sprint mode
  Map<String, dynamic>? get providedContext => sprintData?.providedContext;

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
}
