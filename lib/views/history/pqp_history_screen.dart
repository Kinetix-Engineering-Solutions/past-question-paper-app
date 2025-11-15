import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class _HistoryContent extends StatelessWidget {
  const _HistoryContent({required this.entries, required this.onRefresh});

  final List<SessionHistoryEntry> entries;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
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

    final summary = _HistorySummary.fromEntries(entries);
    final groupedEntries = _groupByDay(entries);

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.accent,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          _SummaryCard(summary: summary),
          const SizedBox(height: 24),
          for (final group in groupedEntries) ...[
            _DaySectionHeader(
              date: group.date,
              sessionCount: group.entries.length,
            ),
            const SizedBox(height: 12),
            for (final entry in group.entries) ...[
              _HistoryEntryCard(entry: entry),
              const SizedBox(height: 16),
            ],
          ],
        ],
      ),
    );
  }

  List<_HistoryDayGroup> _groupByDay(List<SessionHistoryEntry> entries) {
    final Map<DateTime, List<SessionHistoryEntry>> grouped = {};
    for (final entry in entries) {
      final day = DateTime(
        entry.completedAt.year,
        entry.completedAt.month,
        entry.completedAt.day,
      );
      grouped.putIfAbsent(day, () => <SessionHistoryEntry>[]).add(entry);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return sortedKeys
        .map((date) => _HistoryDayGroup(date: date, entries: grouped[date]!))
        .toList();
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
            'Practice History Overview',
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

class _DaySectionHeader extends StatelessWidget {
  const _DaySectionHeader({required this.date, required this.sessionCount});

  final DateTime date;
  final int sessionCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _formatDay(date),
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$sessionCount session${sessionCount == 1 ? '' : 's'}',
            style: textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}

class _HistoryEntryCard extends StatelessWidget {
  const _HistoryEntryCard({required this.entry});

  final SessionHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final modeColor = entry.isPastPaper
        ? AppColors.accent
        : entry.isSprint
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    final configured = entry.configuredDuration;
    final session = entry.sessionDuration;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.subject,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (entry.paper != null)
                      Text(
                        entry.paper!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.percentage.round()}%',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${entry.score}/${entry.totalMarks} marks',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ModeChip(label: entry.modeLabel, color: modeColor),
              _InfoChip(label: 'Grade ${entry.grade}'),
              _InfoChip(label: _formatTime(entry.completedAt)),
              if (configured != null)
                _InfoChip(label: 'Planned ${_formatDuration(configured)}'),
              if (session != null)
                _InfoChip(label: 'Spent ${_formatDuration(session)}'),
              _InfoChip(label: '${entry.totalQuestions} questions'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.2)),
      label: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      backgroundColor: colorScheme.surfaceContainerHighest,
      label: Text(label, style: Theme.of(context).textTheme.labelMedium),
      side: BorderSide.none,
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

class _HistoryDayGroup {
  const _HistoryDayGroup({required this.date, required this.entries});

  final DateTime date;
  final List<SessionHistoryEntry> entries;
}

String _formatDay(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = months[date.month - 1];
  return '$month ${date.day}, ${date.year}';
}

String _formatTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }
  return '${minutes}m';
}
