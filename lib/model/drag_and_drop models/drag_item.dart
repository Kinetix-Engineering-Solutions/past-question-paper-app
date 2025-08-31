class DragItem {
  final String id;
  final String? text;
  final String? image;

  DragItem({required this.id, this.text, this.image});

  factory DragItem.fromMap(Map<String, dynamic> map) {
    return DragItem(id: map['id'], text: map['text'], image: map['image']);
  }
}


