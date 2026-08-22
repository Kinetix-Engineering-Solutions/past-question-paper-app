import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/app_user.dart';
import '../../questions/data/models/question.dart';
import '../../questions/presentation/widgets/question_bookmark_button.dart';
import '../../questions/presentation/widgets/question_content_card.dart';
import '../domain/question_progress.dart';
import '../providers/needs_review_questions_provider.dart';
import '../providers/progress_providers.dart';
import 'widgets/question_reflection_card.dart';

class NeedsReviewDetailScreen extends ConsumerStatefulWidget {
  const NeedsReviewDetailScreen({
    required this.user,
    required this.question,
    super.key,
  });

  final AppUser user;
  final Question question;

  @override
  ConsumerState<NeedsReviewDetailScreen> createState() =>
      _NeedsReviewDetailScreenState();
}

class _NeedsReviewDetailScreenState
    extends ConsumerState<NeedsReviewDetailScreen> {
  bool _showMemo = false;

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    final progressProvider = questionProgressControllerProvider(question.id);
    final progressState = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${question.questionNumber}'),
        actions: [
          QuestionBookmarkButton(user: widget.user, question: question),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${question.topicName} • '
                '${question.examYear} • '
                '${question.examSeason} • '
                'Paper ${question.paperNumber}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          Expanded(
            child: QuestionContentCard(question: question, showMemo: _showMemo),
          ),
          if (_showMemo)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: progressState.when(
                loading: () => QuestionReflectionCard(
                  status: null,
                  isSaving: true,
                  onUnderstood: () {},
                  onNeedsReview: () {},
                ),
                error: (error, stackTrace) => QuestionReflectionCard(
                  status: null,
                  isSaving: false,
                  errorMessage: 'Unable to load or save your progress.',
                  onRetry: () {
                    ref.invalidate(progressProvider);
                  },
                  onUnderstood: () =>
                      _saveProgress(QuestionProgressStatus.understood),
                  onNeedsReview: () =>
                      _saveProgress(QuestionProgressStatus.needsReview),
                ),
                data: (progress) => QuestionReflectionCard(
                  status: progress?.status,
                  isSaving: false,
                  onUnderstood: () =>
                      _saveProgress(QuestionProgressStatus.understood),
                  onNeedsReview: () =>
                      _saveProgress(QuestionProgressStatus.needsReview),
                ),
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
      ),
    );
  }

  Future<void> _saveProgress(QuestionProgressStatus status) async {
    final questionId = widget.question.id;
    final provider = questionProgressControllerProvider(questionId);

    await ref.read(provider.notifier).setStatus(status);

    if (!mounted) {
      return;
    }

    final result = ref.read(provider);

    if (result.hasError) {
      return;
    }

    ref.invalidate(needsReviewQuestionsProvider(widget.user.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == QuestionProgressStatus.understood
              ? 'Marked as understood.'
              : 'Still marked as needing review.',
        ),
      ),
    );
  }
}
