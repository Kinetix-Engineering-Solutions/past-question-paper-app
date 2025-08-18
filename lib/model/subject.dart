class Subject {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> gradeIds; // Grades this subject is available for
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.gradeIds,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create a Subject from JSON data
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      gradeIds: List<String>.from(json['gradeIds'] ?? []),
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

  // Convert Subject to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'gradeIds': gradeIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Copy with method
  Subject copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    List<String>? gradeIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      gradeIds: gradeIds ?? this.gradeIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ description.hashCode ^ imageUrl.hashCode;

  // Common STEM subjects
  static List<Subject> get defaultSubjects {
    final now = DateTime.now();
    return [
      Subject(
        id: 'math',
        name: 'Mathematics',
        description: 'Pure and Applied Mathematics',
        imageUrl: 'gs://your-bucket/icons/math.png',
        gradeIds: ['grade-8', 'grade-9', 'grade-10', 'grade-11', 'grade-12'],
        createdAt: now,
        updatedAt: now,
      ),
      Subject(
        id: 'physics',
        name: 'Physics',
        description: 'Physical Sciences and Engineering',
        imageUrl: 'gs://your-bucket/icons/physics.png',
        gradeIds: ['grade-9', 'grade-10', 'grade-11', 'grade-12'],
        createdAt: now,
        updatedAt: now,
      ),
      Subject(
        id: 'chemistry',
        name: 'Chemistry',
        description: 'Chemical Sciences and Laboratory',
        imageUrl: 'gs://your-bucket/icons/chemistry.png',
        gradeIds: ['grade-9', 'grade-10', 'grade-11', 'grade-12'],
        createdAt: now,
        updatedAt: now,
      ),
      Subject(
        id: 'biology',
        name: 'Biology',
        description: 'Life Sciences and Natural Sciences',
        imageUrl: 'gs://your-bucket/icons/biology.png',
        gradeIds: ['grade-9', 'grade-10', 'grade-11', 'grade-12'],
        createdAt: now,
        updatedAt: now,
      ),
      Subject(
        id: 'computer-science',
        name: 'Computer Science',
        description: 'Programming and Information Technology',
        imageUrl: 'gs://your-bucket/icons/computer.png',
        gradeIds: ['grade-10', 'grade-11', 'grade-12'],
        createdAt: now,
        updatedAt: now,
      ),
      Subject(
        id: 'geography',
        name: 'Geography',
        description: 'Physical and Human Geography',
        imageUrl: 'gs://your-bucket/icons/geography.png',
        gradeIds: ['grade-8', 'grade-9', 'grade-10', 'grade-11', 'grade-12'],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
