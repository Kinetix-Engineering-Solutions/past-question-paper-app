import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for Question List ViewModel
final questionListViewModelProvider =
    StateNotifierProvider<QuestionListViewModel, QuestionListState>(
      (ref) => QuestionListViewModel(),
    );

/// State for Question List
class QuestionListState {
  final List<QuestionListItem> questions;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String? filterSubject;
  final int? filterGrade;
  final String? filterFormat;
  final String? filterTopic;
  final int? filterYear;
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;

  const QuestionListState({
    this.questions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.filterSubject,
    this.filterGrade,
    this.filterFormat,
    this.filterTopic,
    this.filterYear,
    this.currentPage = 1,
    this.itemsPerPage = 50,
    this.totalItems = 0,
  });

  QuestionListState copyWith({
    List<QuestionListItem>? questions,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    String? filterSubject,
    int? filterGrade,
    String? filterFormat,
    String? filterTopic,
    int? filterYear,
    int? currentPage,
    int? itemsPerPage,
    int? totalItems,
  }) {
    return QuestionListState(
      questions: questions ?? this.questions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      filterSubject: filterSubject ?? this.filterSubject,
      filterGrade: filterGrade ?? this.filterGrade,
      filterFormat: filterFormat ?? this.filterFormat,
      filterTopic: filterTopic ?? this.filterTopic,
      filterYear: filterYear ?? this.filterYear,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  int get totalPages {
    if (totalItems == 0) {
      return 1;
    }
    return (totalItems / itemsPerPage).ceil();
  }
}

/// Question List Item (simplified for table display)
class QuestionListItem {
  final String id;
  final String questionText;
  final String subject;
  final int grade;
  final String topic;
  final String format;
  final String paper;
  final int year;
  final String season;
  final int marks;
  final String correctAnswer;
  final bool isParent;
  final DateTime? createdAt;
  final String? pqpNumber;

  QuestionListItem({
    required this.id,
    required this.questionText,
    required this.subject,
    required this.grade,
    required this.topic,
    required this.format,
    required this.paper,
    required this.year,
    required this.season,
    required this.marks,
    required this.correctAnswer,
    required this.isParent,
    this.createdAt,
    this.pqpNumber,
  });

  factory QuestionListItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Safely extract pqpData questionNumber
    String? pqpNumber;
    if (data['pqpData'] != null && data['pqpData'] is Map) {
      final pqpData = data['pqpData'] as Map<String, dynamic>;
      pqpNumber = pqpData['questionNumber']?.toString();
    }

    // Safely extract correctAnswer (might be Map for drag_drop)
    String correctAnswer = '';
    if (data['correctAnswer'] != null) {
      if (data['correctAnswer'] is String) {
        correctAnswer = data['correctAnswer'] as String;
      } else if (data['correctAnswer'] is Map) {
        // For drag_drop or other complex types, just show the type
        correctAnswer = '—';
      }
    }

    // Safe int extraction helper
    int _safeInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? defaultValue;
    }

    return QuestionListItem(
      id: doc.id,
      questionText: (data['questionText'] ?? '').toString(),
      subject: (data['subject'] ?? '').toString(),
      grade: _safeInt(data['grade'], 0),
      topic: (data['topic'] ?? '').toString(),
      format: (data['questionType'] ?? '').toString(),
      paper: (data['paper'] ?? '').toString(),
      year: _safeInt(data['year'], 0),
      season: (data['season'] ?? '').toString(),
      marks: _safeInt(data['marks'], 0),
      correctAnswer: correctAnswer,
      isParent: data['isParent'] == true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      pqpNumber: pqpNumber,
    );
  }

  String get truncatedText {
    if (questionText.length <= 100) return questionText;
    return '${questionText.substring(0, 100)}...';
  }
}

/// ViewModel for Question List
class QuestionListViewModel extends StateNotifier<QuestionListState> {
  QuestionListViewModel() : super(const QuestionListState()) {
    loadQuestions();
  }

  final _firestore = FirebaseFirestore.instance;

  /// Load questions with current filters and pagination
  Future<void> loadQuestions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Build query with filters
      Query query = _firestore.collection('questions');

      // Apply filters
      if (state.filterSubject != null) {
        query = query.where('subject', isEqualTo: state.filterSubject);
      }
      if (state.filterGrade != null) {
        query = query.where('grade', isEqualTo: state.filterGrade);
      }
      if (state.filterFormat != null) {
        query = query.where('questionType', isEqualTo: state.filterFormat);
      }
      if (state.filterTopic != null) {
        query = query.where('topic', isEqualTo: state.filterTopic);
      }
      if (state.filterYear != null) {
        query = query.where('year', isEqualTo: state.filterYear);
      }

      // Note: We DON'T use orderBy('createdAt') because old questions
      // might not have this field and would be excluded from results.
      // Instead, we'll sort client-side after fetching.

      // Execute query (fetch all records matching filters; pagination handled client-side)
      final snapshot = await query.get();

      // Convert to list items
      var questions = snapshot.docs
          .map((doc) => QuestionListItem.fromFirestore(doc))
          .toList();

      // Remove parent/placeholder questions from the listing
      questions = questions.where((question) => !question.isParent).toList();

      // Sort by creation date client-side (handles missing createdAt)
      questions.sort((a, b) {
        // Questions without createdAt go to the end
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        // Newest first
        return b.createdAt!.compareTo(a.createdAt!);
      });

      // Apply search filter (client-side for now)
      final filteredQuestions = state.searchQuery.isEmpty
          ? questions
          : questions.where((q) {
              final query = state.searchQuery.toLowerCase();
              return q.questionText.toLowerCase().contains(query) ||
                  q.topic.toLowerCase().contains(query) ||
                  q.id.toLowerCase().contains(query);
            }).toList();

      final filteredTotal = filteredQuestions.length;
      final totalPages = filteredTotal == 0
          ? 1
          : (filteredTotal / state.itemsPerPage).ceil();
      final adjustedCurrentPage = filteredTotal == 0
          ? 1
          : state.currentPage.clamp(1, totalPages);

      final startIndex = (adjustedCurrentPage - 1) * state.itemsPerPage;
      final pagedQuestions = filteredQuestions
          .skip(startIndex)
          .take(state.itemsPerPage)
          .toList();

      state = state.copyWith(
        questions: pagedQuestions,
        isLoading: false,
        totalItems: filteredTotal,
        currentPage: adjustedCurrentPage,
      );
    } catch (e) {
      debugPrint('❌ Error loading questions: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load questions: ${e.toString()}',
      );
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadQuestions();
  }

  /// Update subject filter
  void updateSubjectFilter(String? subject) {
    state = state.copyWith(
      filterSubject: subject,
      currentPage: 1, // Reset to first page
    );
    loadQuestions();
  }

  /// Update grade filter
  void updateGradeFilter(int? grade) {
    state = state.copyWith(filterGrade: grade, currentPage: 1);
    loadQuestions();
  }

  /// Update format filter
  void updateFormatFilter(String? format) {
    state = state.copyWith(filterFormat: format, currentPage: 1);
    loadQuestions();
  }

  /// Update topic filter
  void updateTopicFilter(String? topic) {
    state = state.copyWith(filterTopic: topic, currentPage: 1);
    loadQuestions();
  }

  /// Update year filter
  void updateYearFilter(int? year) {
    state = state.copyWith(filterYear: year, currentPage: 1);
    loadQuestions();
  }

  /// Clear all filters
  void clearFilters() {
    state = const QuestionListState(currentPage: 1);
    loadQuestions();
  }

  /// Go to specific page
  void goToPage(int page) {
    if (page >= 1 && page <= state.totalPages) {
      state = state.copyWith(currentPage: page);
      loadQuestions();
    }
  }

  /// Next page
  void nextPage() {
    if (state.currentPage < state.totalPages) {
      goToPage(state.currentPage + 1);
    }
  }

  /// Previous page
  void previousPage() {
    if (state.currentPage > 1) {
      goToPage(state.currentPage - 1);
    }
  }

  /// Delete question
  Future<bool> deleteQuestion(String questionId) async {
    try {
      await _firestore.collection('questions').doc(questionId).delete();
      debugPrint('✅ Question deleted: $questionId');

      // Reload questions
      await loadQuestions();
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting question: $e');
      state = state.copyWith(
        errorMessage: 'Failed to delete question: ${e.toString()}',
      );
      return false;
    }
  }

  /// Refresh questions
  void refresh() {
    loadQuestions();
  }

  /// Get unique years from all questions
  Future<List<int>> getAvailableYears() async {
    try {
      final snapshot = await _firestore.collection('questions').get();
      final yearsSet = <int>{};

      for (final doc in snapshot.docs) {
        final yearValue = doc.data()['year'];
        int? year;
        if (yearValue is int) {
          year = yearValue;
        } else if (yearValue != null) {
          year = int.tryParse(yearValue.toString());
        }

        if (year != null && year > 0) {
          yearsSet.add(year);
        }
      }

      final yearsList = yearsSet.toList()
        ..sort((a, b) => b.compareTo(a)); // Descending
      return yearsList;
    } catch (e) {
      debugPrint('❌ Error fetching years: $e');
      return [];
    }
  }
}
