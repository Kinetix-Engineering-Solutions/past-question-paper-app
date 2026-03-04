import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/features/practice/domain/entities/mistake_bank_entry.dart';
import 'package:past_question_paper_v1/features/practice/data/repositories/question_repository.dart';
import 'package:past_question_paper_v1/core/theme/app_colors.dart';
import 'package:past_question_paper_v1/features/practice/presentation/viewmodels/practice_viewmodel.dart';
import 'package:past_question_paper_v1/features/practice/presentation/screens/practice_screen.dart';

class MistakeBankScreen extends ConsumerWidget {
  final String subject;
  final int grade;
  final Color? subjectColor;

  const MistakeBankScreen({
    super.key,
    required this.subject,
    required this.grade,
    this.subjectColor,
  });

  Future<void> _startRetry(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(questionRepositoryProvider);

    final questions = await repo.generateTest({
      'grade': grade,
      'subject': subject,
      'mode': 'retry_mistakes',
      'paper': 'p1',
      'questionCount': 20,
    });

    if (questions.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'No mistakes to retry yet. Complete a practice session first.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeScreen(
          questions: questions,
          modeKey: 'retry_mistakes',
          sessionMetadata: {
            'modeKey': 'retry_mistakes',
            'source': 'mistake_bank_screen',
          },
        ),
      ),
    );

    // Ensure any previous session is cleared before new session begins.
    ref.read(practiceViewModelProvider.notifier).clearSession();
  }

  Future<void> _startTopicPractice(
    BuildContext context,
    WidgetRef ref, {
    required String topic,
  }) async {
    final repo = ref.read(questionRepositoryProvider);

    try {
      final questions = await repo.generateTest({
        'grade': grade,
        'subject': subject,
        'mode': 'by_topic',
        'topic': topic,
        'paper': 'p1',
        'questionCount': 20,
      });

      if (questions.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No questions found for "$topic".'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PracticeScreen(
            questions: questions,
            modeKey: 'by_topic',
            sessionMetadata: {
              'modeKey': 'by_topic',
              'source': 'mistake_bank_weak_topics',
              'topic': topic,
            },
          ),
        ),
      );

      ref.read(practiceViewModelProvider.notifier).clearSession();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final firestore = ref.watch(firestoreDatabaseProvider);

    List<MapEntry<String, int>> buildWeakTopicCounts(
      List<MistakeBankEntry> entries,
    ) {
      final counts = <String, int>{};
      for (final entry in entries) {
        if (entry.isMastered) continue;
        final rawTopic = entry.topic?.trim();
        final topic = (rawTopic == null || rawTopic.isEmpty)
            ? 'Unknown topic'
            : rawTopic;
        counts[topic] = (counts[topic] ?? 0) + 1;
      }

      final sorted = counts.entries.toList()
        ..sort((a, b) {
          final countCompare = b.value.compareTo(a.value);
          if (countCompare != 0) return countCompare;
          return a.key.toLowerCase().compareTo(b.key.toLowerCase());
        });

      return sorted;
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Mistake Bank'),
        backgroundColor: subjectColor ?? colorScheme.background,
        foregroundColor: subjectColor != null
            ? Colors.white
            : colorScheme.onBackground,
        elevation: 0,
      ),
      body: StreamBuilder<List<MistakeBankEntry>>(
        stream: firestore.watchMistakeBankEntries(subject: subject),
        builder: (context, snapshot) {
          final entries = snapshot.data ?? const <MistakeBankEntry>[];
          final unmasteredCount = entries.where((e) => !e.isMastered).length;
          final weakTopics = buildWeakTopicCounts(entries);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: snapshot.connectionState == ConnectionState.waiting
                      ? null
                      : () => _startRetry(context, ref),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Unmastered'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                subject,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (!snapshot.hasError &&
                  snapshot.connectionState != ConnectionState.waiting &&
                  entries.isNotEmpty)
                Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: colorScheme.outlineVariant.withOpacity(0.6),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weak Topics',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$unmasteredCount unmastered',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 10),
                        if (weakTopics.isEmpty)
                          Text(
                            'No topic data yet.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          )
                        else
                          ...weakTopics
                              .take(3)
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 3,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          e.key,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${e.value}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color:
                                                  subjectColor ??
                                                  AppColors.accent,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(width: 12),
                                      TextButton(
                                        onPressed: e.key == 'Unknown topic'
                                            ? null
                                            : () => _startTopicPractice(
                                                context,
                                                ref,
                                                topic: e.key,
                                              ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.accent,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                        ),
                                        child: const Text('Practice'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              if (snapshot.hasError)
                Text(
                  'Failed to load mistakes: ${snapshot.error}',
                  style: TextStyle(color: colorScheme.error),
                )
              else if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (entries.isEmpty)
                const Text(
                  'No mistakes yet. Complete a practice session first.',
                )
              else
                ...entries.map((entry) {
                  final statusText = entry.isMastered
                      ? 'Mastered'
                      : 'Unmastered';
                  final statusColor = entry.isMastered
                      ? Colors.green
                      : (subjectColor ?? AppColors.accent);

                  final subtitleParts = <String>[];
                  if (entry.topic != null && entry.topic!.trim().isNotEmpty) {
                    subtitleParts.add(entry.topic!);
                  }
                  if (entry.pqpQuestionNumber != null &&
                      entry.pqpQuestionNumber!.trim().isNotEmpty) {
                    subtitleParts.add('Q ${entry.pqpQuestionNumber}');
                  }
                  if (entry.marks != null) {
                    subtitleParts.add('${entry.marks} marks');
                  }

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: colorScheme.outlineVariant.withOpacity(0.6),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        statusText,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                      subtitle: subtitleParts.isEmpty
                          ? null
                          : Text(subtitleParts.join(' • ')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _startRetry(context, ref),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
