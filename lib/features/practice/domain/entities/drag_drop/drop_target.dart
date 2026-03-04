class DropTarget {
  final String id;
  final String? text;
  final String? image;
  final String correctPair;

  DropTarget({
    required this.id,
    this.text,
    this.image,
    required this.correctPair,
  });

  factory DropTarget.fromMap(Map<String, dynamic> map) {
    return DropTarget(
      id: map['id']?.toString() ?? '',
      text: map['text']?.toString(),
      image: map['image']?.toString(),
      correctPair: map['correctPair']?.toString() ?? '',
    );
  }

  // Add a safe factory for handling potential type issues
  factory DropTarget.fromDynamic(dynamic data) {
    if (data is Map) {
      // Convert any Map type to Map<String, dynamic>
      final Map<String, dynamic> stringMap = {};
      data.forEach((key, value) {
        stringMap[key.toString()] = value;
      });
      return DropTarget.fromMap(stringMap);
    }
    throw ArgumentError(
      'Invalid data type for DropTarget: ${data.runtimeType}',
    );
  }
}
