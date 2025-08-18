import 'package:flutter/material.dart';
import 'package:past_question_paper_stem/widgets/drag_and_drop/drag_item_image.dart';
import 'package:past_question_paper_stem/widgets/latex_text.dart';
import 'package:past_question_paper_stem/utils/app_colors.dart';

class DropTargetSlot extends StatelessWidget {
  final dynamic dropTarget;
  final dynamic dragItem;
  final Function(String) onTap;
  final Function(String) onRemove;

  const DropTargetSlot({
    super.key,
    required this.dropTarget,
    required this.dragItem,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => onTap(dropTarget.id),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                dragItem != null
                    ? AppColors.neutralMid.withOpacity(0.25)
                    : AppColors.paper,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: dragItem != null ? AppColors.ink : AppColors.neutralMid,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(flex: 2, child: _buildTargetContent()),
              Expanded(
                flex: 3,
                child:
                    dragItem != null ? _buildMatchedItem() : _buildEmptySlot(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dropTarget.image != null) ...[
          DragItemImage(imageUrl: dropTarget.image!),
          const SizedBox(height: 8),
        ],
        LatexText(
          dropTarget.text ?? 'Target ${dropTarget.id}',
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          textColor: AppColors.ink,
        ),
      ],
    );
  }

  Widget _buildMatchedItem() {
    return Row(
      children: [
        if (dragItem.image != null) ...[
          DragItemImage(imageUrl: dragItem.image!),
          const Spacer(),
        ] else ...[
          Expanded(
            child: LatexText(
              dragItem.text ?? 'Item ${dragItem.id}',
              textStyle: const TextStyle(fontWeight: FontWeight.w500),
              textColor: AppColors.ink,
            ),
          ),
        ],
        GestureDetector(
          onTap: () => onRemove(dropTarget.id),
          child: Icon(Icons.close, size: 16, color: Colors.red.shade600),
        ),
      ],
    );
  }

  Widget _buildEmptySlot() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        'Drop here',
        style: TextStyle(
          color: Colors.grey.shade500,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
