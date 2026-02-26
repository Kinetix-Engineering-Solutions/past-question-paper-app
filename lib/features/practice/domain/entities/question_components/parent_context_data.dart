class ParentContextData {
  final String? parentQuestionId;
  final bool usesParentImage;
  final Map<String, dynamic>? parentContext;

  const ParentContextData({
    this.parentQuestionId,
    this.usesParentImage = false,
    this.parentContext,
  });

  bool get hasParent =>
      parentQuestionId != null && parentQuestionId!.isNotEmpty;

  String? displayImageUrl(String? imageUrl) {
    if (usesParentImage && parentContext != null) {
      return parentContext!['imageUrl'] as String?;
    }
    return imageUrl;
  }

  String? get parentQuestionText => parentContext?['questionText'] as String?;

  String? get parentQuestionNumber =>
      parentContext?['pqpData']?['questionNumber'] as String?;
}
