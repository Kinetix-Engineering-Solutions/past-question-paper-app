import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/providers/auth_providers.dart';
import 'package:past_question_paper_v1/viewmodels/auth_viewmodel.dart';

class SessionHistoryEntry {
  SessionHistoryEntry({
    required this.id,
    required this.subject,
    required this.mode,
    required this.score,
    required this.totalMarks,
    required this.grade,
    required this.totalQuestions,
    required this.completedAt,
    required this.percentage,
    required this.metadata,
    required this.statistics,
    this.paper,
    this.durationMinutes,
    this.sessionDurationSeconds,
  });

  factory SessionHistoryEntry.fromMap(Map<String, dynamic> data) {
    final metadata = _castMap(data['metadata']);
    final statistics = _castMap(data['statistics']);
    final sessionMetadata = _castMap(metadata['sessionMetadata']);

    final fallbackPrimary = _tryParseDate(data['savedAt']);
    final fallbackSecondary =
        _tryParseDate(metadata['submittedAt']) ??
        _tryParseDate(data['gradedAt']);

    final completedAt = _resolveDate(
      data['testDate'],
      fallback: fallbackPrimary,
      secondaryFallback: fallbackSecondary,
    );

    final double percentageValue;
    final percentageRaw = data['percentage'] ?? statistics['percentage'];
    if (percentageRaw is num) {
      percentageValue = percentageRaw.toDouble();
    } else if (percentageRaw is String) {
      percentageValue = double.tryParse(percentageRaw) ?? 0;
    } else {
      percentageValue = 0;
    }

    final scoreRaw = data['score'] ?? statistics['marksAwarded'];
    final totalMarksRaw = data['totalMarks'] ?? statistics['totalMarks'];
    final totalQuestionsRaw =
        data['totalQuestions'] ?? statistics['totalQuestions'];

    return SessionHistoryEntry(
      id: data['id']?.toString() ?? '',
      subject:
          (data['subject'] ??
                  metadata['subject'] ??
                  statistics['subject'] ??
                  'Unknown')
              .toString(),
      paper: _stringOrNull(
        data['paper'] ?? metadata['paper'] ?? statistics['paper'],
      ),
      mode: (data['mode'] ?? metadata['mode'] ?? 'Practice').toString(),
      score: _toInt(scoreRaw),
      totalMarks: _toInt(totalMarksRaw),
      grade: (data['grade'] ?? statistics['grade'] ?? 'N/A').toString(),
      totalQuestions: _toInt(totalQuestionsRaw),
      completedAt: completedAt,
      percentage: percentageValue,
      durationMinutes: _toInt(
        metadata['durationMinutes'] ?? sessionMetadata['duration'],
      ),
      sessionDurationSeconds: _toInt(
        metadata['sessionDurationSeconds'] ??
            sessionMetadata['sessionDurationSeconds'],
      ),
      metadata: metadata,
      statistics: statistics,
    );
  }

  final String id;
  final String subject;
  final String? paper;
  final String mode;
  final int score;
  final int totalMarks;
  final String grade;
  final int totalQuestions;
  final DateTime completedAt;
  final double percentage;
  final int? durationMinutes;
  final int? sessionDurationSeconds;
  final Map<String, dynamic> metadata;
  final Map<String, dynamic> statistics;

  bool get isPastPaper {
    final flags = _castMap(metadata['flags']);
    final sessionFlags = _castMap(
      _castMap(metadata['sessionMetadata'])['flags'],
    );
    return flags['isPQPMode'] == true ||
        sessionFlags['isPQPMode'] == true ||
        mode.toLowerCase().contains('full');
  }

  bool get isSprint {
    final flags = _castMap(metadata['flags']);
    final sessionFlags = _castMap(
      _castMap(metadata['sessionMetadata'])['flags'],
    );
    return flags['isSprintMode'] == true ||
        sessionFlags['isSprintMode'] == true ||
        mode.toLowerCase().contains('quick');
  }

  String get modeLabel {
    if (isPastPaper) return 'Past Paper';
    if (isSprint) return 'Sprint';
    if (mode.toLowerCase().contains('topic')) return 'By Topic';
    return mode;
  }

  Duration? get configuredDuration =>
      durationMinutes != null ? Duration(minutes: durationMinutes!) : null;

  Duration? get sessionDuration => sessionDurationSeconds != null
      ? Duration(seconds: sessionDurationSeconds!)
      : null;

  static Map<String, dynamic> _castMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    final stringValue = value.toString().trim();
    return stringValue.isEmpty ? null : stringValue;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _tryParseDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static DateTime _resolveDate(
    dynamic value, {
    DateTime? fallback,
    DateTime? secondaryFallback,
  }) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return fallback ?? secondaryFallback ?? DateTime.now();
  }
}

final sessionHistoryViewModelProvider =
    AutoDisposeAsyncNotifierProvider<
      SessionHistoryViewModel,
      List<SessionHistoryEntry>
    >(SessionHistoryViewModel.new);

class SessionHistoryViewModel
    extends AutoDisposeAsyncNotifier<List<SessionHistoryEntry>> {
  String? _currentUserId;

  @override
  Future<List<SessionHistoryEntry>> build() async {
    final authState = ref.watch(authViewModelProvider);
    final userId = authState.maybeWhen(
      data: (user) => user?.id,
      orElse: () => null,
    );
    _currentUserId = userId;

    print('🚀 SessionHistoryViewModel.build() - userId: $userId');

    if (userId == null || userId.isEmpty) {
      print('⚠️ SessionHistoryViewModel: No userId, returning empty list');
      return <SessionHistoryEntry>[];
    }

    return _fetchHistory(userId);
  }

  Future<void> refresh() async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      state = const AsyncValue.data(<SessionHistoryEntry>[]);
      return;
    }

    state = const AsyncValue.loading();
    final next = await AsyncValue.guard(() => _fetchHistory(userId));
    state = next;
  }

  Future<List<SessionHistoryEntry>> _fetchHistory(String userId) async {
    print('🔍 SessionHistoryViewModel: Fetching history for userId: $userId');
    final database = ref.read(firestoreDatabaseProvider);
    final rawResults = await database.getUserTestResults(userId);
    print(
      '📦 SessionHistoryViewModel: Received ${rawResults.length} raw results from Firestore',
    );

    if (rawResults.isNotEmpty) {
      print('📄 First result sample: ${rawResults.first}');
    }

    final entries = rawResults
        .map((result) => SessionHistoryEntry.fromMap(result))
        .where((entry) => entry.id.isNotEmpty)
        .toList();

    print('✅ SessionHistoryViewModel: Parsed ${entries.length} valid entries');
    entries.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return entries;
  }
}
