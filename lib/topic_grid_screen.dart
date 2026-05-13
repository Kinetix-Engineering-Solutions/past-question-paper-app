import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/core/theme/app_colors.dart';
import 'package:past_question_paper_v1/features/home/presentation/viewmodels/app_metadata_viewmodel.dart';
import 'package:past_question_paper_v1/flashcard_screen.dart';

class TopicGridScreen extends ConsumerStatefulWidget {
  const TopicGridScreen({super.key});

  @override
  ConsumerState<TopicGridScreen> createState() => _TopicGridScreenState();
}

String _toDisplayCase(String text) {
  return text
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

class _TopicMetaTag extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _TopicMetaTag({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TopicGridScreenState extends ConsumerState<TopicGridScreen> {
  String? selectedSubject;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appMetadataViewModelProvider.notifier).refresh();
    });
  }

  String _toTopicId(String topicTitle) {
    return topicTitle
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final metadataState = ref.watch(appMetadataViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (metadataState.isLoading && metadataState.metadata == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final metadata = metadataState.metadata;
    if (metadata == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Past Papers Pilot'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  metadataState.errorMessage ??
                      'Please connect to the internet to download your subjects for the first time.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.read(appMetadataViewModelProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final subjects = metadata.subjects;
    if (subjects.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Past Papers Pilot'),
          centerTitle: true,
        ),
        body: const Center(child: Text('No subjects available.')),
      );
    }

    selectedSubject ??= subjects.map((s) => s.id).contains('mathematics')
        ? 'mathematics'
        : subjects.first.id;

    final currentSubject = subjects.firstWhere(
      (s) => s.id == selectedSubject,
      orElse: () => subjects.first,
    );

    final topics = currentSubject.topics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Papers Pilot'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh subjects',
            onPressed: () =>
                ref.read(appMetadataViewModelProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (subjects.length > 1)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<String>(
                segments: [
                  for (final subject in subjects)
                    ButtonSegment(value: subject.id, label: Text(subject.name)),
                ],
                selected: {selectedSubject!},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    selectedSubject = newSelection.first;
                  });
                },
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: topics.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final topicTitle = topics[index];
                final hashSeed = '${selectedSubject!}::$topicTitle';
                final estimatedQuestions = 8 + (hashSeed.hashCode.abs() % 28);
                final leadingColor = AppColors.accent;

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FlashcardScreen(
                            subjectId: selectedSubject!,
                            topicId: _toTopicId(topicTitle),
                            topicTitle: topicTitle,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 54,
                            decoration: BoxDecoration(
                              color: leadingColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topicTitle,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    _TopicMetaTag(
                                      label: _toDisplayCase(selectedSubject!),
                                      background: colorScheme.surfaceVariant,
                                      foreground: colorScheme.onSurfaceVariant,
                                    ),
                                    _TopicMetaTag(
                                      label: '~$estimatedQuestions questions',
                                      background: colorScheme.primary
                                          .withOpacity(0.10),
                                      foreground: colorScheme.primary,
                                    ),
                                    _TopicMetaTag(
                                      label: 'Available now',
                                      background: AppColors.accent.withOpacity(
                                        0.14,
                                      ),
                                      foreground: AppColors.accent,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
