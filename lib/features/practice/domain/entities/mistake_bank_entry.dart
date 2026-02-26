import 'package:cloud_firestore/cloud_firestore.dart';

class MistakeBankEntry {
  final String questionId;
  final String? subject;
  final int? grade;
  final String? paper;
  final String? topic;
  final int? year;
  final String? season;
  final String? format;
  final String? questionType;
  final num? marks;
  final String? pqpQuestionNumber;
  final DateTime? masteredAt;
  final DateTime? lastSeenAt;

  const MistakeBankEntry({
    required this.questionId,
    this.subject,
    this.grade,
    this.paper,
    this.topic,
    this.year,
    this.season,
    this.format,
    this.questionType,
    this.marks,
    this.pqpQuestionNumber,
    this.masteredAt,
    this.lastSeenAt,
  });

  bool get isMastered => masteredAt != null;

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  factory MistakeBankEntry.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};

    return MistakeBankEntry(
      questionId: doc.id,
      subject: data['subject'] as String?,
      grade: data['grade'] is int ? data['grade'] as int : null,
      paper: data['paper'] as String?,
      topic: data['topic'] as String?,
      year: data['year'] is int ? data['year'] as int : null,
      season: data['season'] as String?,
      format: data['format'] as String?,
      questionType: data['questionType'] as String?,
      marks: data['marks'] is num ? data['marks'] as num : null,
      pqpQuestionNumber: data['pqpQuestionNumber'] as String?,
      masteredAt: _toDateTime(data['masteredAt']),
      lastSeenAt: _toDateTime(data['lastSeenAt']),
    );
  }
}
