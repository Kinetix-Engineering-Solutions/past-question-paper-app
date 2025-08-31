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
      id: map['id'],
      text: map['text'],
      image: map['image'],
      correctPair: map['correctPair'],
    );
  }
}


