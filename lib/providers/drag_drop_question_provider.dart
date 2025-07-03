import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/drag_and_drop%20models/drag_Item.dart';
import 'package:past_question_paper_stem/model/drag_and_drop%20models/drag_and_drop_question.dart';

// State class for drag and drop quiz
class DragDropQuizState {
  final Map<String, String> dragItemPlacements;
  final bool isSubmitted;
  final Map<String, bool> results;
  final bool isLoading;
  final String? error;

  const DragDropQuizState({
    this.dragItemPlacements = const {},
    this.isSubmitted = false,
    this.results = const {},
    this.isLoading = false,
    this.error,
  });

  DragDropQuizState copyWith({
    Map<String, String>? dragItemPlacements,
    bool? isSubmitted,
    Map<String, bool>? results,
    bool? isLoading,
    String? error,
  }) {
    return DragDropQuizState(
      dragItemPlacements: dragItemPlacements ?? this.dragItemPlacements,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// ViewModel for drag and drop quiz
class DragDropQuizViewModel extends StateNotifier<DragDropQuizState> {
  final DragDropQuestion question;

  DragDropQuizViewModel(this.question) : super(const DragDropQuizState()) {
    _validateQuestionData();
  }

  // Get available drag items (not yet placed)
  List<DragItem> get availableDragItems {
    return question.dragItems
        .where((item) => !state.dragItemPlacements.values.contains(item.id))
        .toList();
  }

  // Get the drag item placed on a specific target
  DragItem? getDragItemOnTarget(String targetId) {
    final dragItemId = state.dragItemPlacements[targetId];
    if (dragItemId == null) return null;

    final matchingItems = question.dragItems.where(
      (item) => item.id == dragItemId,
    );

    return matchingItems.isNotEmpty ? matchingItems.first : null;
  }

  // Check if all targets have items placed
  bool get allTargetsFilled {
    return state.dragItemPlacements.length == question.dropTargets.length;
  }

  // Get correct answers count
  int get correctCount {
    return state.results.values.where((correct) => correct).length;
  }

  // Get total questions count
  int get totalCount {
    return state.results.length;
  }

  // Check if a target is correct
  bool isTargetCorrect(String targetId) {
    return state.isSubmitted && (state.results[targetId] ?? false);
  }

  // Check if a target is incorrect
  bool isTargetIncorrect(String targetId) {
    return state.isSubmitted && !(state.results[targetId] ?? true);
  }

  // Place a drag item on a target
  void placeDragItem(String targetId, String dragItemId) {
    // Verify that the drag item exists
    final matchingItems = question.dragItems.where(
      (item) => item.id == dragItemId,
    );

    if (matchingItems.isNotEmpty) {
      final newPlacements = Map<String, String>.from(state.dragItemPlacements);
      newPlacements[targetId] = dragItemId;

      state = state.copyWith(dragItemPlacements: newPlacements);
    } else {
      state = state.copyWith(error: 'Invalid drag item: $dragItemId');
    }
  }

  // Remove a drag item from a target
  void removeDragItem(String targetId) {
    final newPlacements = Map<String, String>.from(state.dragItemPlacements);
    newPlacements.remove(targetId);

    state = state.copyWith(dragItemPlacements: newPlacements);
  }

  // Submit answers and check results
  QuizResult submitAnswers() {
    if (!allTargetsFilled) {
      state = state.copyWith(
        error: 'Please fill all targets before submitting',
      );
      return QuizResult(
        isSuccess: false,
        message: 'Please fill all targets before submitting',
      );
    }

    final newResults = <String, bool>{};

    // Check each placement
    for (var target in question.dropTargets) {
      final placedItemId = state.dragItemPlacements[target.id];
      newResults[target.id] = placedItemId == target.correctPair;
    }

    state = state.copyWith(isSubmitted: true, results: newResults, error: null);

    final correct = correctCount;
    final total = totalCount;
    final message = 'You got $correct out of $total correct!';

    return QuizResult(
      isSuccess: true,
      message: message,
      correctCount: correct,
      totalCount: total,
      isPerfectScore: correct == total,
    );
  }

  // Reset the quiz
  void resetQuiz() {
    state = const DragDropQuizState();
  }

  // Clear any error messages
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Validate question data structure
  void _validateQuestionData() {
    print('=== Question Data Validation ===');
    print('Question Text: ${question.questionText}');
    print('Drag Items Count: ${question.dragItems.length}');
    print('Drop Targets Count: ${question.dropTargets.length}');

    print('\nDrag Items:');
    for (var item in question.dragItems) {
      print('  - ID: ${item.id}, Text: ${item.text}, Image: ${item.image}');
    }

    print('\nDrop Targets:');
    for (var target in question.dropTargets) {
      print(
        '  - ID: ${target.id}, Text: ${target.text}, Image: ${target.image}, CorrectPair: ${target.correctPair}',
      );
    }
    print('=== End Validation ===\n');
  }
}

// Result class for quiz submission
class QuizResult {
  final bool isSuccess;
  final String message;
  final int? correctCount;
  final int? totalCount;
  final bool isPerfectScore;

  const QuizResult({
    required this.isSuccess,
    required this.message,
    this.correctCount,
    this.totalCount,
    this.isPerfectScore = false,
  });
}

// Provider for the drag drop quiz view model
final dragDropQuizViewModelProvider = StateNotifierProvider.family<
  DragDropQuizViewModel,
  DragDropQuizState,
  DragDropQuestion
>((ref, question) => DragDropQuizViewModel(question));
