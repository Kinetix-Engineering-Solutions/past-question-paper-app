class Topic {
  final String id;
  final String name;
  final String description;
  final String subjectId;
  final List<String> gradeIds;
  final int order;
  final String season; // Season when topic was covered
  final DateTime createdAt;
  final DateTime updatedAt;

  const Topic({
    required this.id,
    required this.name,
    required this.description,
    required this.subjectId,
    required this.gradeIds,
    required this.order,
    required this.season,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create a Topic from JSON data
  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      subjectId: json['subjectId'] as String,
      gradeIds: List<String>.from(json['gradeIds'] ?? []),
      order: json['order'] as int? ?? 0,
      season: json['season'] as String? ?? 'Spring 2024',
      createdAt:
          json['createdAt'] is DateTime
              ? json['createdAt']
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] is DateTime
              ? json['updatedAt']
              : DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Convert Topic to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'subjectId': subjectId,
      'gradeIds': gradeIds,
      'order': order,
      'season': season,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  Topic copyWith({
    String? id,
    String? name,
    String? description,
    String? subjectId,
    List<String>? gradeIds,
    int? order,
    String? season,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Topic(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      gradeIds: gradeIds ?? this.gradeIds,
      order: order ?? this.order,
      season: season ?? this.season,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Topic(id: $id, name: $name, subjectId: $subjectId, season: $season)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Topic && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Check if topic is available for a specific grade
  bool isAvailableForGrade(String gradeId) {
    return gradeIds.contains(gradeId);
  }
}
