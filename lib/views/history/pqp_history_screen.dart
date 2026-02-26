import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/mistake_bank_entry.dart';
import 'package:past_question_paper_v1/providers/auth_providers.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/viewmodels/session_history_viewmodel.dart';
import 'package:past_question_paper_v1/widgets/shimmer_loading.dart';
import 'package:past_question_paper_v1/widgets/empty_state.dart';

class PqpHistoryScreen extends ConsumerWidget {
  const PqpHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHistory = ref.watch(sessionHistoryViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: asyncHistory.when(
          loading: () => const _HistoryLoadingView(),
          error: (error, _) => _HistoryErrorView(
            message: error.toString(),
            onRetry: () =>
                ref.read(sessionHistoryViewModelProvider.notifier).refresh(),
          ),
          data: (entries) => _HistoryContent(
            entries: entries,
            onRefresh: () =>
                ref.read(sessionHistoryViewModelProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }
}

class _HistoryLoadingView extends StatelessWidget {
  const _HistoryLoadingView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        itemCount: 6,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => const HistoryCardShimmer(),
      ),
    );
  }
}

class _HistoryErrorView extends StatelessWidget {
  const _HistoryErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Could not load your history',
      message: message,
      actionLabel: 'Try again',
      onAction: onRetry,
    );
  }
}

class _HistoryContent extends ConsumerWidget {
  const _HistoryContent({required this.entries, required this.onRefresh});

  final List<SessionHistoryEntry> entries;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: AppColors.accent,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [_EmptyHistoryState()],
        ),
      );
    }

    final firestore = ref.watch(firestoreDatabaseProvider);
    final summary = _HistorySummary.fromEntries(entries);
    final readinessSubjects = _buildSubjectReadiness(entries);

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.accent,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          _SummaryCard(summary: summary),
          const SizedBox(height: 16),
          _ExamReadinessSection(
            subjects: readinessSubjects,
            mistakeBankStreamForSubject: (subject) =>
                firestore.watchMistakeBankEntries(subject: subject),
          ),
        ],
      ),
    );
  }

  List<_SubjectReadiness> _buildSubjectReadiness(
    List<SessionHistoryEntry> entries,
  ) {
    final bySubject = <String, List<SessionHistoryEntry>>{};
    for (final entry in entries) {
      bySubject
          .putIfAbsent(entry.subject, () => <SessionHistoryEntry>[])
          .add(entry);
    }

    final subjects = bySubject.keys.toList()..sort();
    return subjects.map((subject) {
      final subjectEntries =
          bySubject[subject] ?? const <SessionHistoryEntry>[];
      final pqpEntries = subjectEntries.where((e) => e.isPastPaper).toList();
      final recent = pqpEntries.take(5).toList();
      final last = recent.isNotEmpty ? recent.first : null;
      final previous = recent.length > 1 ? recent[1] : null;

      final averageLast3 = recent.take(3).isEmpty
          ? null
          : (recent.take(3).fold<double>(0, (sum, e) => sum + e.percentage) /
                    recent.take(3).length)
                .round();

      final lastScore = last?.percentage.round();
      final trendDelta = (last != null && previous != null)
          ? (last.percentage - previous.percentage).round()
          : null;

      return _SubjectReadiness(
        subject: subject,
        gradeLabel: last?.grade,
        lastScore: lastScore,
        averageLast3: averageLast3,
        trendDelta: trendDelta,
        pqpAttemptCount: pqpEntries.length,
      );
    }).toList();
  }
}

class _SubjectReadiness {
  const _SubjectReadiness({
    required this.subject,
    required this.gradeLabel,
    required this.lastScore,
    required this.averageLast3,
    required this.trendDelta,
    required this.pqpAttemptCount,
  });

  final String subject;
  final String? gradeLabel;
  final int? lastScore;
  final int? averageLast3;
  final int? trendDelta;
  final int pqpAttemptCount;
}

class _ExamReadinessSection extends StatelessWidget {
  const _ExamReadinessSection({
    required this.subjects,
    required this.mistakeBankStreamForSubject,
  });

  final List<_SubjectReadiness> subjects;
  final Stream<List<MistakeBankEntry>> Function(String subject)
  mistakeBankStreamForSubject;

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Exam readiness'),
        const SizedBox(height: 12),
        for (final subject in subjects) ...[
          _SubjectReadinessCard(
            readiness: subject,
            mistakesStream: mistakeBankStreamForSubject(subject.subject),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
    );
  }
}

class _SubjectReadinessCard extends StatelessWidget {
  const _SubjectReadinessCard({
    required this.readiness,
    required this.mistakesStream,
  });

  final _SubjectReadiness readiness;
  final Stream<List<MistakeBankEntry>> mistakesStream;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final lastScoreText = readiness.lastScore != null
        ? '${readiness.lastScore}%'
        : '—';
    final avgText = readiness.averageLast3 != null
        ? '${readiness.averageLast3}%'
        : '—';

    final trend = readiness.trendDelta;
    final trendText = trend == null
        ? '—'
        : (trend == 0 ? '0' : (trend > 0 ? '+$trend' : '$trend'));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: StreamBuilder<List<MistakeBankEntry>>(
        stream: mistakesStream,
        builder: (context, snapshot) {
          final mistakes = snapshot.data ?? const <MistakeBankEntry>[];
          final unmastered = mistakes.where((e) => !e.isMastered).toList();

          final hasEnoughPqpData = readiness.pqpAttemptCount >= 3;
          final avg3 = readiness.averageLast3;

          final String readinessLabel;
          final Color readinessColor;
          if (!hasEnoughPqpData || avg3 == null) {
            readinessLabel = 'Building';
            readinessColor = colorScheme.onSurfaceVariant;
          } else {
            final isReady = avg3 >= 60 && unmastered.length <= 10;
            if (isReady) {
              readinessLabel = 'Ready';
              readinessColor = AppColors.accent;
            } else {
              readinessLabel = 'Needs work';
              readinessColor = colorScheme.onSurfaceVariant;
            }
          }

          final topicCounts = <String, int>{};
          for (final entry in unmastered) {
            final topic = (entry.topic?.trim().isNotEmpty ?? false)
                ? entry.topic!.trim()
                : 'Unknown topic';
            topicCounts[topic] = (topicCounts[topic] ?? 0) + 1;
          }

          final topTopics = topicCounts.entries.toList()
            ..sort((a, b) {
              final countCompare = b.value.compareTo(a.value);
              if (countCompare != 0) return countCompare;
              return a.key.toLowerCase().compareTo(b.key.toLowerCase());
            });

          final topTopicText = topTopics.isEmpty
              ? '—'
              : topTopics.take(2).map((e) => e.key).join(' • ');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      readiness.subject,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: readinessColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: readinessColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      readinessLabel,
                      style: textTheme.labelMedium?.copyWith(
                        color: readinessColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (readiness.gradeLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        readiness.gradeLabel!,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _SummaryStat(
                    label: 'Last',
                    value: lastScoreText,
                    helper: 'PQP',
                  ),
                  const SizedBox(width: 16),
                  _SummaryStat(
                    label: 'Avg (3)',
                    value: avgText,
                    helper: 'recent',
                  ),
                  const SizedBox(width: 16),
                  _SummaryStat(
                    label: 'Trend',
                    value: trendText,
                    helper: 'vs prev',
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Based on ${readiness.pqpAttemptCount} PQP attempt${readiness.pqpAttemptCount == 1 ? '' : 's'}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${unmastered.length} unmastered mistakes',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Weak topics: $topTopicText',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (unmastered.isNotEmpty) ...[
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (unmastered.length / (mistakes.length)).clamp(0, 1),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: AppColors.accent,
                  minHeight: 6,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _HistorySummary {
  const _HistorySummary({
    required this.totalSessions,
    required this.averageScore,
    required this.bestScore,
    required this.bestGrade,
    required this.lastAttempt,
  });

  factory _HistorySummary.fromEntries(List<SessionHistoryEntry> entries) {
    final totalSessions = entries.length;
    final lastAttempt = entries.first;

    final best = entries.reduce((prev, curr) {
      final prevScore = prev.percentage;
      final currScore = curr.percentage;
      return currScore >= prevScore ? curr : prev;
    });

    final average =
        entries.fold<double>(0, (sum, entry) => sum + entry.percentage) /
        totalSessions;

    return _HistorySummary(
      totalSessions: totalSessions,
      averageScore: average,
      bestScore: best.percentage,
      bestGrade: best.grade,
      lastAttempt: lastAttempt,
    );
  }

  final int totalSessions;
  final double averageScore;
  final double bestScore;
  final String bestGrade;
  final SessionHistoryEntry lastAttempt;

  int get averageRounded => averageScore.round();
  int get bestRounded => bestScore.round();
  int get lastRounded => lastAttempt.percentage.round();
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final _HistorySummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PQP Progress Overview',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryStat(
                label: 'Sessions',
                value: summary.totalSessions.toString(),
                helper: 'completed',
              ),
              const SizedBox(width: 16),
              _SummaryStat(
                label: 'Last score',
                value: '${summary.lastRounded}%',
                helper: summary.lastAttempt.modeLabel,
              ),
              const SizedBox(width: 16),
              _SummaryStat(
                label: 'Best',
                value: '${summary.bestRounded}%',
                helper: summary.bestGrade,
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: summary.averageScore.clamp(0, 100) / 100,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: AppColors.accent,
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Text(
            'Average accuracy ${summary.averageRounded}% across ${summary.totalSessions} sessions.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.helper,
  });

  final String label;
  final String value;
  final String helper;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            helper,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.history_edu_outlined,
      title: 'No practice history yet',
      message:
          'Complete a session in any mode and your results will appear here. Past papers and sprints are saved automatically.',
      actionLabel: 'Back to subjects',
      onAction: () => Navigator.of(context).maybePop(),
    );
  }
}
