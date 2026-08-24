import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'models/discovery_data.dart';
import 'models/subject.dart';
import 'models/topic.dart';

final class DiscoveryRepository {
  const DiscoveryRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<DiscoveryData> getGrade12Discovery() async {
    final responses = await Future.wait<Object?>([
      _apiClient.get('/api/subjects'),
      _apiClient.get('/api/topics', queryParameters: const {'grade': '12'}),
    ]);

    final subjects = _parseList(responses[0], Subject.fromJson, 'subjects');

    final topics = _parseList(responses[1], Topic.fromJson, 'topics');

    final subjectIds = subjects.map((subject) => subject.id).toSet();

    final hasUnknownSubject = topics.any(
      (topic) => !subjectIds.contains(topic.subjectId),
    );

    if (hasUnknownSubject) {
      throw const ApiException(
        type: ApiFailureType.invalidResponse,
        message: 'The server returned inconsistent discovery data.',
      );
    }

    return DiscoveryData(subjects: subjects, topics: topics);
  }

  List<T> _parseList<T>(
    Object? value,
    T Function(Map<String, Object?> json) fromJson,
    String resourceName,
  ) {
    if (value is! List) {
      throw ApiException(
        type: ApiFailureType.invalidResponse,
        message: 'The server returned invalid $resourceName data.',
      );
    }

    final items = <T>[];

    for (final item in value) {
      if (item is! Map) {
        throw ApiException(
          type: ApiFailureType.invalidResponse,
          message: 'The server returned invalid $resourceName data.',
        );
      }

      try {
        items.add(fromJson(Map<String, Object?>.from(item)));
      } on FormatException {
        throw ApiException(
          type: ApiFailureType.invalidResponse,
          message: 'The server returned invalid $resourceName data.',
        );
      }
    }

    return items;
  }
}
