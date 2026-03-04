import 'package:past_question_paper_v1/features/practice/domain/entities/drag_drop/drag_item.dart';
import 'package:past_question_paper_v1/features/practice/domain/entities/drag_drop/drop_target.dart';

class DragDropData {
  final String format;
  final List<DragItem>? dragItems;
  final List<DropTarget>? dragTargets;

  const DragDropData({required this.format, this.dragItems, this.dragTargets});

  bool get isDragAndDrop => format == 'drag-and-drop';

  bool get hasDragDropData =>
      isDragAndDrop &&
      dragItems != null &&
      dragTargets != null &&
      dragItems!.isNotEmpty &&
      dragTargets!.isNotEmpty;
}
