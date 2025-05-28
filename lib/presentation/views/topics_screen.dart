import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/core/providers/question_providers.dart';
import 'package:past_question_paper_stem/presentation/views/questions_screen.dart';

/// Screen showing available topics for a selected subject and exam type
class TopicsScreen extends ConsumerWidget {
  final String subjectId;
  final String examTypeId;

  const TopicsScreen({
    super.key,
    required this.subjectId,
    required this.examTypeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the Riverpod family provider to get topics for the selected subject and exam type
    final topicsAsync = ref.watch(
      topicsProvider((subjectId: subjectId, examTypeId: examTypeId)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('$examTypeId - Topics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: topicsAsync.when(
        data: (topics) {
          if (topics.isEmpty) {
            return const Center(
              child: Text(
                'No topics available for this exam type.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    topics[index],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => QuestionsScreen(
                              subjectId: subjectId,
                              examTypeId: examTypeId,
                              topicId: topics[index],
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load topics: $error',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        () => ref.refresh(
                          topicsProvider((
                            subjectId: subjectId,
                            examTypeId: examTypeId,
                          )),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
