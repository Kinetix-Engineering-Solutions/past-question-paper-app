import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';

/// Reusable empty state widget for displaying placeholder content
///
/// Supports both light and dark themes, with optional action button.
/// Commonly used for empty lists, error states, and offline scenarios.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  /// Factory constructor for offline state
  factory EmptyState.offline({VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.wifi_off_rounded,
      title: 'No internet connection',
      message:
          'Please check your network settings and try again. Some features require an active internet connection.',
      actionLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }

  /// Factory constructor for network error state
  factory EmptyState.networkError({
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      icon: Icons.cloud_off_rounded,
      title: 'Connection problem',
      message:
          customMessage ??
          'Unable to connect to the server. Please try again in a moment.',
      actionLabel: onRetry != null ? 'Try again' : null,
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColorsDark.accentSoft : AppColors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: AppColors.accent),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.neutralCard,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
