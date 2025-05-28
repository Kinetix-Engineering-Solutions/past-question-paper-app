import 'dart:math';
import 'package:flutter/material.dart';
import 'package:past_question_paper_stem/domain/strategies/question_strategy.dart';
import 'package:past_question_paper_stem/models/question.dart';
import 'package:past_question_paper_stem/presentation/widgets/drag_and_drop_question_widget.dart';

/// Pure business logic strategy for handling drag-and-drop questions
class DragAndDropStrategy implements QuestionStrategy {
  @override
  bool validate(Question question) {
    // Ensure we have either text options or image options
    if (!question.hasImageOptions && question.options.isEmpty) {
      return false;
    }

    // Validate we have a correct order
    if (question.correctOrder.isEmpty) {
      return false;
    }

    // Get the actual option count based on question type
    final optionCount =
        question.hasImageOptions
            ? question.optionImages!.length
            : question.options.length;

    // Validate correctOrder indices
    return question.correctOrder.every(
      (index) => index >= 0 && index < optionCount,
    );
  }

  @override
  Widget buildQuestionContent(Question question, BuildContext context) {
    return DragAndDropQuestionWidget(question: question);
  }

  @override
  bool checkAnswer(Question question, dynamic userAnswer) {
    if (userAnswer is! List<String?>) return false;

    final answerSlots = userAnswer;

    // Check if all slots are filled
    if (answerSlots.any((item) => item == null)) return false;

    // Get the actual options based on question type
    final options =
        question.hasImageOptions ? question.optionImages! : question.options;

    // Check if the order matches the correctOrder
    for (int i = 0; i < question.correctOrder.length; i++) {
      final correctOption = options[question.correctOrder[i]];
      if (answerSlots[i] != correctOption) {
        return false;
      }
    }
    return true;
  }

  @override
  String getCorrectAnswerText(Question question) {
    // Get the actual options based on question type
    final options =
        question.hasImageOptions ? question.optionImages! : question.options;

    final orderedOptions =
        question.correctOrder
            .where((index) => index < options.length)
            .map((index) => options[index])
            .toList();

    // For image options, show text description if available
    if (question.hasImageOptions && question.correctAnswer.isNotEmpty) {
      return question.correctAnswer.join(" → ");
    }

    return orderedOptions.join(" → ");
  }

  @override
  List<String?> createInitialState(Question question) {
    return List<String?>.filled(question.correctOrder.length, null);
  }

  /// Creates a shuffled option bank for the question
  List<String> createShuffledOptionBank(Question question) {
    // Get the actual options based on question type
    final options =
        question.hasImageOptions ? question.optionImages! : question.options;

    final bank = List<String>.from(options);
    bank.shuffle(Random());
    return bank;
  }

  /// Pure business logic for moving from bank to slot
  MoveResult moveFromBankToSlot(
    List<String?> currentSlots,
    List<String> currentBank,
    String option,
    int slotIndex,
  ) {
    if (slotIndex < 0 || slotIndex >= currentSlots.length) {
      return MoveResult.invalid();
    }

    if (currentSlots[slotIndex] != null) {
      return MoveResult.invalid();
    }

    if (!currentBank.contains(option)) {
      return MoveResult.invalid();
    }

    final newSlots = List<String?>.from(currentSlots);
    newSlots[slotIndex] = option;

    final newBank = List<String>.from(currentBank)..remove(option);

    return MoveResult.success(newSlots, newBank);
  }

  /// Pure business logic for moving from slot to slot
  MoveResult moveFromSlotToSlot(
    List<String?> currentSlots,
    int fromIndex,
    int toIndex,
  ) {
    if (fromIndex == toIndex ||
        fromIndex < 0 ||
        fromIndex >= currentSlots.length ||
        toIndex < 0 ||
        toIndex >= currentSlots.length) {
      return MoveResult.invalid();
    }

    if (currentSlots[toIndex] != null || currentSlots[fromIndex] == null) {
      return MoveResult.invalid();
    }

    final newSlots = List<String?>.from(currentSlots);
    newSlots[toIndex] = newSlots[fromIndex];
    newSlots[fromIndex] = null;

    return MoveResult.success(newSlots, null);
  }

  /// Pure business logic for moving from slot to bank
  MoveResult moveFromSlotToBank(
    List<String?> currentSlots,
    List<String> currentBank,
    int slotIndex,
  ) {
    if (slotIndex < 0 || slotIndex >= currentSlots.length) {
      return MoveResult.invalid();
    }

    final option = currentSlots[slotIndex];
    if (option == null) {
      return MoveResult.invalid();
    }

    final newSlots = List<String?>.from(currentSlots);
    newSlots[slotIndex] = null;

    final newBank = List<String>.from(currentBank)..add(option);

    return MoveResult.success(newSlots, newBank);
  }

  /// Checks if there are duplicate options in slots
  bool hasDuplicatesInSlots(List<String?> answerSlots) {
    final filled = answerSlots.whereType<String>().toList();
    return filled.length != filled.toSet().length;
  }
}

/// Result of a move operation
class MoveResult {
  final bool isValid;
  final List<String?>? newSlots;
  final List<String>? newBank;

  MoveResult._(this.isValid, this.newSlots, this.newBank);

  factory MoveResult.success(List<String?> slots, List<String>? bank) =>
      MoveResult._(true, slots, bank);

  factory MoveResult.invalid() => MoveResult._(false, null, null);
}
