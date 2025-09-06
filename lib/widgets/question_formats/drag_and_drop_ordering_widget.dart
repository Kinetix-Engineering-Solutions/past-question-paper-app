import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'package:past_question_paper_v1/model/drag_and_drop models/drag_item.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/viewmodels/practice_viewmodel.dart';
import 'package:past_question_paper_v1/widgets/latex_text.dart';

class DragAndDropOrderingWidget extends ConsumerStatefulWidget {
  final Question question;
  final String? currentAnswer;

  const DragAndDropOrderingWidget({
    Key? key,
    required this.question,
    this.currentAnswer,
  }) : super(key: key);

  @override
  ConsumerState<DragAndDropOrderingWidget> createState() =>
      _DragAndDropOrderingWidgetState();
}

class _DragAndDropOrderingWidgetState
    extends ConsumerState<DragAndDropOrderingWidget> {
  List<DragItem> _orderedSteps = [];
  List<DragItem> _availableItems = [];

  @override
  void initState() {
    super.initState();
    _initializeItems();
  }

  void _initializeItems() {
    // Handle cases where dragItems might be null but correctOrder exists
    if (widget.question.dragItems != null &&
        widget.question.dragItems!.isNotEmpty) {
      _availableItems = List.from(widget.question.dragItems!);
    } else if (widget.question.correctOrder.isNotEmpty) {
      // Create drag items from correctOrder if dragItems is not available
      _availableItems = widget.question.correctOrder
          .map((stepId) => DragItem(id: stepId, text: stepId))
          .toList();
    } else {
      // Fallback: create from options if available
      _availableItems = widget.question.options
          .asMap()
          .entries
          .map(
            (entry) => DragItem(id: 'option_${entry.key}', text: entry.value),
          )
          .toList();
    }

    // Parse existing answer if available
    if (widget.currentAnswer != null && widget.currentAnswer!.isNotEmpty) {
      try {
        final steps = widget.currentAnswer!.split(',');
        for (final stepId in steps) {
          final item = _availableItems.firstWhere(
            (item) => item.id == stepId.trim(),
            orElse: () => DragItem(id: stepId, text: stepId),
          );
          _orderedSteps.add(item);
          _availableItems.removeWhere(
            (available) => available.id == stepId.trim(),
          );
        }
      } catch (e) {
        print('Error parsing current answer: $e');
      }
    }

    // Delay saving to avoid modifying provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveAnswer();
    });
  }

  void _addStep(DragItem item) {
    setState(() {
      _orderedSteps.add(item);
      _availableItems.removeWhere((available) => available.id == item.id);
    });
    _saveAnswer();
  }

  void _removeStep(int index) {
    setState(() {
      final removedItem = _orderedSteps.removeAt(index);
      _availableItems.add(removedItem);
    });
    _saveAnswer();
  }

  void _reorderSteps(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _orderedSteps.removeAt(oldIndex);
      _orderedSteps.insert(newIndex, item);
    });
    _saveAnswer();
  }

  void _saveAnswer() {
    final answerString = _orderedSteps.map((item) => item.id).join(',');
    ref
        .read(practiceViewModelProvider.notifier)
        .answerQuestion(widget.question.id, answerString);
  }

  @override
  Widget build(BuildContext context) {
    // Check if we have any data to work with for ordering
    final hasOrderingData =
        (widget.question.dragItems != null &&
            widget.question.dragItems!.isNotEmpty) ||
        widget.question.correctOrder.isNotEmpty ||
        widget.question.options.isNotEmpty;

    if (!hasOrderingData) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 32),
            const SizedBox(height: 12),
            Text(
              'Missing Step Ordering Data',
              style: TextStyle(
                color: Colors.red.shade800,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This question requires drag items for step ordering.',
              style: TextStyle(color: Colors.red.shade600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instructions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.list_alt, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Arrange the steps below in the correct order to solve the problem',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Ordered Steps Area
        Text(
          'Your Solution Steps (in order):',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 12),
        _buildOrderedStepsArea(),

        const SizedBox(height: 32),

        // Available Items
        Text(
          'Available Steps:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 12),
        _buildAvailableItems(),

        const SizedBox(height: 16),
        _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildOrderedStepsArea() {
    if (_orderedSteps.isEmpty) {
      return Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.neutralCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutralBorder),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.list_alt, color: AppColors.neutralMid, size: 32),
              const SizedBox(height: 8),
              Text(
                'Drag steps here to arrange them in order',
                style: TextStyle(color: AppColors.neutralMid, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutralCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        onReorder: _reorderSteps,
        itemCount: _orderedSteps.length,
        itemBuilder: (context, index) {
          final item = _orderedSteps[index];
          return _buildOrderedStepCard(item, index, key: ValueKey(item.id));
        },
      ),
    );
  }

  Widget _buildOrderedStepCard(DragItem item, int index, {required Key key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralMid.withOpacity(0.1),
            blurRadius: 2,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        title: _buildItemContent(item),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_handle, color: AppColors.neutralMid),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _removeStep(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.red.shade600, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableItems() {
    if (_availableItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const SizedBox(width: 8),
            Text(
              'All steps have been arranged!',
              style: TextStyle(
                color: Colors.green.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _availableItems
          .map((item) => _buildAvailableItemCard(item))
          .toList(),
    );
  }

  Widget _buildAvailableItemCard(DragItem item) {
    return GestureDetector(
      onTap: () => _addStep(item),
      child: Container(
        constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.neutralCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutralBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutralMid.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.accent, size: 16),
            const SizedBox(width: 8),
            Flexible(child: _buildItemContent(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemContent(DragItem item) {
    if (item.image != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              item.image!,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.broken_image,
                  color: AppColors.neutralMid,
                  size: 24,
                );
              },
            ),
          ),
          if (item.text != null) ...[
            const SizedBox(height: 4),
            Text(
              item.text!,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.ink,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      );
    } else {
      return LatexText(
        item.text ?? item.id,
        textColor: AppColors.ink,
        fontSize: 12,
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _buildProgressIndicator() {
    // Calculate total items from available sources
    final totalItems =
        widget.question.dragItems?.length ??
        widget.question.correctOrder.length;
    final arrangedItems = _orderedSteps.length;
    final progress = totalItems > 0 ? arrangedItems / totalItems : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              Text(
                '$arrangedItems / $totalItems steps arranged',
                style: TextStyle(fontSize: 12, color: AppColors.neutralMid),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.neutralBorder,
            color: progress == 1.0 ? Colors.green : AppColors.accent,
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
