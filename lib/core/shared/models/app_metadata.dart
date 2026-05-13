class AppMetadata {
  final String version;
  final DateTime lastUpdated;
  final List<AppSubjectConfig> subjects;

  const AppMetadata({
    required this.version,
    required this.lastUpdated,
    required this.subjects,
  });

  factory AppMetadata.fromJson(Map<String, dynamic> json) {
    final subjectsRaw = json['subjects'];
    final subjects = (subjectsRaw is List)
        ? subjectsRaw
              .whereType<Map>()
              .map(
                (item) =>
                    AppSubjectConfig.fromJson(item.cast<String, dynamic>()),
              )
              .toList()
        : <AppSubjectConfig>[];

    final lastUpdatedString = (json['last_updated'] ?? '').toString();
    final parsedLastUpdated = DateTime.tryParse(lastUpdatedString);

    return AppMetadata(
      version: (json['version'] ?? '').toString(),
      lastUpdated:
          parsedLastUpdated?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      subjects: subjects,
    );
  }
}

class AppSubjectConfig {
  final String name;
  final String? iconUrl;
  final List<String> topics;

  const AppSubjectConfig({
    required this.name,
    required this.iconUrl,
    required this.topics,
  });

  String get id => _toSubjectId(name);

  static String _toSubjectId(String name) {
    return name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  }

  factory AppSubjectConfig.fromJson(Map<String, dynamic> json) {
    final topicsRaw = json['topics'];
    final topics = (topicsRaw is List)
        ? topicsRaw
              .map((e) => e?.toString().trim() ?? '')
              .where((e) => e.isNotEmpty)
              .toList()
        : <String>[];

    final icon = (json['icon_url'] ?? '').toString().trim();

    return AppSubjectConfig(
      name: (json['name'] ?? '').toString(),
      iconUrl: icon.isEmpty ? null : icon,
      topics: topics,
    );
  }
}
