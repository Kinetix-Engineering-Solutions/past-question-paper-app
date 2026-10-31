import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/loading_skeleton.dart';

class LearnerHeader extends StatelessWidget {
  const LearnerHeader({
    required this.learnerName,
    required this.progress,
    required this.reviewedQuestions,
    required this.totalQuestions,
    required this.onInfoPressed,
    required this.onAccountPressed,
    required this.isSignedIn,
    this.isProgressLoading = false,
    super.key,
  });

  final String? learnerName;
  final double? progress;
  final int? reviewedQuestions;
  final int? totalQuestions;
  final VoidCallback onInfoPressed;
  final VoidCallback? onAccountPressed;
  final bool isSignedIn;
  final bool isProgressLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppPalette.of(context);
    final name = learnerName?.trim();
    final hasProgress =
        progress != null && reviewedQuestions != null && totalQuestions != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Past Papers', style: theme.textTheme.titleLarge),
              ),
              IconButton(
                tooltip: 'Legal and privacy',
                onPressed: onInfoPressed,
                icon: const Icon(Icons.info_outline, size: 22),
              ),
              IconButton(
                tooltip: isSignedIn ? 'Account' : 'Sign in',
                onPressed: onAccountPressed,
                icon: CircleAvatar(
                  radius: 18,
                  backgroundColor: colors.iconTile,
                  child: Icon(
                    Icons.person_outline,
                    color: colors.topicIcon,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isSignedIn
                ? name == null || name.isEmpty
                      ? 'Welcome back'
                      : 'Welcome back, $name'
                : 'Ready to learn?',
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          if (isProgressLoading && !hasProgress)
            const ShimmerLoading(
              child: FractionallySizedBox(
                widthFactor: 0.7,
                child: SkeletonBlock(height: 16),
              ),
            )
          else if (!isSignedIn)
            Text(
              'Sign in to track your progress',
              style: theme.textTheme.bodyLarge,
            )
          else if (!hasProgress)
            Text(
              'Progress unavailable. Pull down to retry.',
              style: theme.textTheme.bodyLarge,
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${(progress!.clamp(0.0, 1.0) * 100).round()}%',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$reviewedQuestions of $totalQuestions questions reviewed',
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
