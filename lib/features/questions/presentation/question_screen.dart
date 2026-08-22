import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/features/questions/presentation/question_filter_dialog.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/presentation/auth_screen.dart';
import '../../auth/providers/auth_providers.dart';
import '../../bookmarks/domain/bookmark_target.dart';
import '../../bookmarks/providers/bookmark_providers.dart';
import '../../discovery/data/models/topic.dart';
import '../data/models/question.dart';
import '../domain/question_query.dart';
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
  late QuestionQuery _query;

  @override
  void initState() {
    super.initState();

    _query = QuestionQuery(topicId: widget.topic.id);
  }

  Future<void> _openFilters() async {
    final result = await showQuestionFilterDialog(
      context: context,
      currentQuery: _query,
    );

    if (result == null || result == _query || !mounted) {
      return;
    }

    setState(() {
      _query = result;
      _currentIndex = 0;
      _showMemo = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(questionsControllerProvider(_query));
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.name),
        actions: [
          IconButton(
            tooltip: 'Filter questions',
            onPressed: _openFilters,
            icon: Icon(
              _query.hasFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
          ),
        ],
      ),
      body: questions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _QuestionError(
          message: error is ApiException
              ? error.message
              : 'Unable to load questions.',
          onRetry: () =>
              ref.read(questionsControllerProvider(_query).notifier).refresh(),
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
                bookmarkAction: _BookmarkButton(
                  user: currentUser,
                  question: currentQuestion,
                ),
              ),
              LinearProgressIndicator(
                value: (_currentIndex + 1) / page.totalCount,
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
                          .read(questionsControllerProvider(_query).notifier)
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
                            .read(questionsControllerProvider(_query).notifier)
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
    required this.bookmarkAction,
  });

  final Question question;
  final int currentIndex;
  final int totalCount;
  final Widget bookmarkAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Question ${question.questionNumber}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              bookmarkAction,
              const SizedBox(width: 4),
              Text(
                '${currentIndex + 1} of $totalCount',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          Text(
            '${question.examYear} • '
            '${question.examSeason} • '
            'Paper ${question.paperNumber}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _BookmarkButton extends ConsumerWidget {
  const _BookmarkButton({required this.user, required this.question});

  final AppUser? user;
  final Question question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = user;

    if (currentUser == null) {
      return IconButton(
        tooltip: 'Sign in to bookmark',
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const AuthScreen()));
        },
        icon: const Icon(Icons.bookmark_border),
      );
    }

    final target = BookmarkTarget(
      userId: currentUser.id,
      questionId: question.id,
    );

    final bookmark = ref.watch(bookmarkControllerProvider(target));

    return bookmark.when(
      loading: () => const IconButton(
        tooltip: 'Loading bookmark',
        onPressed: null,
        icon: SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, stackTrace) => IconButton(
        tooltip: 'Retry bookmark',
        onPressed: () {
          ref.invalidate(bookmarkControllerProvider(target));
        },
        icon: const Icon(Icons.bookmark_border),
      ),
      data: (state) {
        return IconButton(
          tooltip: state.isBookmarked ? 'Remove bookmark' : 'Bookmark question',
          onPressed: state.isSaving
              ? null
              : () => _toggle(context, ref, target),
          icon: state.isSaving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  state.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                ),
        );
      },
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    BookmarkTarget target,
  ) async {
    await ref.read(bookmarkControllerProvider(target).notifier).toggle();

    if (!context.mounted) {
      return;
    }

    final updatedState = ref
        .read(bookmarkControllerProvider(target))
        .asData
        ?.value;

    final errorMessage = updatedState?.errorMessage;

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    showMemo ? Icons.task_alt : Icons.description_outlined,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    showMemo ? 'Memo' : 'Question',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            LayoutBuilder(
              builder: (context, constraints) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image.network(
                    imageUri.toString(),
                    width: constraints.maxWidth,
                    fit: BoxFit.fitWidth,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) {
                        return child;
                      }

                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.broken_image_outlined, size: 48),
                              SizedBox(height: 12),
                              Text('Unable to load this image.'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
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
