import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'package:past_question_paper_v1/model/drag_and_drop models/drag_item.dart';
import 'package:past_question_paper_v1/model/drag_and_drop models/drop_target.dart';
import 'package:past_question_paper_v1/viewmodels/practice_viewmodel.dart';
import 'package:past_question_paper_v1/widgets/latex_text.dart';

class DragAndDropWidget extends ConsumerStatefulWidget {
  final Question question;
  final Map<String, String>? currentAnswers;

  const DragAndDropWidget({
    Key? key,
    required this.question,
    this.currentAnswers,
  }) : super(key: key);

  @override
  ConsumerState<DragAndDropWidget> createState() => _DragAndDropWidgetState();
}

class _DragAndDropWidgetState extends ConsumerState<DragAndDropWidget> {
  Map<String, String> _dragTargetAssignments = {}; // targetId -> dragItemId
  late ColorScheme _colorScheme;
  late TextTheme _textTheme;

  @override
  void initState() {
    super.initState();
    _dragTargetAssignments = Map.from(widget.currentAnswers ?? {});
  }

  void _onDragItemAccepted(String targetId, String dragItemId) {
    setState(() {
      // Remove the item from any previous target
      _dragTargetAssignments.removeWhere((key, value) => value == dragItemId);
      // Assign to new target
      _dragTargetAssignments[targetId] = dragItemId;
    });

    // Save answer in the format the viewmodel expects
    final answerString = _dragTargetAssignments.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .join(',');

    ref
        .read(practiceViewModelProvider.notifier)
        .answerQuestion(widget.question.id, answerString);
  }

  void _onDragItemRemoved(String targetId) {
    setState(() {
      _dragTargetAssignments.remove(targetId);
    });

    final answerString = _dragTargetAssignments.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .join(',');

    ref
        .read(practiceViewModelProvider.notifier)
        .answerQuestion(widget.question.id, answerString);
  }

  @override
  Widget build(BuildContext context) {
    _colorScheme = Theme.of(context).colorScheme;
    _textTheme = Theme.of(context).textTheme;
    // TEMPORARY: Skip validation check for debugging
    if (!widget.question.hasDragDropData) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _colorScheme.error),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: _colorScheme.error, size: 32),
            const SizedBox(height: 12),
            Text(
              'Missing Drag and Drop Data',
              style: TextStyle(
                color: _colorScheme.onErrorContainer,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'dragItems: ${widget.question.dragItems?.length ?? 0}, dragTargets: ${widget.question.dragTargets?.length ?? 0}',
              style: TextStyle(color: _colorScheme.error, fontSize: 14),
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
            color: _colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.touch_app_outlined, color: _colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Drag items from below to the correct drop zones above',
                      style: _textTheme.bodyMedium?.copyWith(
                            color: _colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ) ??
                          TextStyle(
                            color: _colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.info_outline, color: _colorScheme.primary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Press and hold an item for a moment before dragging',
                      style: TextStyle(
                        color: _colorScheme.primary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Drop Targets
        Text(
          'Drop Zones:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        _buildDropTargets(),

        const SizedBox(height: 32),

        // Drag Items
        Text(
          'Drag Items:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        _buildDragItems(),

        const SizedBox(height: 16),
        _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildDropTargets() {
    final targets = widget.question.dragTargets!;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: targets.map((target) {
        final assignedItemId = _dragTargetAssignments[target.id];
        final assignedItem = assignedItemId != null
            ? widget.question.dragItems!.firstWhere(
                (item) => item.id == assignedItemId,
                orElse: () => DragItem(id: '', text: 'Unknown'),
              )
            : null;

        return _buildDropTarget(target, assignedItem);
      }).toList(),
    );
  }

  Widget _buildDropTarget(DropTarget target, DragItem? assignedItem) {
    return DragTarget<String>(
      onWillAccept: (dragItemId) => dragItemId != null,
      onAccept: (dragItemId) => _onDragItemAccepted(target.id, dragItemId),
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        final hasItem = assignedItem != null;

        return Container(
          width: 150,
          height: 120,
          decoration: BoxDecoration(
            color: isHighlighted
                ? _colorScheme.primary.withOpacity(0.12)
                : hasItem
                ? _colorScheme.primary.withOpacity(0.08)
                : _colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHighlighted
                  ? _colorScheme.primary
                  : hasItem
                  ? _colorScheme.primary.withOpacity(0.45)
                  : _colorScheme.outlineVariant,
              width: isHighlighted ? 2 : 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Target label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _colorScheme.onSurfaceVariant.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  target.text ?? target.id,
                  style: TextStyle(
                    fontSize: 12,
                    color: _colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),

              // Assigned item or placeholder
              if (hasItem)
                Expanded(
                  child: Stack(
                    children: [
                      Center(
                        child: _buildItemContent(
                          assignedItem,
                          isInDropZone: true,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _onDragItemRemoved(target.id),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: _colorScheme.onError,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Icon(
                      Icons.add,
                      color: _colorScheme.onSurfaceVariant.withOpacity(0.5),
                      size: 32,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragItems() {
    final items = widget.question.dragItems!;
    final unassignedItems = items.where((item) {
      return !_dragTargetAssignments.containsValue(item.id);
    }).toList();

    if (unassignedItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _colorScheme.tertiary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: _colorScheme.tertiary),
            const SizedBox(width: 8),
            Text(
              'All items have been placed!',
              style: TextStyle(
                color: _colorScheme.onTertiaryContainer,
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
      children: unassignedItems.map((item) => _buildDragItem(item)).toList(),
    );
  }

  Widget _buildDragItem(DragItem item) {
    return LongPressDraggable<String>(
      data: item.id,
      hapticFeedbackOnStart: true,
      delay: const Duration(milliseconds: 200),
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 120,
          height: 80,
          decoration: BoxDecoration(
            color: _colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _colorScheme.primary.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(child: _buildItemContent(item, isDragging: true)),
        ),
      ),
      childWhenDragging: Container(
        width: 120,
        height: 80,
        decoration: BoxDecoration(
          color: _colorScheme.onSurfaceVariant.withOpacity(0.24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _colorScheme.outlineVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Icon(Icons.drag_handle, color: _colorScheme.onSurfaceVariant),
        ),
      ),
      child: Container(
        width: 120,
        height: 80,
        decoration: BoxDecoration(
          color: _colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _colorScheme.outlineVariant,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _colorScheme.shadow.withOpacity(0.08),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(child: _buildItemContent(item)),
            Positioned(
              top: 4,
              right: 4,
              child: Icon(
                Icons.touch_app,
                size: 16,
                color: _colorScheme.primary.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemContent(
    DragItem item, {
    bool isDragging = false,
    bool isInDropZone = false,
  }) {
    final textColor = isDragging
        ? _colorScheme.onPrimary
        : isInDropZone
        ? _colorScheme.primary
        : _colorScheme.onSurface;

    if (item.image != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.broken_image,
                    color: textColor.withOpacity(0.7),
                  );
                },
              ),
            ),
          ),
          if (item.text != null) ...[
            const SizedBox(height: 4),
            Text(
              item.text!,
              style: TextStyle(
                fontSize: 10,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: LatexText(
          item.text ?? item.id,
          textColor: textColor,
          fontSize: 12,
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  Widget _buildProgressIndicator() {
    final totalTargets = widget.question.dragTargets!.length;
    final completedTargets = _dragTargetAssignments.length;
    final progress = totalTargets > 0 ? completedTargets / totalTargets : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _colorScheme.outlineVariant),
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
                  color: _colorScheme.onSurface,
                ),
              ),
              Text(
                '$completedTargets / $totalTargets items placed',
                style: TextStyle(
                  fontSize: 12,
                  color: _colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: _colorScheme.outlineVariant.withOpacity(0.3),
            color:
                progress == 1.0 ? _colorScheme.tertiary : _colorScheme.primary,
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
