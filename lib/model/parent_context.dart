/// Model for parent question context data
/// Used when a question is part of a parent-child relationship (Option 3)
class ParentContext {
  final String id;
  final String questionText;
  final String? imageUrl;
  final String? questionNumber; // For PQP mode (e.g., "6")
  final int totalMarks;
  final List<String> childQuestionIds;

  ParentContext({
    required this.id,
    required this.questionText,
    this.imageUrl,
    this.questionNumber,
    required this.totalMarks,
    required this.childQuestionIds,
  });

  /// Create from backend enriched data
  factory ParentContext.fromMap(Map<String, dynamic> data) {
    return ParentContext(
      id: data['id']?.toString() ?? '',
      questionText: data['questionText']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString(),
      questionNumber: data['pqpData']?['questionNumber']?.toString(),
      totalMarks: (data['totalMarks'] as num?)?.toInt() ?? 0,
      childQuestionIds: data['childQuestionIds'] != null
          ? List<String>.from(data['childQuestionIds'])
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'imageUrl': imageUrl,
      'questionNumber': questionNumber,
      'totalMarks': totalMarks,
      'childQuestionIds': childQuestionIds,
    };
  }

  /// Get formatted question number for display (e.g., "Question 6")
  String get displayNumber =>
      questionNumber != null ? 'Question $questionNumber' : 'Parent Question';
}
