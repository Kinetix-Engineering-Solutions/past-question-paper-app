class Grade {
  final String id;
  final String name;
  final int level;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Grade({
    required this.id,
    required this.name,
    required this.level,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create a Grade from JSON data
  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'] as String,
      name: json['name'] as String,
      level: json['level'] as int,
      description: json['description'] as String,
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

  // Convert Grade to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Copy with method
  Grade copyWith({
    String? id,
    String? name,
    int? level,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Grade(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Grade &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          level == other.level &&
          description == other.description;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ level.hashCode ^ description.hashCode;

  // Default grades for common educational systems
  static List<Grade> get defaultGrades {
    final now = DateTime.now();
    return [
      Grade(
        id: 'grade-8',
        name: 'Grade 8',
        level: 8,
        description: 'Junior Secondary School Grade 8',
        createdAt: now,
        updatedAt: now,
      ),
      Grade(
        id: 'grade-9',
        name: 'Grade 9',
        level: 9,
        description: 'Junior Secondary School Grade 9',
        createdAt: now,
        updatedAt: now,
      ),
      Grade(
        id: 'grade-10',
        name: 'Grade 10',
        level: 10,
        description: 'Senior Secondary School Grade 10',
        createdAt: now,
        updatedAt: now,
      ),
      Grade(
        id: 'grade-11',
        name: 'Grade 11',
        level: 11,
        description: 'Senior Secondary School Grade 11',
        createdAt: now,
        updatedAt: now,
      ),
      Grade(
        id: 'grade-12',
        name: 'Grade 12',
        level: 12,
        description: 'Senior Secondary School Grade 12',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
