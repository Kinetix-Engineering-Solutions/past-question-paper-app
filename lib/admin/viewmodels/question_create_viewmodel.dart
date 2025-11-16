import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for Question Create ViewModel
final questionCreateViewModelProvider =
    StateNotifierProvider<QuestionCreateViewModel, QuestionCreateState>(
      (ref) => QuestionCreateViewModel(),
    );

/// State for Question Creation Form
class QuestionCreateState {
  static const Object _unset = Object();

  final String subject;
  final int grade;
  final String topic;
  final String paper;
  final int year;
  final String season;
  final String format;
  final String questionText;
  final String correctAnswer;
  final int marks;
  final String cognitiveLevel;
  final String difficulty;
  final bool caseSensitive;
  final String correctOrder;
  final bool availableInPQP;
  final bool availableInSprint;
  final bool availableInByTopic;

  // Parent-child fields
  final bool isChildQuestion;
  final String? parentQuestionId;
  final bool usesParentImage;
  final String? parentContextText;
  final String? parentImageUrl;
  final String? suggestedPQPNumber;
  final String pqpNumber;

  // Format-specific support data
  final List<String> mcqOptions;
  final List<String> mcqOptionImages; // Image URLs for MCQ options
  final bool useImageOptions; // Toggle between text and image options
  final List<String> answerVariations;
  final List<Map<String, dynamic>> dragItems;
  final String explanation;

  // UI / lifecycle state
  final bool isSubmitting;
  final bool isLoading;
  final bool isEditMode;
  final String? questionId;
  final String? originalParentQuestionId;
  final int? originalMarks;
  final String? errorMessage;
  final String? successMessage;

  const QuestionCreateState({
    this.subject = 'mathematics',
    this.grade = 10,
    this.topic = '',
    this.paper = 'p1',
    this.year = 2024,
    this.season = 'November',
    this.format = 'MCQ',
    this.questionText = '',
    this.correctAnswer = '',
    this.marks = 1,
    this.cognitiveLevel = 'Level 1',
    this.difficulty = 'medium',
    this.caseSensitive = false,
    this.correctOrder = '',
    this.availableInPQP = true,
    this.availableInSprint = true,
    this.availableInByTopic = true,

    // Parent-child defaults
    this.isChildQuestion = false,
    this.parentQuestionId,
    this.usesParentImage = false,
    this.parentContextText,
    this.parentImageUrl,
    this.suggestedPQPNumber,
    this.pqpNumber = '',

    // Format defaults
    this.mcqOptions = const ['', '', '', ''],
    this.mcqOptionImages = const [],
    this.useImageOptions = false,
    this.answerVariations = const [],
    this.dragItems = const [],
    this.explanation = '',

    // UI state
    this.isSubmitting = false,
    this.isLoading = false,
    this.isEditMode = false,
    this.questionId,
    this.originalParentQuestionId,
    this.originalMarks,
    this.errorMessage,
    this.successMessage,
  });

  QuestionCreateState copyWith({
    String? subject,
    int? grade,
    String? topic,
    String? paper,
    int? year,
    String? season,
    String? format,
    String? questionText,
    String? correctAnswer,
    int? marks,
    String? cognitiveLevel,
    String? difficulty,
    bool? caseSensitive,
    String? correctOrder,
    bool? availableInPQP,
    bool? availableInSprint,
    bool? availableInByTopic,

    // Parent-child parameters
    bool? isChildQuestion,
    Object? parentQuestionId = _unset,
    bool? usesParentImage,
    Object? parentContextText = _unset,
    Object? parentImageUrl = _unset,
    Object? suggestedPQPNumber = _unset,
    String? pqpNumber,

    // Format data
    List<String>? mcqOptions,
    List<String>? mcqOptionImages,
    bool? useImageOptions,
    List<String>? answerVariations,
    List<Map<String, dynamic>>? dragItems,
    String? explanation,

    // UI state
    bool? isSubmitting,
    bool? isLoading,
    bool? isEditMode,
    Object? questionId = _unset,
    Object? originalParentQuestionId = _unset,
    Object? originalMarks = _unset,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
  }) {
    return QuestionCreateState(
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      topic: topic ?? this.topic,
      paper: paper ?? this.paper,
      year: year ?? this.year,
      season: season ?? this.season,
      format: format ?? this.format,
      questionText: questionText ?? this.questionText,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      marks: marks ?? this.marks,
      cognitiveLevel: cognitiveLevel ?? this.cognitiveLevel,
      difficulty: difficulty ?? this.difficulty,
      caseSensitive: caseSensitive ?? this.caseSensitive,
      correctOrder: correctOrder ?? this.correctOrder,
      availableInPQP: availableInPQP ?? this.availableInPQP,
      availableInSprint: availableInSprint ?? this.availableInSprint,
      availableInByTopic: availableInByTopic ?? this.availableInByTopic,

      // Parent-child fields
      isChildQuestion: isChildQuestion ?? this.isChildQuestion,
      parentQuestionId: parentQuestionId == _unset
          ? this.parentQuestionId
          : parentQuestionId as String?,
      usesParentImage: usesParentImage ?? this.usesParentImage,
      parentContextText: parentContextText == _unset
          ? this.parentContextText
          : parentContextText as String?,
      parentImageUrl: parentImageUrl == _unset
          ? this.parentImageUrl
          : parentImageUrl as String?,
      suggestedPQPNumber: suggestedPQPNumber == _unset
          ? this.suggestedPQPNumber
          : suggestedPQPNumber as String?,
      pqpNumber: pqpNumber ?? this.pqpNumber,

      mcqOptions: mcqOptions ?? this.mcqOptions,
      mcqOptionImages: mcqOptionImages ?? this.mcqOptionImages,
      useImageOptions: useImageOptions ?? this.useImageOptions,
      answerVariations: answerVariations ?? this.answerVariations,
      dragItems: dragItems ?? this.dragItems,
      explanation: explanation ?? this.explanation,

      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoading: isLoading ?? this.isLoading,
      isEditMode: isEditMode ?? this.isEditMode,
      questionId: questionId == _unset
          ? this.questionId
          : questionId as String?,
      originalParentQuestionId: originalParentQuestionId == _unset
          ? this.originalParentQuestionId
          : originalParentQuestionId as String?,
      originalMarks: originalMarks == _unset
          ? this.originalMarks
          : originalMarks as int?,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      successMessage: successMessage == _unset
          ? this.successMessage
          : successMessage as String?,
    );
  }
}

/// ViewModel for Question Creation
class QuestionCreateViewModel extends StateNotifier<QuestionCreateState> {
  QuestionCreateViewModel() : super(const QuestionCreateState());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void updateSubject(String value) {
    state = state.copyWith(
      subject: value,
      topic: '',
    ); // Reset topic when subject changes
  }

  void updateGrade(int value) {
    state = state.copyWith(grade: value);
  }

  void updateTopic(String value) {
    state = state.copyWith(topic: value);
  }

  void updatePaper(String value) {
    state = state.copyWith(paper: value);
  }

  void updateYear(int value) {
    state = state.copyWith(year: value);
  }

  void updateSeason(String value) {
    state = state.copyWith(season: value);
  }

  void updateFormat(String value) {
    final normalized = _normalizeFormat(value);
    state = state.copyWith(format: normalized, correctAnswer: '');
  }

  void updateQuestionText(String value) {
    state = state.copyWith(questionText: value);
  }

  void updateCorrectAnswer(String value) {
    state = state.copyWith(correctAnswer: value);
  }

  void updateMarks(int value) {
    state = state.copyWith(marks: value);
  }

  void updateCognitiveLevel(String value) {
    state = state.copyWith(cognitiveLevel: value);
  }

  void updateDifficulty(String value) {
    state = state.copyWith(difficulty: value);
  }

  void updateCaseSensitive(bool value) {
    state = state.copyWith(caseSensitive: value);
  }

  void updateCorrectOrder(String value) {
    state = state.copyWith(correctOrder: value);
  }

  void updatePqpNumber(String value) {
    state = state.copyWith(pqpNumber: value);
  }

  void togglePQPMode() {
    state = state.copyWith(availableInPQP: !state.availableInPQP);
  }

  void toggleSprintMode() {
    state = state.copyWith(availableInSprint: !state.availableInSprint);
  }

  void toggleByTopicMode() {
    state = state.copyWith(availableInByTopic: !state.availableInByTopic);
  }

  /// Toggle between text and image options for MCQ
  void toggleUseImageOptions() {
    final newValue = !state.useImageOptions;
    state = state.copyWith(
      useImageOptions: newValue,
      // Clear the opposite type when switching
      mcqOptions: newValue ? const ['', '', '', ''] : state.mcqOptions,
      mcqOptionImages: newValue ? state.mcqOptionImages : const [],
      correctAnswer: '', // Reset correct answer when switching
    );
  }

  /// Update MCQ option image at specific index
  void updateMcqOptionImage(int index, String imageUrl) {
    final updatedImages = List<String>.from(state.mcqOptionImages);

    // Ensure list is large enough
    while (updatedImages.length <= index) {
      updatedImages.add('');
    }

    updatedImages[index] = imageUrl;
    state = state.copyWith(mcqOptionImages: updatedImages);
  }

  /// Remove MCQ option image at specific index
  void removeMcqOptionImage(int index) {
    final updatedImages = List<String>.from(state.mcqOptionImages);

    if (index < updatedImages.length) {
      updatedImages[index] = '';
    }

    state = state.copyWith(mcqOptionImages: updatedImages);
  }

  /// Toggle child question mode
  void toggleChildQuestionMode() {
    final newValue = !state.isChildQuestion;
    if (newValue) {
      // Switching to child mode - keep current values
      state = state.copyWith(isChildQuestion: newValue);
    } else {
      // Switching to standalone mode - clear parent data
      state = state.copyWith(
        isChildQuestion: newValue,
        parentQuestionId: null,
        usesParentImage: false,
        parentContextText: null,
        parentImageUrl: null,
        suggestedPQPNumber: null,
      );
    }
  }

  /// Select a parent question and load its context
  Future<void> selectParent(String parentId) async {
    try {
      // Fetch parent document from Firestore
      final doc = await _firestore.collection('questions').doc(parentId).get();

      if (!doc.exists) {
        state = state.copyWith(errorMessage: 'Parent question not found');
        return;
      }

      final data = doc.data()!;

      // Verify it's actually a parent
      if (data['isParent'] != true) {
        state = state.copyWith(
          errorMessage: 'Selected question is not a parent',
        );
        return;
      }

      // Extract parent data
      final parentContextText = data['questionText'] as String?;
      final parentImageUrl = data['imageUrl'] as String?;
      final parentSubject = data['subject'] as String?;
      final parentGrade = data['grade'] as int?;
      final parentTopic = data['topic'] as String?;
      final parentPaper = data['paper'] as String?;
      final parentYear = data['year'] as int?;
      final parentSeason = data['season'] as String?;

      // Get parent PQP number for suggestion
      String? parentPQPNumber;
      if (data['pqpData'] != null && data['pqpData'] is Map) {
        final pqpData = data['pqpData'] as Map<String, dynamic>;
        parentPQPNumber = pqpData['questionNumber'] as String?;
      }

      // Generate suggested child PQP number
      String? suggestedNumber;
      if (parentPQPNumber != null) {
        // Count existing children to suggest next number
        final childrenSnapshot = await _firestore
            .collection('questions')
            .where('parentQuestionId', isEqualTo: parentId)
            .get();

        final childCount = childrenSnapshot.docs.length;
        suggestedNumber = '$parentPQPNumber.${childCount + 1}';
      }

      // Update state with parent data and auto-fill metadata
      state = state.copyWith(
        parentQuestionId: parentId,
        parentContextText: parentContextText,
        parentImageUrl: parentImageUrl,
        suggestedPQPNumber: suggestedNumber,
        // Auto-fill metadata from parent
        subject: parentSubject ?? state.subject,
        grade: parentGrade ?? state.grade,
        topic: parentTopic ?? state.topic,
        paper: parentPaper ?? state.paper,
        year: parentYear ?? state.year,
        season: parentSeason ?? state.season,
      );
    } catch (e) {
      debugPrint('❌ Error loading parent: $e');
      state = state.copyWith(
        errorMessage: 'Failed to load parent: ${e.toString()}',
      );
    }
  }

  /// Clear parent selection
  void clearParent() {
    state = state.copyWith(
      parentQuestionId: null,
      usesParentImage: false,
      parentContextText: null,
      parentImageUrl: null,
      suggestedPQPNumber: null,
    );
  }

  /// Toggle using parent's image
  void toggleUsesParentImage() {
    state = state.copyWith(usesParentImage: !state.usesParentImage);
  }

  /// Load an existing question into edit mode
  Future<void> loadQuestionForEdit(String questionId) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final doc = await _firestore
          .collection('questions')
          .doc(questionId)
          .get();

      if (!doc.exists) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Question not found.',
          isEditMode: false,
          questionId: null,
        );
        return;
      }

      final data = doc.data() as Map<String, dynamic>;

      if (data['isParent'] == true) {
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              'This context is managed via the Parent Question screen. Please edit it there.',
          isEditMode: false,
          questionId: null,
        );
        return;
      }

      final formatValue = _normalizeFormat(
        data['format'] ?? data['questionType'] ?? 'MCQ',
      );
      final subject = (data['subject'] ?? state.subject).toString();
      final grade = _safeInt(data['grade'], state.grade);
      final topic = (data['topic'] ?? '').toString();
      final paper = (data['paper'] ?? state.paper).toString();
      final year = _safeInt(data['year'], state.year);
      final season = (data['season'] ?? state.season).toString();
      final marks = _safeInt(data['marks'], state.marks);
      final cognitiveLevel = (data['cognitiveLevel'] ?? state.cognitiveLevel)
          .toString();
      final difficulty = (data['difficulty'] ?? state.difficulty).toString();
      final questionText = (data['questionText'] ?? '').toString();
      String correctAnswer = _stringifyCorrectAnswer(data['correctAnswer']);

      // Sanitize correctAnswer for MCQ format - ensure it's only A, B, C, or D
      if (formatValue == 'mcq') {
        final validAnswers = ['A', 'B', 'C', 'D'];
        if (!validAnswers.contains(correctAnswer)) {
          correctAnswer = ''; // Reset to empty if invalid
          debugPrint(
            '⚠️ Invalid correctAnswer value for MCQ: ${data['correctAnswer']}. Resetting to empty.',
          );
        }
      }

      final caseSensitive = data['caseSensitive'] == true;

      // PQP data
      String? pqpNumber;
      if (data['pqpData'] is Map<String, dynamic>) {
        final pqpData = data['pqpData'] as Map<String, dynamic>;
        pqpNumber = pqpData['questionNumber']?.toString();
      }

      // Availability modes
      final modes = (data['availableInModes'] is Iterable)
          ? (data['availableInModes'] as Iterable)
                .map((mode) => mode.toString())
                .toList()
          : <String>[];
      final availableInPQP = modes.contains('pqp');
      final availableInSprint = modes.contains('sprint');

      // Parent linkage
      final rawParentId = data['parentQuestionId'];
      String? parentId = rawParentId == null || rawParentId.toString().isEmpty
          ? null
          : rawParentId.toString();
      String? parentContextText;
      String? parentImageUrl;

      if (parentId != null) {
        final parentDoc = await _firestore
            .collection('questions')
            .doc(parentId)
            .get();
        if (parentDoc.exists) {
          final parentData = parentDoc.data() as Map<String, dynamic>;
          parentContextText = parentData['questionText']?.toString();
          parentImageUrl = parentData['imageUrl']?.toString();
        }
      }

      // MCQ options
      List<String> mcqOptions = const ['', '', '', ''];
      List<String> mcqOptionImages = const [];
      bool useImageOptions = false;

      if (formatValue.toLowerCase() == 'mcq') {
        // Check if this MCQ uses image options
        if (data['hasImageOptions'] == true &&
            data['optionImages'] is Iterable) {
          useImageOptions = true;
          mcqOptionImages = (data['optionImages'] as Iterable)
              .map((url) => url?.toString() ?? '')
              .toList();

          // For image MCQs, correctAnswer is the image URL
          // We need to map it back to a letter (A/B/C/D)
          final correctImageUrl = data['correctAnswer']?.toString() ?? '';
          final answerIndex = mcqOptionImages.indexOf(correctImageUrl);
          if (answerIndex != -1) {
            correctAnswer = ['A', 'B', 'C', 'D'][answerIndex];
          }
        } else if (data['options'] is Iterable) {
          // Text-based options
          useImageOptions = false;
          final optionsList = (data['options'] as Iterable)
              .map((option) => option?.toString() ?? '')
              .toList();
          while (optionsList.length < 4) {
            optionsList.add('');
          }
          mcqOptions = List<String>.from(optionsList.take(4));
        }
      }

      // Short answer variations
      final answerVariations = data['answerVariations'] is Iterable
          ? (data['answerVariations'] as Iterable)
                .map((variation) => variation?.toString() ?? '')
                .where((variation) => variation.isNotEmpty)
                .toList()
          : <String>[];

      // Drag & drop items
      List<Map<String, dynamic>> dragItems = [];
      if (data['dragItems'] is Iterable) {
        dragItems = (data['dragItems'] as Iterable)
            .whereType<Map>()
            .map(
              (item) =>
                  item.map((key, value) => MapEntry(key.toString(), value)),
            )
            .map((item) => Map<String, dynamic>.from(item))
            .where((item) => (item['text']?.toString().trim() ?? '').isNotEmpty)
            .toList();
      }

      // Correct order string
      String correctOrder = '';
      final rawOrder = data['correctOrder'];
      if (rawOrder is Iterable) {
        final orderList = rawOrder
            .map((step) => step?.toString() ?? '')
            .map((step) => step.startsWith('step_') ? step.substring(5) : step)
            .where((step) => step.isNotEmpty)
            .toList();
        correctOrder = orderList.join(',');
      } else if (rawOrder is String) {
        correctOrder = rawOrder.trim();
      }

      final explanation = (data['explanation'] ?? '').toString();
      final usesParentImage = data['usesParentImage'] == true;

      state = QuestionCreateState(
        subject: subject,
        grade: grade,
        topic: topic,
        paper: paper,
        year: year,
        season: season,
        format: formatValue,
        questionText: questionText,
        correctAnswer: correctAnswer,
        marks: marks,
        cognitiveLevel: cognitiveLevel,
        difficulty: difficulty,
        caseSensitive: caseSensitive,
        correctOrder: correctOrder,
        availableInPQP: availableInPQP,
        availableInSprint: availableInSprint,
        availableInByTopic: true,
        isChildQuestion: parentId != null,
        parentQuestionId: parentId,
        parentContextText: parentContextText,
        parentImageUrl: parentImageUrl,
        usesParentImage: usesParentImage,
        suggestedPQPNumber: null,
        pqpNumber: pqpNumber ?? '',
        mcqOptions: mcqOptions,
        mcqOptionImages: mcqOptionImages,
        useImageOptions: useImageOptions,
        answerVariations: answerVariations,
        dragItems: dragItems,
        explanation: explanation,
        isSubmitting: false,
        isLoading: false,
        isEditMode: true,
        questionId: questionId,
        originalParentQuestionId: parentId,
        originalMarks: marks,
        errorMessage: null,
        successMessage: null,
      );
    } catch (e) {
      debugPrint('❌ Error loading question for edit: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load question: ${e.toString()}',
        isEditMode: false,
        questionId: null,
      );
    }
  }

  /// Submit question to Firestore
  Future<void> submitQuestion({
    required List<String> options,
    required List<String> answerVariations,
    required List<Map<String, dynamic>> dragItems,
    required String explanation,
    String? pqpNumber,
  }) async {
    // Validation
    if (state.questionText.isEmpty) {
      state = state.copyWith(errorMessage: 'Question text is required');
      return;
    }

    if (state.topic.isEmpty) {
      state = state.copyWith(errorMessage: 'Topic is required');
      return;
    }

    if (state.format == 'MCQ') {
      if (state.useImageOptions) {
        // Validate image options
        final imageUrls = state.mcqOptionImages
            .where((url) => url.isNotEmpty)
            .toList();
        if (imageUrls.length < 4) {
          state = state.copyWith(
            errorMessage: 'All 4 image options are required for image MCQ',
          );
          return;
        }
      } else if (options.any((o) => o.isEmpty)) {
        // Validate text options
        state = state.copyWith(errorMessage: 'All MCQ options are required');
        return;
      }
    }

    // Validate correctAnswer for MCQ and short_answer formats
    if ((state.format == 'MCQ' || state.format == 'short_answer') &&
        state.correctAnswer.isEmpty) {
      state = state.copyWith(errorMessage: 'Correct answer is required');
      return;
    }

    // Validate correctOrder for drag_drop format
    if (state.format == 'drag_drop' && state.correctOrder.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Correct order is required for drag & drop questions',
      );
      return;
    }

    // Validate dragItems for drag_drop format
    if (state.format == 'drag_drop' && dragItems.isEmpty) {
      state = state.copyWith(
        errorMessage: 'At least one drag item is required',
      );
      return;
    }

    // Validate child question has parent selected
    if (state.isChildQuestion &&
        (state.parentQuestionId == null || state.parentQuestionId!.isEmpty)) {
      state = state.copyWith(errorMessage: 'Please select a parent question');
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final effectivePqpNumber = (pqpNumber ?? state.pqpNumber).isEmpty
          ? null
          : pqpNumber ?? state.pqpNumber;

      final questionData = _buildQuestionDocument(
        options: options,
        answerVariations: answerVariations,
        dragItems: dragItems,
        explanation: explanation,
        pqpNumber: effectivePqpNumber,
        isUpdate: state.isEditMode,
      );

      final normalizedNewParentId = state.isChildQuestion
          ? state.parentQuestionId?.trim().isEmpty ?? true
                ? null
                : state.parentQuestionId!.trim()
          : null;
      final normalizedOriginalParentId =
          state.originalParentQuestionId?.trim().isEmpty ?? true
          ? null
          : state.originalParentQuestionId?.trim();
      final int previousMarks = state.originalMarks ?? state.marks;
      final int currentMarks = state.marks;

      if (state.isEditMode && state.questionId != null) {
        final questionRef = _firestore
            .collection('questions')
            .doc(state.questionId);

        await questionRef.update(questionData);

        debugPrint('✅ Question updated successfully: ${state.questionId}');

        final bool parentChanged =
            normalizedNewParentId != normalizedOriginalParentId;
        final bool marksChanged = previousMarks != currentMarks;

        if (parentChanged) {
          if (normalizedOriginalParentId != null) {
            await _refreshParentAggregates(normalizedOriginalParentId);
          }
          if (normalizedNewParentId != null) {
            await _refreshParentAggregates(normalizedNewParentId);
          }
        } else if (normalizedNewParentId != null && marksChanged) {
          await _refreshParentAggregates(normalizedNewParentId);
        }

        state = state.copyWith(
          isSubmitting: false,
          successMessage: 'Question updated successfully!',
          pqpNumber: effectivePqpNumber ?? '',
          originalParentQuestionId: normalizedNewParentId,
          originalMarks: currentMarks,
        );
      } else {
        final createData = {
          ...questionData,
          'createdAt': FieldValue.serverTimestamp(),
        };

        final docRef = await _firestore.collection('questions').add(createData);

        debugPrint('✅ Question created successfully: ${docRef.id}');

        state = state.copyWith(
          isSubmitting: false,
          successMessage: 'Question created successfully!',
        );

        if (normalizedNewParentId != null) {
          await _refreshParentAggregates(normalizedNewParentId);
        }

        // Reset form after 2 seconds only for create flow - removed to prevent memory leaks
      }
    } catch (e) {
      debugPrint('❌ Error creating question: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to create question: ${e.toString()}',
      );
    }
  }

  /// Build Firestore document structure
  Map<String, dynamic> _buildQuestionDocument({
    required List<String> options,
    required List<String> answerVariations,
    required List<Map<String, dynamic>> dragItems,
    required String explanation,
    String? pqpNumber,
    bool isUpdate = false,
  }) {
    // Base question data
    final data = <String, dynamic>{
      // Core fields
      'questionText': state.questionText,
      'format': state.format, // Primary field name
      'questionType': state.format, // Backward compatibility
      'correctAnswer': state.correctAnswer,
      'subject': state.subject,
      'grade': state.grade,
      'topic': state.topic,
      'paper': state.paper,
      'year': state.year,
      'season': state.season,
      'marks': state.marks,
      'cognitiveLevel': state.cognitiveLevel,
      'difficulty': state.difficulty,

      // Parent-child fields
      'isParent': false,
      'parentQuestionId': state.isChildQuestion ? state.parentQuestionId : null,
      'usesParentImage': state.isChildQuestion ? state.usesParentImage : false,

      // Timestamps
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy':
          'admin', // TODO: Replace with actual user ID when auth is added
    };

    // Build availableInModes array from boolean flags
    final List<String> modesArray = [];
    if (state.availableInPQP) modesArray.add('pqp');
    if (state.availableInSprint) modesArray.add('sprint');
    // Note: All questions are available by topic - it's a filter, not a mode
    data['availableInModes'] = modesArray;

    // Format-specific fields
    if (state.format == 'MCQ') {
      if (state.useImageOptions) {
        // Image-based MCQ options
        final imageUrls = state.mcqOptionImages
            .where((url) => url.isNotEmpty)
            .toList();
        data['optionImages'] = imageUrls;
        data['hasImageOptions'] = true;

        // For image MCQs, correctAnswer is the image URL (not letter)
        // Map letter (A/B/C/D) to corresponding image URL
        final answerIndex = {
          'A': 0,
          'B': 1,
          'C': 2,
          'D': 3,
        }[state.correctAnswer];
        if (answerIndex != null && answerIndex < imageUrls.length) {
          data['correctAnswer'] = imageUrls[answerIndex];
        }

        // Remove text options
        if (isUpdate) {
          data['options'] = FieldValue.delete();
        }
      } else {
        // Text-based MCQ options
        data['options'] = options;
        data['hasImageOptions'] = false;
        data['correctAnswer'] = state.correctAnswer; // Letter (A/B/C/D)

        // Remove image options
        if (isUpdate) {
          data['optionImages'] = FieldValue.delete();
        }
      }
    } else if (isUpdate) {
      data['options'] = FieldValue.delete();
      data['optionImages'] = FieldValue.delete();
      data['hasImageOptions'] = FieldValue.delete();
    } else if (state.format == 'short_answer') {
      data['answerVariations'] = answerVariations;
      data['caseSensitive'] = state.caseSensitive;
    } else if (isUpdate) {
      data['answerVariations'] = FieldValue.delete();
      data['caseSensitive'] = FieldValue.delete();
    } else if (state.format == 'drag_drop') {
      // Parse correctOrder from string (e.g., "1,2,3,4")
      final orderList = state.correctOrder
          .split(',')
          .map((s) => 'step_${s.trim()}')
          .toList();

      data['dragItems'] = dragItems;
      data['correctOrder'] = orderList;
    } else if (isUpdate) {
      data['dragItems'] = FieldValue.delete();
      data['correctOrder'] = FieldValue.delete();
    }

    // Explanation for all question types
    if (explanation.isNotEmpty) {
      data['explanation'] = explanation;
    } else if (isUpdate) {
      data['explanation'] = FieldValue.delete();
    }

    // PQP-specific data
    if (state.availableInPQP) {
      data['pqpData'] = {
        'questionNumber': pqpNumber ?? _generateAutoQuestionNumber(),
        'questionText': state.questionText,
        'marks': state.marks,
      };
    } else if (isUpdate) {
      data['pqpData'] = FieldValue.delete();
    }

    // Sprint-specific data
    if (state.availableInSprint) {
      data['sprintData'] = {
        'questionText':
            state.questionText, // Use same as base (can override in future)
        'marks': state.marks, // Use same as base
        'difficulty': state.difficulty,
        'canRandomize':
            state.format == 'MCQ', // Allow randomization for MCQ only
        'estimatedTime': state.marks * 60, // Estimate 1 minute per mark
        'tags': [], // Empty for now, can add tag field later
        // 'providedContext' (hints/formulas) - Requires new UI field
      };
    } else if (isUpdate) {
      data['sprintData'] = FieldValue.delete();
    }

    return data;
  }

  String _normalizeFormat(dynamic rawFormat) {
    final raw = rawFormat?.toString().trim();
    if (raw == null || raw.isEmpty) {
      return 'MCQ';
    }

    final normalized = raw.replaceAll('-', '').replaceAll('_', '');
    final lower = normalized.toLowerCase();

    if (lower.contains('drag') && lower.contains('drop')) {
      return 'drag_drop';
    }
    if (lower.contains('short') && lower.contains('answer')) {
      return 'short_answer';
    }
    if (lower.contains('true') && lower.contains('false')) {
      return 'true_false';
    }
    if (lower.contains('essay')) {
      return 'essay';
    }
    if (lower.contains('mcq') || lower.contains('multiplechoice')) {
      return 'MCQ';
    }

    return raw;
  }

  Future<void> _refreshParentAggregates(String parentId) async {
    if (parentId.isEmpty) {
      return;
    }

    try {
      final childrenSnapshot = await _firestore
          .collection('questions')
          .where('parentQuestionId', isEqualTo: parentId)
          .get();

      final childIds = <String>[];
      int totalMarks = 0;

      for (final doc in childrenSnapshot.docs) {
        childIds.add(doc.id);
        final data = doc.data();
        totalMarks += _safeInt(data['marks'], 0);
      }

      await _firestore.collection('questions').doc(parentId).update({
        'childQuestionIds': childIds,
        'totalMarks': totalMarks,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint(
        '🔁 Parent aggregates refreshed for $parentId (children: ${childIds.length}, marks: $totalMarks)',
      );
    } catch (e) {
      debugPrint('⚠️ Failed to refresh parent aggregates for $parentId: $e');
    }
  }

  int _safeInt(dynamic value, int fallback) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  String _stringifyCorrectAnswer(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List) {
      return value.map((e) => e?.toString() ?? '').join(', ');
    }
    if (value is Map) {
      return value.values.map((e) => e?.toString() ?? '').join(', ');
    }
    return value.toString();
  }

  /// Generate automatic question number (e.g., "1.0.1")
  String _generateAutoQuestionNumber() {
    // Simple auto-generation - can be improved with actual paper structure
    return '${state.paper.replaceAll('p', '')}.0.1';
  }

  /// Reset form to initial state
  void resetForm() {
    state = const QuestionCreateState();
  }
}
