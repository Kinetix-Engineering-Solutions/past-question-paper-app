class DragItem {
  final String id;
  final String? text;
  final String? image;

  DragItem({required this.id, this.text, this.image});

  factory DragItem.fromMap(Map<String, dynamic> map) {
    return DragItem(
      id: map['id']?.toString() ?? '',
      text: map['text']?.toString(),
      image: map['image']?.toString(),
    );
  }

  // Add a safe factory for handling potential type issues
  factory DragItem.fromDynamic(dynamic data) {
    if (data is Map) {
      // Convert any Map type to Map<String, dynamic>
      final Map<String, dynamic> stringMap = {};
      data.forEach((key, value) {
        stringMap[key.toString()] = value;
      });
      return DragItem.fromMap(stringMap);
    }
    throw ArgumentError('Invalid data type for DragItem: ${data.runtimeType}');
  }
}
