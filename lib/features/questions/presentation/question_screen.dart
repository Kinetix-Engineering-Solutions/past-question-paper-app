import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../discovery/data/models/topic.dart';
import '../data/models/question.dart';
import '../providers/question_providers.dart';

class QuestionScreen extends ConsumerStatefulWidget {
  const QuestionScreen({required this.topic, super.key});

  final Topic topic;

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  int _currentIndex = 0;
  bool _showMemo = false;

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(questionsControllerProvider(widget.topic.id));

    return Scaffold(
      appBar: AppBar(title: Text(widget.topic.name)),
      body: questions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _QuestionError(
          message: error is ApiException
              ? error.message
              : 'Unable to load questions.',
          onRetry: () => ref
              .read(questionsControllerProvider(widget.topic.id).notifier)
              .refresh(),
        ),
        data: (page) {
          if (page.items.isEmpty) {
            return const _EmptyQuestions();
          }

          final currentQuestion = page.items[_currentIndex];

          return Column(
            children: [
              _QuestionHeader(
                question: currentQuestion,
                currentIndex: _currentIndex,
                totalCount: page.totalCount,
              ),
              Expanded(
                child: PageView.builder(
                  itemCount: page.items.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                      _showMemo = false;
                    });

                    if (index >= page.items.length - 2) {
                      ref
                          .read(
                            questionsControllerProvider(
                              widget.topic.id,
                            ).notifier,
                          )
                          .loadNextPage();
                    }
                  },
                  itemBuilder: (context, index) {
                    final question = page.items[index];

                    return _QuestionCard(
                      question: question,
                      showMemo: index == _currentIndex && _showMemo,
                    );
                  },
                ),
              ),
              if (page.isLoadingMore)
                const LinearProgressIndicator()
              else if (page.loadMoreError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          page.loadMoreError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => ref
                            .read(
                              questionsControllerProvider(
                                widget.topic.id,
                              ).notifier,
                            )
                            .loadNextPage(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              SafeArea(
                minimum: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _showMemo = !_showMemo;
                      });
                    },
                    icon: Icon(
                      _showMemo
                          ? Icons.description_outlined
                          : Icons.visibility_outlined,
                    ),
                    label: Text(_showMemo ? 'Show question' : 'Reveal memo'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuestionHeader extends StatelessWidget {
  const _QuestionHeader({
    required this.question,
    required this.currentIndex,
    required this.totalCount,
  });

  final Question question;
  final int currentIndex;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Question ${question.questionNumber}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text('${currentIndex + 1} of $totalCount'),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question, required this.showMemo});

  final Question question;
  final bool showMemo;

  @override
  Widget build(BuildContext context) {
    final imageUri = showMemo
        ? question.memoImageUrl
        : question.questionImageUrl;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  showMemo ? 'Memo' : 'Question',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Image.network(
                    imageUri.toString(),
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) {
                        return child;
                      }

                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image_outlined, size: 48),
                            SizedBox(height: 12),
                            Text('Unable to load this image.'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionError extends StatelessWidget {
  const _QuestionError({required this.message, required this.onRetry});

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

class _EmptyQuestions extends StatelessWidget {
  const _EmptyQuestions();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No published questions are available for this topic yet.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
