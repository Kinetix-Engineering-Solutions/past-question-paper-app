import 'package:flutter/material.dart';
import 'package:past_question_paper_stem/widgets/drag_and_drop/drag_item_image.dart';
import 'package:past_question_paper_stem/widgets/latex_text.dart';
import 'package:past_question_paper_stem/utils/app_colors.dart';

class DragItemCard extends StatelessWidget {
  final dynamic dragItem;
  final bool isUsed;
  final String? selectedAnswerId;
  final Function(String) onTap;

  const DragItemCard({
    super.key,
    required this.dragItem,
    required this.isUsed,
    required this.selectedAnswerId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUsed ? null : () => onTap(dragItem.id),
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dragItem.image != null)
              _buildImageContent()
            else
              _buildTextContent(),
            if (isUsed) ...[
              const SizedBox(width: 8),
              Icon(Icons.check_circle, size: 20, color: Colors.green.shade600),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border:
            selectedAnswerId == dragItem.id
                ? Border.all(color: AppColors.ink, width: 3)
                : Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: DragItemImage(imageUrl: dragItem.image!),
      ),
    );
  }

  Widget _buildTextContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getBorderColor(),
          width: selectedAnswerId == dragItem.id ? 2 : 1,
        ),
      ),
      child: LatexText(
        dragItem.text ?? 'Item ${dragItem.id}',
        textStyle: TextStyle(fontWeight: FontWeight.w500),
        textColor: _getTextColor(),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isUsed) return Colors.grey.shade300;
    if (selectedAnswerId == dragItem.id) return AppColors.accent;
    return AppColors.neutralCard;
  }

  Color _getBorderColor() {
    if (isUsed) return Colors.grey.shade400;
    if (selectedAnswerId == dragItem.id) return AppColors.ink;
    return AppColors.neutralMid;
  }

  Color _getTextColor() {
    if (isUsed) return Colors.grey.shade600;
    if (selectedAnswerId == dragItem.id) return AppColors.neutralCard;
    return AppColors.ink;
  }
}
