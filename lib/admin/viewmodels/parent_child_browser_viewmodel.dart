import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// State for Parent-Child Browser
class ParentChildBrowserState {
  final List<ParentQuestionNode> questions;
  final bool isLoading;
  final String? errorMessage;
  final FilterMode filterMode;
  final String searchQuery;
  final Set<String> expandedParentIds;
  final int? selectedYear; // null means "All Years"

  const ParentChildBrowserState({
    this.questions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filterMode = FilterMode.all,
    this.searchQuery = '',
    this.expandedParentIds = const {},
    this.selectedYear,
  });

  ParentChildBrowserState copyWith({
    List<ParentQuestionNode>? questions,
    bool? isLoading,
    String? errorMessage,
    FilterMode? filterMode,
    String? searchQuery,
    Set<String>? expandedParentIds,
    int? selectedYear,
  }) {
    return ParentChildBrowserState(
      questions: questions ?? this.questions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      filterMode: filterMode ?? this.filterMode,
      searchQuery: searchQuery ?? this.searchQuery,
      expandedParentIds: expandedParentIds ?? this.expandedParentIds,
      selectedYear: selectedYear ?? this.selectedYear,
    );
  }
}

/// Filter modes for question display
enum FilterMode { all, parentsOnly, childrenOnly, standalone }

/// Node representing a parent question with its children
class ParentQuestionNode {
  final String id;
  final Map<String, dynamic> data;
  final List<ChildQuestionNode> children;

  ParentQuestionNode({
    required this.id,
    required this.data,
    this.children = const [],
  });

  String get pqpNumber =>
      data['pqpData']?['questionNumber'] ?? id.substring(0, 8);
  String get subject => data['subject'] ?? '';
  String get topic => data['topic'] ?? '';
  String get contextText => data['contextText'] ?? '';
  bool get hasChildren => children.isNotEmpty;
  int? get year => (data['year'] as num?)?.toInt();
}

/// Node representing a child question
class ChildQuestionNode {
  final String id;
  final Map<String, dynamic> data;

  ChildQuestionNode({required this.id, required this.data});

  String get pqpNumber =>
      data['pqpData']?['questionNumber'] ?? id.substring(0, 8);
  String get questionText => data['questionText'] ?? '';
  String get format => data['format'] ?? '';
  int get marks => data['marks'] ?? 0;
}

/// ViewModel for Parent-Child Browser
class ParentChildBrowserViewModel
    extends StateNotifier<ParentChildBrowserState> {
  ParentChildBrowserViewModel() : super(const ParentChildBrowserState()) {
    loadQuestions();
  }

  final _firestore = FirebaseFirestore.instance;

  /// Load all questions and build parent-child hierarchy
  Future<void> loadQuestions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Load all questions
      final snapshot = await _firestore.collection('questions').get();

      // Separate parents, children, and standalone questions
      final Map<String, ParentQuestionNode> parentsMap = {};
      final Map<String, List<ChildQuestionNode>> childrenByParent = {};
      final List<ParentQuestionNode> standaloneQuestions = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final isParent = data['isParent'] == true;
        final parentId = data['parentQuestionId'] as String?;

        if (isParent) {
          // This is a parent question
          parentsMap[doc.id] = ParentQuestionNode(id: doc.id, data: data);
        } else if (parentId != null) {
          // This is a child question
          final child = ChildQuestionNode(id: doc.id, data: data);
          childrenByParent.putIfAbsent(parentId, () => []).add(child);
        } else {
          // This is a standalone question (no parent, not a parent)
          standaloneQuestions.add(ParentQuestionNode(id: doc.id, data: data));
        }
      }

      // Build parent nodes with their children
      final List<ParentQuestionNode> questionsList = [];

      // Add parent questions with children
      for (final parentEntry in parentsMap.entries) {
        final parentId = parentEntry.key;
        final parent = parentEntry.value;
        final children = childrenByParent[parentId] ?? [];

        // Sort children by PQP number
        children.sort((a, b) => a.pqpNumber.compareTo(b.pqpNumber));

        questionsList.add(
          ParentQuestionNode(
            id: parent.id,
            data: parent.data,
            children: children,
          ),
        );
      }

      // Add standalone questions
      questionsList.addAll(standaloneQuestions);

      // Sort by PQP number
      questionsList.sort((a, b) => a.pqpNumber.compareTo(b.pqpNumber));

      state = state.copyWith(questions: questionsList, isLoading: false);
    } catch (e) {
      debugPrint('Error loading questions: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load questions: $e',
      );
    }
  }

  /// Toggle parent expansion
  void toggleParentExpansion(String parentId) {
    final expanded = Set<String>.from(state.expandedParentIds);
    if (expanded.contains(parentId)) {
      expanded.remove(parentId);
    } else {
      expanded.add(parentId);
    }
    state = state.copyWith(expandedParentIds: expanded);
  }

  /// Expand all parents
  void expandAll() {
    final allParentIds = state.questions
        .where((q) => q.hasChildren)
        .map((q) => q.id)
        .toSet();
    state = state.copyWith(expandedParentIds: allParentIds);
  }

  /// Collapse all parents
  void collapseAll() {
    state = state.copyWith(expandedParentIds: {});
  }

  /// Update filter mode
  void setFilterMode(FilterMode mode) {
    state = state.copyWith(filterMode: mode);
  }

  /// Update search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Update selected year filter
  void setSelectedYear(int? year) {
    state = state.copyWith(selectedYear: year);
  }

  /// Get unique years from all questions
  List<int> get availableYears {
    final yearsSet = <int>{};
    for (final question in state.questions) {
      final year = question.year;
      if (year != null) {
        yearsSet.add(year);
      }
    }
    final yearsList = yearsSet.toList()
      ..sort((a, b) => b.compareTo(a)); // Descending order
    return yearsList;
  }

  /// Get filtered questions based on current filter and search
  List<ParentQuestionNode> get filteredQuestions {
    var questions = state.questions;

    // Apply filter mode
    switch (state.filterMode) {
      case FilterMode.parentsOnly:
        questions = questions.where((q) => q.hasChildren).toList();
        break;
      case FilterMode.childrenOnly:
        // Flatten to show only children
        final childrenOnly = <ParentQuestionNode>[];
        for (final parent in questions) {
          for (final child in parent.children) {
            childrenOnly.add(
              ParentQuestionNode(id: child.id, data: child.data),
            );
          }
        }
        questions = childrenOnly;
        break;
      case FilterMode.standalone:
        questions = questions.where((q) => !q.hasChildren).toList();
        break;
      case FilterMode.all:
        // Show all
        break;
    }

    // Apply search filter
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      questions = questions.where((q) {
        final pqpMatch = q.pqpNumber.toLowerCase().contains(query);
        final subjectMatch = q.subject.toLowerCase().contains(query);
        final topicMatch = q.topic.toLowerCase().contains(query);
        final contextMatch = q.contextText.toLowerCase().contains(query);

        // Also search in children
        final childMatch = q.children.any((child) {
          final childPqp = child.pqpNumber.toLowerCase().contains(query);
          final childText = child.questionText.toLowerCase().contains(query);
          return childPqp || childText;
        });

        return pqpMatch ||
            subjectMatch ||
            topicMatch ||
            contextMatch ||
            childMatch;
      }).toList();
    }

    // Apply year filter
    if (state.selectedYear != null) {
      questions = questions.where((q) => q.year == state.selectedYear).toList();
    }

    return questions;
  }

  /// Delete a parent question (with confirmation)
  Future<bool> deleteParent(String parentId) async {
    try {
      // Delete parent document
      await _firestore.collection('questions').doc(parentId).delete();

      // Reload questions
      await loadQuestions();
      return true;
    } catch (e) {
      debugPrint('Error deleting parent: $e');
      state = state.copyWith(errorMessage: 'Failed to delete parent: $e');
      return false;
    }
  }

  /// Delete a child question
  Future<bool> deleteChild(String childId, String parentId) async {
    try {
      // Delete child document
      await _firestore.collection('questions').doc(childId).delete();

      // Update parent's childQuestionIds array
      await _firestore.collection('questions').doc(parentId).update({
        'childQuestionIds': FieldValue.arrayRemove([childId]),
      });

      // Reload questions
      await loadQuestions();
      return true;
    } catch (e) {
      debugPrint('Error deleting child: $e');
      state = state.copyWith(errorMessage: 'Failed to delete child: $e');
      return false;
    }
  }
}

/// Provider for Parent-Child Browser ViewModel
final parentChildBrowserViewModelProvider =
    StateNotifierProvider<ParentChildBrowserViewModel, ParentChildBrowserState>(
      (ref) => ParentChildBrowserViewModel(),
    );
