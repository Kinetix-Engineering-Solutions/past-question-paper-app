final class CommunityGuidelinesStatus {
  const CommunityGuidelinesStatus({
    required this.version,
    required this.isAccepted,
    required this.acceptedAt,
  });

  final String version;
  final bool isAccepted;
  final DateTime? acceptedAt;

  factory CommunityGuidelinesStatus.fromJson(Map<String, dynamic> json) {
    final version = json['guidelines_version'];
    final isAccepted = json['is_accepted'];
    final acceptedAtValue = json['accepted_at'];

    if (version is! String ||
        version.isEmpty ||
        isAccepted is! bool ||
        acceptedAtValue is! String? ||
        (isAccepted && acceptedAtValue == null)) {
      throw const FormatException('Invalid Community Guidelines response.');
    }

    return CommunityGuidelinesStatus(
      version: version,
      isAccepted: isAccepted,
      acceptedAt: acceptedAtValue == null
          ? null
          : DateTime.parse(acceptedAtValue),
    );
  }
}
