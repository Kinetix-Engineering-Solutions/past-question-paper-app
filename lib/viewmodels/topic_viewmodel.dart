import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/topic.dart';
import 'package:past_question_paper_stem/model/subject.dart';
import 'package:past_question_paper_stem/services/firestore_database_firebase.dart';

// Topic View Model Provider
final topicViewModelProvider =
    StateNotifierProvider<TopicViewModel, TopicState>((ref) {
      return TopicViewModel();
    });

// Topic State
class TopicState {
  final bool isLoading;
  final String? error;
  final List<Topic> topics;
  final Subject? selectedSubject;
  final String? selectedGradeId;
  final String? selectedSeason;

  const TopicState({
    this.isLoading = false,
    this.error,
    this.topics = const [],
    this.selectedSubject,
    this.selectedGradeId,
    this.selectedSeason,
  });

  TopicState copyWith({
    bool? isLoading,
    String? error,
    List<Topic>? topics,
    Subject? selectedSubject,
    String? selectedGradeId,
    String? selectedSeason,
  }) {
    return TopicState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      topics: topics ?? this.topics,
      selectedSubject: selectedSubject ?? this.selectedSubject,
      selectedGradeId: selectedGradeId ?? this.selectedGradeId,
      selectedSeason: selectedSeason ?? this.selectedSeason,
    );
  }
}

class TopicViewModel extends StateNotifier<TopicState> {
  final FirestoreDatabaseService _database = FirestoreDatabaseService();

  TopicViewModel() : super(const TopicState());

  /// Load all topics
  Future<void> loadAllTopics() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final topics = await _database.getTopics();
      state = state.copyWith(topics: topics, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load topics: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Load topics for a specific subject
  Future<void> loadTopicsForSubject(Subject subject, {String? gradeId}) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedSubject: subject,
      selectedGradeId: gradeId,
    );

    try {
      List<Topic> topics;

      if (gradeId != null) {
        // Load topics for specific subject and grade
        topics = await _database.getTopicsForSubjectAndGrade(
          subject.id,
          gradeId,
        );
      } else {
        // Load all topics for subject
        topics = await _database.getTopicsForSubject(subject.id);
      }

      state = state.copyWith(topics: topics, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load topics for ${subject.name}: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Get topic count by season
  Map<String, int> getTopicCountBySeason() {
    final filteredTopics = _getFilteredTopics();
    final Map<String, int> counts = {};

    for (final topic in filteredTopics) {
      counts[topic.season] = (counts[topic.season] ?? 0) + 1;
    }

    return counts;
  }

  /// Get unique seasons from current topics
  List<String> getAvailableSeasons() {
    return state.topics.map((topic) => topic.season).toSet().toList()..sort();
  }

  /// Apply filters and get filtered topics
  List<Topic> _getFilteredTopics() {
    List<Topic> filteredTopics = state.topics;

    // Filter by season
    if (state.selectedSeason != null) {
      filteredTopics =
          filteredTopics
              .where((topic) => topic.season == state.selectedSeason)
              .toList();
    }

    return filteredTopics;
  }

  /// Get filtered topics (public method)
  List<Topic> getFilteredTopics() {
    return _getFilteredTopics();
  }

  /// Set season filter
  void setSeasonFilter(String? season) {
    state = state.copyWith(selectedSeason: season);
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(selectedSeason: null);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state
  void reset() {
    state = const TopicState();
  }
}
