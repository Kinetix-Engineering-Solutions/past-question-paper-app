final class BlockedLearner {
  const BlockedLearner({
    required this.userId,
    required this.displayName,
    required this.blockedAt,
  });

  final String userId;
  final String displayName;
  final DateTime blockedAt;

  factory BlockedLearner.fromJson(Map<String, dynamic> json) {
    final userId = json['blocked_user_id'];
    final displayName = json['display_name'];
    final blockedAt = json['blocked_at'];

    if (userId is! String ||
        userId.isEmpty ||
        displayName is! String ||
        displayName.isEmpty ||
        blockedAt is! String) {
      throw const FormatException('Invalid blocked learner response.');
    }

    return BlockedLearner(
      userId: userId,
      displayName: displayName,
      blockedAt: DateTime.parse(blockedAt),
    );
  }
}
