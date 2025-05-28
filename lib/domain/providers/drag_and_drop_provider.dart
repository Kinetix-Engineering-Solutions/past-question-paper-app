import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/models/question.dart';
import 'package:past_question_paper_stem/domain/strategies/drag_and_drop_strategy.dart';

/// The state for a drag-and-drop question
class DragAndDropState {
  final List<String?> answerSlots;
  final List<String> optionBank;
  final bool hasSubmitted;
  final bool isCorrect;

  DragAndDropState({
    required this.answerSlots,
    required this.optionBank,
    this.hasSubmitted = false,
    this.isCorrect = false,
  });

  DragAndDropState copyWith({
    List<String?>? answerSlots,
    List<String>? optionBank,
    bool? hasSubmitted,
    bool? isCorrect,
  }) {
    return DragAndDropState(
      answerSlots: answerSlots ?? this.answerSlots,
      optionBank: optionBank ?? this.optionBank,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  bool hasDuplicatesInSlots() {
    return DragAndDropStrategy().hasDuplicatesInSlots(answerSlots);
  }
}

class DragAndDropNotifier extends StateNotifier<DragAndDropState> {
  final Question question;
  final DragAndDropStrategy _strategy = DragAndDropStrategy();

  DragAndDropNotifier(this.question)
    : super(
        DragAndDropState(
          answerSlots: DragAndDropStrategy().createInitialState(question),
          optionBank: DragAndDropStrategy().createShuffledOptionBank(question),
        ),
      );

  void moveFromBankToSlot(String option, int slotIndex) {
    final result = _strategy.moveFromBankToSlot(
      state.answerSlots,
      state.optionBank,
      option,
      slotIndex,
    );

    if (result.isValid) {
      state = state.copyWith(
        answerSlots: result.newSlots,
        optionBank: result.newBank,
      );
    }
  }

  void moveFromSlotToSlot(int fromSlotIndex, int toSlotIndex) {
    final result = _strategy.moveFromSlotToSlot(
      state.answerSlots,
      fromSlotIndex,
      toSlotIndex,
    );

    if (result.isValid) {
      state = state.copyWith(answerSlots: result.newSlots);
    }
  }

  void moveFromSlotToBank(int slotIndex) {
    final result = _strategy.moveFromSlotToBank(
      state.answerSlots,
      state.optionBank,
      slotIndex,
    );

    if (result.isValid) {
      state = state.copyWith(
        answerSlots: result.newSlots,
        optionBank: result.newBank,
      );
    }
  }

  void checkAnswer() {
    final isCorrect = _strategy.checkAnswer(question, state.answerSlots);
    state = state.copyWith(hasSubmitted: true, isCorrect: isCorrect);
  }

  void reset() {
    state = DragAndDropState(
      answerSlots: _strategy.createInitialState(question),
      optionBank: _strategy.createShuffledOptionBank(question),
    );
  }
}

/// Provider for a specific drag-and-drop question
final dragAndDropProvider = StateNotifierProvider.family<
  DragAndDropNotifier,
  DragAndDropState,
  Question
>((ref, question) => DragAndDropNotifier(question));
