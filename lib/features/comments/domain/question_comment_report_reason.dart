enum QuestionCommentReportReason {
  spam,
  harassment,
  inappropriate,
  misleading,
  other;

  String get apiValue => name;

  String get label {
    return switch (this) {
      QuestionCommentReportReason.spam => 'Spam',
      QuestionCommentReportReason.harassment => 'Harassment',
      QuestionCommentReportReason.inappropriate => 'Inappropriate content',
      QuestionCommentReportReason.misleading => 'Misleading information',
      QuestionCommentReportReason.other => 'Other',
    };
  }
}
