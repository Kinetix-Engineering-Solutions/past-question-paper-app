import 'package:flutter/material.dart';
import 'package:past_question_paper_stem/model/drag_and_drop%20models/drag_Item.dart';
import 'package:past_question_paper_stem/widgets/firebase_image.dart';

class DragItemWidget extends StatelessWidget {
  final DragItem item;
  final bool isBeingDragged;

  const DragItemWidget({
    super.key,
    required this.item,
    this.isBeingDragged = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (item.text != null) {
      content = Text(
        item.text!,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      );
    } else if (item.image != null) {
      content = FirebaseImage(
        imageUrl: item.image!,
        width: 140,
        height: 40,
        iconColor: Colors.white,
      );
    } else {
      content = Icon(Icons.drag_indicator, color: Colors.white, size: 24);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:
            isBeingDragged
                ? Colors.blue.shade400
                : const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isBeingDragged ? 0.2 : 0.1),
            blurRadius: isBeingDragged ? 6 : 4,
            offset: Offset(0, isBeingDragged ? 4 : 2),
          ),
        ],
      ),
      child: content,
    );
  }
}
