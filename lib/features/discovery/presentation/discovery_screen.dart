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
        title: const Text('Past Papers'),
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

          return _DiscoveryContent(data: data);
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
  const _DiscoveryContent({required this.data});

  final DiscoveryData data;

  @override
  ConsumerState<_DiscoveryContent> createState() => _DiscoveryContentState();
}

class _DiscoveryContentState extends ConsumerState<_DiscoveryContent> {
  String? _selectedSubjectId;

  @override
  Widget build(BuildContext context) {
    final visibleTopics = _selectedSubjectId == null
        ? widget.data.topics
        : widget.data.topicsForSubject(_selectedSubjectId!);

    return RefreshIndicator(
      onRefresh: () => ref.read(discoveryControllerProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const _HomeHeader(),
          const SizedBox(height: 28),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All topics'),
                  selected: _selectedSubjectId == null,
                  onSelected: (_) {
                    setState(() {
                      _selectedSubjectId = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                for (final subject in widget.data.subjects) ...[
                  ChoiceChip(
                    label: Text(subject.name),
                    selected: _selectedSubjectId == subject.id,
                    onSelected: (_) {
                      setState(() {
                        _selectedSubjectId = subject.id;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Topics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text(
                '${visibleTopics.length} '
                '${visibleTopics.length == 1 ? 'topic' : 'topics'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (visibleTopics.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text('No topics are available for this subject.'),
              ),
            )
          else
            for (final topic in visibleTopics) ...[
              _TopicCard(topic: topic),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.neutralCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Image.asset(
            'assets/branding/splash_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brandCyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'GRADE 12',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'What do you want\nto practise?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});

  final Topic topic;

  @override
  Widget build(BuildContext context) {
    final isAvailable = topic.questionCount > 0;
    final accent = _accentForSubject(topic.subjectSlug);
    final displayAccent = isAvailable ? accent : AppColors.mutedInk;
    final icon = _iconForSubject(topic.subjectSlug);

    return Card(
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: displayAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: displayAccent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isAvailable ? AppColors.ink : AppColors.mutedInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.subjectName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAvailable
                          ? '${topic.questionCount} '
                                '${topic.questionCount == 1 ? 'question' : 'questions'}'
                          : 'Coming soon',
                      style: TextStyle(
                        color: isAvailable
                            ? AppColors.primary
                            : AppColors.mutedInk,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAvailable) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Color _accentForSubject(String subjectSlug) {
    return switch (subjectSlug) {
      'mathematics' => AppColors.brandPeriwinkle,
      'physical-sciences' => AppColors.brandCyan,
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
