import 'package:flutter/material.dart';
import 'package:past_question_paper_stem/model/drag_and_drop%20models/drag_Item.dart';
import 'package:past_question_paper_stem/model/drag_and_drop%20models/drop_target.dart';
import 'package:past_question_paper_stem/widgets/firebase_image.dart';

class DropTargetWidget extends StatelessWidget {
  final DropTarget target;
  final DragItem? placedItem;
  final bool isCorrect;
  final bool isIncorrect;
  final bool isHovering;
  final VoidCallback? onRemoveItem;

  const DropTargetWidget({
    Key? key,
    required this.target,
    this.placedItem,
    this.isCorrect = false,
    this.isIncorrect = false,
    this.isHovering = false,
    this.onRemoveItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _getBorderColor(), width: 2),
        borderRadius: BorderRadius.circular(8),
        color: _getBackgroundColor(),
      ),
      child: placedItem != null ? _buildPlacedContent() : _buildEmptyContent(),
    );
  }

  Color _getBorderColor() {
    if (isCorrect) return Colors.green.shade600;
    if (isIncorrect) return Colors.red.shade600;
    if (isHovering) return Colors.blue.shade400;
    return Colors.grey.shade300;
  }

  Color _getBackgroundColor() {
    if (isCorrect) return Colors.green.shade50;
    if (isIncorrect) return Colors.red.shade50;
    if (isHovering) return Colors.blue.shade50;
    return Colors.white;
  }

  Widget _buildEmptyContent() {
    Widget content;

    if (target.text != null) {
      content = Text(
        target.text!,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
        textAlign: TextAlign.center,
      );
    } else if (target.image != null) {
      content = FirebaseImage(
        imageUrl: target.image!,
        width: 60,
        height: 60,
        iconColor: Colors.grey,
      );
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.place_outlined, color: Colors.grey.shade500, size: 24),
          SizedBox(height: 4),
          Text(
            'Drop Here',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      constraints: BoxConstraints(minWidth: 120, minHeight: 80),
      child: Center(child: content),
    );
  }

  Widget _buildPlacedContent() {
    Widget content;

    if (placedItem!.text != null) {
      content = Text(
        placedItem!.text!,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color:
              isCorrect
                  ? Colors.green.shade800
                  : isIncorrect
                  ? Colors.red.shade800
                  : Colors.blue.shade800,
        ),
        textAlign: TextAlign.center,
      );
    } else if (placedItem!.image != null) {
      content = FirebaseImage(
        imageUrl: placedItem!.image!,
        width: 50,
        height: 50,
        iconColor:
            isCorrect
                ? Colors.green.shade800
                : isIncorrect
                ? Colors.red.shade800
                : Colors.blue.shade800,
      );
    } else {
      content = Icon(
        isCorrect
            ? Icons.check_circle
            : isIncorrect
            ? Icons.cancel
            : Icons.check_circle_outline,
        color:
            isCorrect
                ? Colors.green.shade800
                : isIncorrect
                ? Colors.red.shade800
                : Colors.blue.shade800,
        size: 32,
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      constraints: BoxConstraints(minWidth: 120, minHeight: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          SizedBox(height: 8),
          GestureDetector(
            onTap: onRemoveItem,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Remove',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
