import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/core/providers/question_providers.dart';
import 'package:past_question_paper_stem/presentation/views/question_detail_screen.dart';

/// Screen showing a list of questions for a selected topic
class QuestionsScreen extends ConsumerWidget {
  final String subjectId;
  final String examTypeId;
  final String topicId;

  const QuestionsScreen({
    super.key,
    required this.subjectId,
    required this.examTypeId,
    required this.topicId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the Riverpod family provider to get questions
    final questionsAsync = ref.watch(
      questionsProvider((
        subjectId: subjectId,
        examTypeId: examTypeId,
        topicId: topicId,
      )),
    );

    // Get the user progress tracker
    final userProgress = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('$topicId - Questions'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(
              child: Text(
                'No questions available for this topic.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              final hasAttempted =
                  (userProgress['questionStats'] as Map<String, dynamic>?)
                      ?.containsKey(question.id) ??
                  false;
              final wasCorrect =
                  hasAttempted &&
                  ((userProgress['questionStats']
                              as Map<String, dynamic>)[question.id]
                          as Map<String, dynamic>)['correct']
                      as bool;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape:
                    hasAttempted
                        ? RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: wasCorrect ? Colors.green : Colors.red,
                            width: 2,
                          ),
                        )
                        : null,
                child: ListTile(
                  title: Text(
                    'Question ${index + 1}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    question.questionText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasAttempted)
                        Icon(
                          wasCorrect ? Icons.check_circle : Icons.cancel,
                          color: wasCorrect ? Colors.green : Colors.red,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        question.questionType,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => QuestionDetailScreen(
                              question: question,
                              onSubmit: (bool isCorrect) {
                                // Record the attempt in the user progress tracker
                                ref
                                    .read(userProgressProvider.notifier)
                                    .recordAttempt(question.id, isCorrect);
                              },
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
                    'Failed to load questions: $error',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        () => ref.refresh(
                          questionsProvider((
                            subjectId: subjectId,
                            examTypeId: examTypeId,
                            topicId: topicId,
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
