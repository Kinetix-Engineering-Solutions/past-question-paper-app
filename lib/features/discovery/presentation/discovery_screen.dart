import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/features/questions/presentation/question_screen.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/presentation/account_screen.dart';
import '../../auth/presentation/auth_screen.dart';
import '../../auth/providers/auth_providers.dart';
import '../../legal/presentation/legal_documents_screen.dart';
import '../../progress/domain/topic_progress.dart';
import '../../progress/providers/topic_progress_provider.dart';
import '../data/models/discovery_data.dart';
import '../data/models/topic.dart';
import '../providers/discovery_providers.dart';

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discovery = ref.watch(discoveryControllerProvider);
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.asData?.value;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Legal and privacy',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const LegalDocumentsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.info_outline),
          ),
          IconButton(
            tooltip: currentUser == null ? 'Sign in' : 'Account',
            onPressed: authState.isLoading
                ? null
                : () => _openAccount(context, currentUser),
            icon: Icon(
              currentUser == null ? Icons.person_outline : Icons.account_circle,
            ),
          ),
        ],
      ),
      body: discovery.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _DiscoveryError(
          message: _errorMessage(error),
          onRetry: () =>
              ref.read(discoveryControllerProvider.notifier).refresh(),
        ),
        data: (data) {
          if (data.isEmpty) {
            return _EmptyDiscovery(
              onRefresh: () =>
                  ref.read(discoveryControllerProvider.notifier).refresh(),
            );
          }

          final progress = currentUser == null
              ? const AsyncValue<List<TopicProgress>>.data(<TopicProgress>[])
              : ref.watch(topicProgressProvider(currentUser.id));

          return _DiscoveryContent(data: data, progress: progress);
        },
      ),
    );
  }

  Future<void> _openAccount(BuildContext context, AppUser? user) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            user == null ? const AuthScreen() : AccountScreen(user: user),
      ),
    );
  }

  String _errorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }

    return 'Unable to load subjects and topics.';
  }
}

class _DiscoveryContent extends ConsumerStatefulWidget {
  const _DiscoveryContent({required this.data, required this.progress});

  final DiscoveryData data;
  final AsyncValue<List<TopicProgress>> progress;

  @override
  ConsumerState<_DiscoveryContent> createState() => _DiscoveryContentState();
}

class _DiscoveryContentState extends ConsumerState<_DiscoveryContent> {
  String? _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = _initialSubjectId();
  }

  @override
  void didUpdateWidget(covariant _DiscoveryContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    final selectionStillExists = widget.data.subjects.any(
      (subject) => subject.id == _selectedSubjectId,
    );

    if (!selectionStillExists) {
      _selectedSubjectId = _initialSubjectId();
    }
  }

  String? _initialSubjectId() {
    if (widget.data.subjects.isEmpty) {
      return null;
    }

    return widget.data.subjects.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final selectedSubjectId = _selectedSubjectId;
    final visibleTopics = selectedSubjectId == null
        ? const <Topic>[]
        : widget.data.topicsForSubject(selectedSubjectId);
    final sortedTopics = visibleTopics.toList(growable: false)
      ..sort((a, b) {
        final availability = (b.questionCount > 0 ? 1 : 0).compareTo(
          a.questionCount > 0 ? 1 : 0,
        );
        return availability != 0
            ? availability
            : a.displayOrder.compareTo(b.displayOrder);
      });
    final progressByTopic = {
      for (final item in widget.progress.valueOrNull ?? const <TopicProgress>[])
        item.topic.id: item,
    };
    final continueItem =
        (widget.progress.valueOrNull ?? const <TopicProgress>[])
            .where(
              (item) =>
                  item.topic.subjectId == selectedSubjectId &&
                  item.topic.questionCount > 0,
            )
            .fold<TopicProgress?>(
              null,
              (latest, item) =>
                  latest == null ||
                      item.summary.lastReviewedAt.isAfter(
                        latest.summary.lastReviewedAt,
                      )
                  ? item
                  : latest,
            );

    return RefreshIndicator(
      onRefresh: () => ref.read(discoveryControllerProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _PageIntroduction(),
          const SizedBox(height: 20),
          if (widget.data.subjects.isNotEmpty)
            _SubjectSelector(
              subjects: widget.data.subjects
                  .map(
                    (subject) =>
                        _SubjectOption(id: subject.id, name: subject.name),
                  )
                  .toList(growable: false),
              selectedSubjectId: selectedSubjectId,
              onSelected: (subjectId) {
                setState(() {
                  _selectedSubjectId = subjectId;
                });
              },
            ),
          if (continueItem != null) ...[
            const SizedBox(height: 24),
            Text(
              'Continue practising',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            _ContinueCard(progress: continueItem),
          ],
          const SizedBox(height: 24),
          _TopicsHeader(topicCount: sortedTopics.length),
          const SizedBox(height: 12),
          if (sortedTopics.isEmpty)
            const _NoTopicsForSubject()
          else
            for (var index = 0; index < sortedTopics.length; index++) ...[
              _TopicCard(
                topic: sortedTopics[index],
                progress: progressByTopic[sortedTopics[index].id],
              ),
              if (index != sortedTopics.length - 1) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _PageIntroduction extends StatelessWidget {
  const _PageIntroduction();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.brandPeriwinkle.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'GRADE 12',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'What do you want to practise?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Practise past-paper questions by topic.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _SubjectOption {
  const _SubjectOption({required this.id, required this.name});

  final String id;
  final String name;
}

class _SubjectSelector extends StatelessWidget {
  const _SubjectSelector({
    required this.subjects,
    required this.selectedSubjectId,
    required this.onSelected,
  });

  final List<_SubjectOption> subjects;
  final String? selectedSubjectId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedId = selectedSubjectId;

    if (selectedId == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < subjects.length; index++) ...[
            ChoiceChip(
              label: Text(subjects[index].name),
              selected: subjects[index].id == selectedId,
              onSelected: (_) => onSelected(subjects[index].id),
              showCheckmark: false,
              selectedColor: AppColors.brandPeriwinkle.withValues(alpha: 0.22),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            ),
            if (index != subjects.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.progress});

  final TopicProgress progress;

  @override
  Widget build(BuildContext context) {
    final topic = progress.topic;
    return Card(
      color: AppColors.primary,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => QuestionScreen(topic: topic)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topic.name,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                '${progress.summary.reviewedCount} of ${topic.questionCount} questions reviewed',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.84),
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress.reviewCoverage,
                minHeight: 7,
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.24),
              ),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicsHeader extends StatelessWidget {
  const _TopicsHeader({required this.topicCount});

  final int topicCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text('Topics', style: Theme.of(context).textTheme.titleLarge),
        ),
        Text(
          '$topicCount ${topicCount == 1 ? 'topic' : 'topics'}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic, this.progress});

  final Topic topic;
  final TopicProgress? progress;

  @override
  Widget build(BuildContext context) {
    final isAvailable = topic.questionCount > 0;
    final accent = _accentForSubject(topic.subjectSlug);
    final displayAccent = isAvailable ? accent : AppColors.mutedInk;
    final icon = _iconForSubject(topic.subjectSlug);
    final questionLabel = topic.questionCount == 1
        ? '1 question'
        : '${topic.questionCount} questions';

    return Semantics(
      button: isAvailable,
      enabled: isAvailable,
      label: isAvailable
          ? '${topic.name}, $questionLabel'
          : '${topic.name}, coming soon',
      child: Card(
        color: AppColors.neutralCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isAvailable
              ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => QuestionScreen(topic: topic),
                    ),
                  );
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: displayAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, size: 23, color: displayAccent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: isAvailable
                                  ? AppColors.ink
                                  : AppColors.mutedInk,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isAvailable
                            ? progress == null
                                  ? questionLabel
                                  : '$questionLabel · ${progress!.summary.reviewedCount} reviewed'
                            : 'Coming soon',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isAvailable
                              ? AppColors.primary
                              : AppColors.mutedInk,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isAvailable && progress != null) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress!.reviewCoverage,
                          minHeight: 5,
                          borderRadius: BorderRadius.circular(6),
                          color: accent,
                        ),
                      ],
                    ],
                  ),
                ),
                if (isAvailable)
                  Icon(Icons.chevron_right, color: displayAccent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _accentForSubject(String subjectSlug) {
    return switch (subjectSlug) {
      'mathematics' => AppColors.brandPeriwinkle,
      'physical-sciences' => AppColors.primary,
      _ => AppColors.primary,
    };
  }

  IconData _iconForSubject(String subjectSlug) {
    return switch (subjectSlug) {
      'mathematics' => Icons.calculate_outlined,
      'physical-sciences' => Icons.science_outlined,
      _ => Icons.menu_book_outlined,
    };
  }
}

class _NoTopicsForSubject extends StatelessWidget {
  const _NoTopicsForSubject();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(
            Icons.menu_book_outlined,
            size: 40,
            color: AppColors.mutedInk,
          ),
          const SizedBox(height: 12),
          Text(
            'No topics are available for this subject yet.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _DiscoveryError extends StatelessWidget {
  const _DiscoveryError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class _EmptyDiscovery extends StatelessWidget {
  const _EmptyDiscovery({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_outlined, size: 48),
            const SizedBox(height: 16),
            const Text(
              'No Grade 12 topics are available yet.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRefresh, child: const Text('Refresh')),
          ],
        ),
      ),
    );
  }
}
