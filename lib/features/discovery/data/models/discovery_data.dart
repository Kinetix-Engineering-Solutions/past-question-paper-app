import 'subject.dart';
import 'topic.dart';

final class DiscoveryData {
  DiscoveryData({
    required Iterable<Subject> subjects,
    required Iterable<Topic> topics,
  }) : subjects = List.unmodifiable(subjects),
       topics = List.unmodifiable(topics);

  final List<Subject> subjects;
  final List<Topic> topics;

  bool get isEmpty => subjects.isEmpty && topics.isEmpty;

  List<Topic> topicsForSubject(String subjectId) {
    return topics
        .where((topic) => topic.subjectId == subjectId)
        .toList(growable: false);
  }
}
