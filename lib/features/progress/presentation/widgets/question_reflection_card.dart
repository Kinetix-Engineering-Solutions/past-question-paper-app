import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/features/progress/domain/question_progress.dart';

final class QuestionReflectionCard extends StatelessWidget {
  const QuestionReflectionCard({
    required this.status,
    required this.isSaving,
    required this.onUnderstood,
    required this.onNeedsReview,
    this.errorMessage,
    this.onRetry,
    super.key,
  });

  final QuestionProgressStatus? status;
  final bool isSaving;
  final String? errorMessage;
  final VoidCallback onUnderstood;
  final VoidCallback onNeedsReview;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final understoodSelected = status == QuestionProgressStatus.understood;
    final needsReviewSelected = status == QuestionProgressStatus.needsReview;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Did you understand this question?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your answer helps organise what to review next.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ReflectionButton(
                    label: 'Understood',
                    icon: Icons.check_circle_outline,
                    selected: understoodSelected,
                    enabled: !isSaving,
                    onPressed: onUnderstood,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ReflectionButton(
                    label: 'Needs review',
                    icon: Icons.replay_outlined,
                    selected: needsReviewSelected,
                    enabled: !isSaving,
                    onPressed: onNeedsReview,
                  ),
                ),
              ],
            ),
            if (isSaving) ...[
              const SizedBox(height: 14),
              const LinearProgressIndicator(),
            ],
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: isSaving ? null : onRetry,
                    child: const Text('Try again'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

final class _ReflectionButton extends StatelessWidget {
  const _ReflectionButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return FilledButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon),
        label: Text(label),
      );
    }

    return OutlinedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
