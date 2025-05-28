import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/domain/providers/drag_and_drop_provider.dart';
import 'package:past_question_paper_stem/models/question.dart';

/// UI widget for drag-and-drop questions
class DragAndDropQuestionWidget extends ConsumerWidget {
  final Question question;

  const DragAndDropQuestionWidget({super.key, required this.question});

  // Constants for better maintainability
  static const double _slotWidth = 130.0;
  static const double _slotHeight = 50.0;
  static const double _defaultSpacing = 8.0;
  static const double _borderRadius = 10.0;
  static const String _instructionText =
      'Drag the correct options to solve the question:';
  static const String _duplicateErrorText =
      'Error: The same option cannot be placed in multiple slots.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dragDropState = ref.watch(dragAndDropProvider(question));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInstructions(),
        const SizedBox(height: 12),
        _buildAnswerSlots(dragDropState, ref),
        const SizedBox(height: 24),
        _buildOptionBank(dragDropState, ref),
        _buildErrorMessage(dragDropState),
        _buildSubmitButton(dragDropState, ref),
        _buildResults(dragDropState, ref),
      ],
    );
  }

  Widget _buildInstructions() {
    return const Text(
      _instructionText,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildAnswerSlots(dynamic dragDropState, WidgetRef ref) {
    final answerSlots = dragDropState.answerSlots as List<String?>;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: _defaultSpacing,
      runSpacing: _defaultSpacing,
      children: List.generate(
        answerSlots.length,
        (slotIndex) => _buildAnswerSlot(
          dragDropState,
          ref,
          slotIndex,
          answerSlots[slotIndex],
        ),
      ),
    );
  }

  Widget _buildAnswerSlot(
    dynamic dragDropState,
    WidgetRef ref,
    int slotIndex,
    String? slotData,
  ) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails:
          (details) => _shouldAcceptInSlot(details.data, slotIndex, slotData),
      onAcceptWithDetails:
          (details) => _handleSlotDrop(details.data, slotIndex, ref),
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;

        return Container(
          width: _slotWidth,
          height: _slotHeight,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: _getSlotDecoration(isHighlighted, slotData),
          child:
              slotData == null
                  ? const Center(child: Text(""))
                  : _buildDraggableOption(
                    slotData,
                    slotIndex,
                    isFromSlot: true,
                  ),
        );
      },
    );
  }

  Widget _buildOptionBank(dynamic dragDropState, WidgetRef ref) {
    final optionBank = dragDropState.optionBank as List<String>;

    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) => data != null && data['from'] == 'slot',
      onAccept: (data) {
        final fromIndex = data['slotIndex'] as int;
        ref
            .read(dragAndDropProvider(question).notifier)
            .moveFromSlotToBank(fromIndex);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: _getBankDecoration(isHighlighted),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: _defaultSpacing,
            runSpacing: _defaultSpacing,
            children:
                optionBank
                    .map((option) => _buildDraggableOption(option, null))
                    .toList(),
          ),
        );
      },
    );
  }

  Widget _buildDraggableOption(
    String option,
    int? slotIndex, {
    bool isFromSlot = false,
  }) {
    final dragData = {
      'option': option,
      'from': isFromSlot ? 'slot' : 'bank',
      if (isFromSlot) 'slotIndex': slotIndex,
    };

    return Draggable<Map<String, dynamic>>(
      data: dragData,
      feedback: Material(
        color: Colors.transparent,
        child: _buildOptionChip(option, isDragging: true),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildOptionChip(option)),
      child: _buildOptionChip(option),
    );
  }

  Widget _buildErrorMessage(dynamic dragDropState) {
    if (!dragDropState.hasDuplicatesInSlots()) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        _duplicateErrorText,
        style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubmitButton(dynamic dragDropState, WidgetRef ref) {
    if (dragDropState.hasSubmitted) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ElevatedButton(
        onPressed: () {
          ref.read(dragAndDropProvider(question).notifier).checkAnswer();
        },
        child: const Text('Check Answer'),
      ),
    );
  }

  Widget _buildResults(dynamic dragDropState, WidgetRef ref) {
    if (!dragDropState.hasSubmitted) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _getResultDecoration(dragDropState.isCorrect),
        child: Column(
          children: [
            Text(
              dragDropState.isCorrect
                  ? 'Correct! Well done!'
                  : 'Not quite right. Keep trying!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: dragDropState.isCorrect ? Colors.green : Colors.red,
              ),
            ),
            if (!dragDropState.isCorrect)
              TextButton(
                onPressed: () {
                  ref.read(dragAndDropProvider(question).notifier).reset();
                },
                child: const Text('Try Again'),
              ),
          ],
        ),
      ),
    );
  }

  // Helper methods for styling and logic
  bool _shouldAcceptInSlot(
    Map<String, dynamic>? data,
    int slotIndex,
    String? slotData,
  ) {
    if (data == null || slotData != null) return false;

    if (data['from'] == 'bank') return true;
    if (data['from'] == 'slot') return data['slotIndex'] != slotIndex;

    return false;
  }

  void _handleSlotDrop(
    Map<String, dynamic> data,
    int slotIndex,
    WidgetRef ref,
  ) {
    final notifier = ref.read(dragAndDropProvider(question).notifier);

    if (data['from'] == 'bank') {
      notifier.moveFromBankToSlot(data['option'] as String, slotIndex);
    } else if (data['from'] == 'slot') {
      notifier.moveFromSlotToSlot(data['slotIndex'] as int, slotIndex);
    }
  }

  BoxDecoration _getSlotDecoration(bool isHighlighted, String? slotData) {
    return BoxDecoration(
      color:
          isHighlighted
              ? Colors.lightGreenAccent.withOpacity(0.5)
              : (slotData == null ? Colors.grey[200] : Colors.blue[100]),
      borderRadius: BorderRadius.circular(_borderRadius),
      border: Border.all(
        color: isHighlighted ? Colors.green : Colors.blueAccent,
        width: 2,
      ),
    );
  }

  BoxDecoration _getBankDecoration(bool isHighlighted) {
    return BoxDecoration(
      color:
          isHighlighted
              ? Colors.lightBlueAccent.withOpacity(0.2)
              : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isHighlighted ? Colors.blue : Colors.transparent,
        width: isHighlighted ? 2 : 0,
      ),
    );
  }

  BoxDecoration _getResultDecoration(bool isCorrect) {
    return BoxDecoration(
      color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: isCorrect ? Colors.green : Colors.red),
    );
  }

  Widget _buildOptionChip(String option, {bool isDragging = false}) {
    final hasImage = question.hasImageOptions;

    return Container(
      constraints: const BoxConstraints(
        minWidth: 0,
        minHeight: 0,
        maxWidth: _slotWidth,
        maxHeight: _slotHeight,
      ),
      padding: const EdgeInsets.all(6),
      decoration: _getChipDecoration(isDragging),
      alignment: Alignment.center,
      child: hasImage ? _buildImageOption(option) : _buildTextOption(option),
    );
  }

  Widget _buildImageOption(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 118,
        height: 38,
        fit: BoxFit.contain,
        errorBuilder:
            (context, error, stackTrace) =>
                const Icon(Icons.broken_image, color: Colors.white),
        cacheWidth: 236,
        cacheHeight: 76,
      ),
    );
  }

  Widget _buildTextOption(String option) {
    return Text(
      option,
      style: const TextStyle(color: Colors.white),
      textAlign: TextAlign.center,
    );
  }

  BoxDecoration _getChipDecoration(bool isDragging) {
    return BoxDecoration(
      color: isDragging ? Colors.blue[200] : Colors.blue,
      borderRadius: BorderRadius.circular(12),
      boxShadow:
          isDragging
              ? [
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ]
              : [],
    );
  }
}
