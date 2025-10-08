import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for Parent Question Creation
@immutable
class ParentQuestionCreateState {
  // Basic Information
  final String subject;
  final int grade;
  final String topic;
  final String paper;
  final int year;
  final String season;

  // Context Content
  final String contextText;
  final String? imageUrl;

  // PQP Metadata
  final String pqpNumber;

  // Availability
  final bool availableInPQP;
  final bool availableInSprint;

  // UI State
  final bool isSubmitting;
  final bool isLoading;
  final bool isEditMode;
  final String? parentId;
  final List<String> childQuestionIds;
  final int totalMarks;
  final String? errorMessage;
  final String? successMessage;

  const ParentQuestionCreateState({
    this.subject = '',
    this.grade = 12,
    this.topic = '',
    this.paper = 'p1',
    this.year = 2024,
    this.season = 'November',
    this.contextText = '',
    this.imageUrl,
    this.pqpNumber = '',
    this.availableInPQP = true,
    this.availableInSprint = true,
    this.isSubmitting = false,
    this.isLoading = false,
    this.isEditMode = false,
    this.parentId,
    this.childQuestionIds = const [],
    this.totalMarks = 0,
    this.errorMessage,
    this.successMessage,
  });

  ParentQuestionCreateState copyWith({
    String? subject,
    int? grade,
    String? topic,
    String? paper,
    int? year,
    String? season,
    String? contextText,
    String? imageUrl,
    String? pqpNumber,
    bool? availableInPQP,
    bool? availableInSprint,
    bool? isSubmitting,
    bool? isLoading,
    bool? isEditMode,
    String? parentId,
    List<String>? childQuestionIds,
    int? totalMarks,
    String? errorMessage,
    String? successMessage,
  }) {
    return ParentQuestionCreateState(
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      topic: topic ?? this.topic,
      paper: paper ?? this.paper,
      year: year ?? this.year,
      season: season ?? this.season,
      contextText: contextText ?? this.contextText,
      imageUrl: imageUrl ?? this.imageUrl,
      pqpNumber: pqpNumber ?? this.pqpNumber,
      availableInPQP: availableInPQP ?? this.availableInPQP,
      availableInSprint: availableInSprint ?? this.availableInSprint,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoading: isLoading ?? this.isLoading,
      isEditMode: isEditMode ?? this.isEditMode,
      parentId: parentId ?? this.parentId,
      childQuestionIds: childQuestionIds ?? this.childQuestionIds,
      totalMarks: totalMarks ?? this.totalMarks,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

/// Provider for Parent Question Creation
final parentQuestionCreateViewModelProvider =
    StateNotifierProvider<
      ParentQuestionCreateViewModel,
      ParentQuestionCreateState
    >((ref) => ParentQuestionCreateViewModel());

/// ViewModel for Parent Question Creation
class ParentQuestionCreateViewModel
    extends StateNotifier<ParentQuestionCreateState> {
  ParentQuestionCreateViewModel() : super(const ParentQuestionCreateState());

  final _firestore = FirebaseFirestore.instance;

  // Update methods
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

  void updateContextText(String value) {
    state = state.copyWith(contextText: value);
  }

  void updateImageUrl(String value) {
    state = state.copyWith(imageUrl: value);
  }

  void updatePQPNumber(String value) {
    state = state.copyWith(pqpNumber: value);
  }

  void togglePQPMode() {
    state = state.copyWith(availableInPQP: !state.availableInPQP);
  }

  void toggleSprintMode() {
    state = state.copyWith(availableInSprint: !state.availableInSprint);
  }

  /// Validate form data
  bool _validateForm() {
    if (state.subject.isEmpty) {
      state = state.copyWith(errorMessage: 'Subject is required');
      return false;
    }
    if (state.topic.isEmpty) {
      state = state.copyWith(errorMessage: 'Topic is required');
      return false;
    }
    if (state.contextText.isEmpty) {
      state = state.copyWith(errorMessage: 'Context text is required');
      return false;
    }
    if (state.pqpNumber.isEmpty) {
      state = state.copyWith(errorMessage: 'PQP number is required');
      return false;
    }
    if (!state.availableInPQP && !state.availableInSprint) {
      state = state.copyWith(
        errorMessage: 'Select at least one mode (PQP or Sprint)',
      );
      return false;
    }
    return true;
  }

  /// Save parent question to Firestore
  Future<void> saveParentQuestion() async {
    if (!_validateForm()) return;

    state = state.copyWith(
      isSubmitting: true,
      isLoading: false,
      errorMessage: null,
      successMessage: null,
    );

    try {
      if (state.isEditMode && state.parentId != null) {
        final updateData = _buildParentDocument(isUpdate: true);
        await _firestore
            .collection('questions')
            .doc(state.parentId)
            .update(updateData);

        debugPrint('✅ Parent question updated successfully: ${state.parentId}');

        state = state.copyWith(
          isSubmitting: false,
          successMessage: 'Parent question updated successfully!',
        );
      } else {
        final parentData = _buildParentDocument();
        final docRef = await _firestore.collection('questions').add(parentData);

        debugPrint('✅ Parent question created successfully: ${docRef.id}');

        state = state.copyWith(
          isSubmitting: false,
          successMessage:
              'Parent question created successfully! You can now add child questions.',
        );

        // Reset form after 3 seconds for create flow only
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && !state.isEditMode) {
            state = const ParentQuestionCreateState();
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error creating parent question: $e');
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to create parent question: ${e.toString()}',
      );
    }
  }

  /// Build Firestore document structure for parent question
  Map<String, dynamic> _buildParentDocument({bool isUpdate = false}) {
    // Build availableInModes array
    final List<String> modesArray = [];
    if (state.availableInPQP) modesArray.add('pqp');
    if (state.availableInSprint) modesArray.add('sprint');

    final Map<String, dynamic> data = {
      // Parent identification
      'type': 'context', // NOT a question format
      'isParent': true,

      // Context content
      'questionText': state.contextText,
      if (state.imageUrl != null && state.imageUrl!.isNotEmpty)
        'imageUrl': state.imageUrl,

      // Metadata (inherited by children)
      'subject': state.subject,
      'grade': state.grade,
      'topic': state.topic,
      'paper': state.paper,
      'year': state.year,
      'season': state.season,

      // Parent-specific fields
      'childQuestionIds': state.childQuestionIds,
      'totalMarks': state.totalMarks,
      // Availability
      'availableInModes': modesArray,

      // PQP data
      'pqpData': {
        'questionNumber': state.pqpNumber,
        'year': state.year,
        'season': state.season,
        'paper': state.paper,
        'marks': 0, // Calculated from children
        'isParent': true,
      },

      // Timestamps
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': 'admin', // TODO: Replace with actual user ID when auth added
    };

    if (!isUpdate) {
      data['childQuestionIds'] = [];
      data['totalMarks'] = 0;
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    return data;
  }

  /// Reset form to initial state
  void resetForm() {
    state = const ParentQuestionCreateState();
  }

  /// Load an existing parent question for editing
  Future<void> loadParentForEdit(String parentId) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final doc = await _firestore.collection('questions').doc(parentId).get();

      if (!doc.exists) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Parent question not found.',
        );
        return;
      }

      final data = doc.data() as Map<String, dynamic>;

      if (data['isParent'] != true) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Selected document is not a parent question.',
        );
        return;
      }

      final pqpData = (data['pqpData'] as Map<String, dynamic>?) ?? {};
      final List<String> modes = (data['availableInModes'] is Iterable)
          ? (data['availableInModes'] as Iterable)
                .map((e) => e.toString())
                .toList()
          : <String>[];

      int safeInt(dynamic value, int fallback) {
        if (value == null) return fallback;
        if (value is int) return value;
        if (value is num) return value.toInt();
        return int.tryParse(value.toString()) ?? fallback;
      }

      state = state.copyWith(
        isLoading: false,
        isEditMode: true,
        parentId: parentId,
        subject: (data['subject'] ?? '').toString(),
        grade: safeInt(data['grade'], 12),
        topic: (data['topic'] ?? '').toString(),
        paper: (data['paper'] ?? 'p1').toString(),
        year: safeInt(data['year'], 2024),
        season: (data['season'] ?? 'November').toString(),
        contextText: (data['questionText'] ?? '').toString(),
        imageUrl: data['imageUrl']?.toString(),
        pqpNumber: pqpData['questionNumber']?.toString() ?? '',
        availableInPQP: modes.contains('pqp'),
        availableInSprint: modes.contains('sprint'),
        childQuestionIds: (data['childQuestionIds'] is Iterable)
            ? (data['childQuestionIds'] as Iterable)
                  .map((e) => e.toString())
                  .toList()
            : <String>[],
        totalMarks: safeInt(data['totalMarks'], 0),
      );
    } catch (e) {
      debugPrint('❌ Error loading parent question: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load parent question: ${e.toString()}',
      );
    }
  }

  /// Exit edit mode and reset state
  void exitEditMode() {
    state = const ParentQuestionCreateState();
  }
}
