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
  final String correctOrder; // For drag-and-drop
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
  
  final bool isSubmitting;
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
    
    this.isSubmitting = false,
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
    String? parentQuestionId,
    bool? usesParentImage,
    String? parentContextText,
    String? parentImageUrl,
    String? suggestedPQPNumber,
    
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
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
      parentQuestionId: parentQuestionId ?? this.parentQuestionId,
      usesParentImage: usesParentImage ?? this.usesParentImage,
      parentContextText: parentContextText ?? this.parentContextText,
      parentImageUrl: parentImageUrl ?? this.parentImageUrl,
      suggestedPQPNumber: suggestedPQPNumber ?? this.suggestedPQPNumber,
      
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

/// ViewModel for Question Creation
class QuestionCreateViewModel extends StateNotifier<QuestionCreateState> {
  QuestionCreateViewModel() : super(const QuestionCreateState());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void updateSubject(String value) {
    state = state.copyWith(subject: value, topic: ''); // Reset topic when subject changes
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
    state = state.copyWith(format: value, correctAnswer: ''); // Reset answer when format changes
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

  void togglePQPMode() {
    state = state.copyWith(availableInPQP: !state.availableInPQP);
  }

  void toggleSprintMode() {
    state = state.copyWith(availableInSprint: !state.availableInSprint);
  }

  void toggleByTopicMode() {
    state = state.copyWith(availableInByTopic: !state.availableInByTopic);
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
        state = state.copyWith(errorMessage: 'Selected question is not a parent');
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
      state = state.copyWith(errorMessage: 'Failed to load parent: ${e.toString()}');
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

    if (state.format == 'MCQ' && options.any((o) => o.isEmpty)) {
      state = state.copyWith(errorMessage: 'All MCQ options are required');
      return;
    }

    // Validate correctAnswer for MCQ and short_answer formats
    if ((state.format == 'MCQ' || state.format == 'short_answer') && 
        state.correctAnswer.isEmpty) {
      state = state.copyWith(errorMessage: 'Correct answer is required');
      return;
    }

    // Validate correctOrder for drag_drop format
    if (state.format == 'drag_drop' && state.correctOrder.isEmpty) {
      state = state.copyWith(errorMessage: 'Correct order is required for drag & drop questions');
      return;
    }

    // Validate dragItems for drag_drop format
    if (state.format == 'drag_drop' && dragItems.isEmpty) {
      state = state.copyWith(errorMessage: 'At least one drag item is required');
      return;
    }

    // Validate child question has parent selected
    if (state.isChildQuestion && (state.parentQuestionId == null || state.parentQuestionId!.isEmpty)) {
      state = state.copyWith(errorMessage: 'Please select a parent question');
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      // Build question document
      final questionData = _buildQuestionDocument(
        options: options,
        answerVariations: answerVariations,
        dragItems: dragItems,
        explanation: explanation,
        pqpNumber: pqpNumber,
      );

      // Add to Firestore
      final docRef = await _firestore.collection('questions').add(questionData);

      debugPrint('✅ Question created successfully: ${docRef.id}');

      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Question created successfully!',
      );

      // Reset form after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        state = const QuestionCreateState();
      });
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
  }) {
    // Base question data
    final data = <String, dynamic>{
      // Core fields
      'questionText': state.questionText,
      'format': state.format,              // Primary field name
      'questionType': state.format,        // Backward compatibility
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
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': 'admin', // TODO: Replace with actual user ID when auth is added
    };

    // Build availableInModes array from boolean flags
    final List<String> modesArray = [];
    if (state.availableInPQP) modesArray.add('pqp');
    if (state.availableInSprint) modesArray.add('sprint');
    // Note: All questions are available by topic - it's a filter, not a mode
    data['availableInModes'] = modesArray;

    // Format-specific fields
    if (state.format == 'MCQ') {
      data['options'] = options;
      data['hasImageOptions'] = false;
    } else if (state.format == 'short_answer') {
      data['answerVariations'] = answerVariations;
      data['caseSensitive'] = state.caseSensitive;
    } else if (state.format == 'drag_drop') {
      // Parse correctOrder from string (e.g., "1,2,3,4")
      final orderList = state.correctOrder
          .split(',')
          .map((s) => 'step_${s.trim()}')
          .toList();
      
      data['dragItems'] = dragItems;
      data['correctOrder'] = orderList;
    }

    // Explanation for all question types
    if (explanation.isNotEmpty) {
      data['explanation'] = explanation;
    }

    // PQP-specific data
    if (state.availableInPQP) {
      data['pqpData'] = {
        'questionNumber': pqpNumber ?? _generateAutoQuestionNumber(),
        'questionText': state.questionText,
        'marks': state.marks,
      };
    }

    // Sprint-specific data
    if (state.availableInSprint) {
      data['sprintData'] = {
        'questionText': state.questionText,  // Use same as base (can override in future)
        'marks': state.marks,                // Use same as base
        'difficulty': state.difficulty,
        'canRandomize': state.format == 'MCQ', // Allow randomization for MCQ only
        'estimatedTime': state.marks * 60,   // Estimate 1 minute per mark
        'tags': [],                          // Empty for now, can add tag field later
        // 'providedContext' (hints/formulas) - Requires new UI field
      };
    }

    return data;
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
