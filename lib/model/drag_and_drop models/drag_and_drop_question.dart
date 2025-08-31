import 'package:past_question_paper_stem/model/drag_and_drop models/drag_item.dart';
import 'package:past_question_paper_stem/model/drag_and_drop models/drop_target.dart';

class DragDropQuestion {
  final String? questionText;
  final List<DragItem> dragItems;
  final List<DropTarget> dropTargets;

  DragDropQuestion({
    this.questionText,
    required this.dragItems,
    required this.dropTargets,
  });

  factory DragDropQuestion.fromFirestore(Map<String, dynamic> doc) {
    return DragDropQuestion(
      questionText: doc['questionText'] as String?,
      dragItems:
          (doc['dragItems'] as List<dynamic>? ?? [])
              .map((item) => DragItem.fromMap(item))
              .toList(),
      dropTargets:
          (doc['dragTargets'] as List<dynamic>? ?? [])
              .map((target) => DropTarget.fromMap(target))
              .toList(),
    );
  }
}
