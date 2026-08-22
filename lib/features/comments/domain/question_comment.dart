enum CommentLinkProvider {
  youtube,
  tiktok;

  static CommentLinkProvider fromApiValue(String value) {
    return switch (value) {
      'youtube' => CommentLinkProvider.youtube,
      'tiktok' => CommentLinkProvider.tiktok,
      _ => throw FormatException('Unknown comment link provider: $value'),
    };
  }
}

final class QuestionComment {
  const QuestionComment({
    required this.id,
    required this.questionId,
    required this.authorUserId,
    required this.authorDisplayName,
    required this.body,
    required this.externalUrl,
    required this.linkProvider,
    required this.isOwnComment,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String questionId;
  final String authorUserId;
  final String authorDisplayName;
  final String body;
  final String? externalUrl;
  final CommentLinkProvider? linkProvider;
  final bool isOwnComment;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasExternalLink => externalUrl != null && linkProvider != null;

  factory QuestionComment.fromJson(Map<String, dynamic> json) {
    final externalUrl = json['external_url'] as String?;
    final providerValue = json['link_provider'] as String?;

    if ((externalUrl == null) != (providerValue == null)) {
      throw const FormatException('Invalid comment link response.');
    }

    return QuestionComment(
      id: json['comment_id'] as String,
      questionId: json['question_id'] as String,
      authorUserId: json['author_user_id'] as String,
      authorDisplayName: json['author_display_name'] as String,
      body: json['body'] as String,
      externalUrl: externalUrl,
      linkProvider: providerValue == null
          ? null
          : CommentLinkProvider.fromApiValue(providerValue),
      isOwnComment: json['is_own_comment'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
