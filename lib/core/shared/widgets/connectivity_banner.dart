import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/providers/connectivity_provider.dart';
import 'package:past_question_paper_v1/services/connectivity_service.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';

/// Global banner that displays when network connectivity is lost or degraded
/// 
/// Integrates with ConnectivityService via Riverpod to show/hide based on
/// network status. Positioned at top of screen with slide animation.
/// 
/// Place this widget high in the widget tree (e.g., in MaterialApp builder)
/// to ensure it appears over all screens.
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStatusProvider);

    return connectivityAsync.when(
      data: (status) {
        // Only show banner when offline or degraded
        if (status == ConnectivityStatus.online) {
          return const SizedBox.shrink();
        }

        return _BannerContent(status: status);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _BannerContent extends ConsumerStatefulWidget {
  const _BannerContent({required this.status});

  final ConnectivityStatus status;

  @override
  ConsumerState<_BannerContent> createState() => _BannerContentState();
}

class _BannerContentState extends ConsumerState<_BannerContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Trigger slide-in animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    setState(() => _isRetrying = true);
    
    try {
      await ref.recheckConnectivity();
      // Wait a moment for status to update
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    // Determine banner styling based on status
    final bannerConfig = _getBannerConfig(widget.status, isDark);

    return SlideTransition(
      position: _slideAnimation,
      child: Material(
        color: bannerConfig.backgroundColor,
        elevation: 4,
        child: SafeArea(
          bottom: false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: bannerConfig.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  bannerConfig.icon,
                  color: bannerConfig.iconColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        bannerConfig.title,
                        style: textTheme.labelLarge?.copyWith(
                          color: bannerConfig.textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bannerConfig.message,
                        style: textTheme.bodySmall?.copyWith(
                          color: bannerConfig.textColor.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (widget.status == ConnectivityStatus.offline)
                  TextButton(
                    onPressed: _isRetrying ? null : _handleRetry,
                    style: TextButton.styleFrom(
                      foregroundColor: bannerConfig.textColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      backgroundColor: bannerConfig.textColor.withValues(alpha: 0.15),
                    ),
                    child: _isRetrying
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                bannerConfig.textColor,
                              ),
                            ),
                          )
                        : Text(
                            'Retry',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: bannerConfig.textColor,
                            ),
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _BannerConfig _getBannerConfig(ConnectivityStatus status, bool isDark) {
    switch (status) {
      case ConnectivityStatus.offline:
        return _BannerConfig(
          backgroundColor: isDark ? AppColorsDark.ink : AppColors.ink,
          borderColor: (isDark ? AppColorsDark.ink : AppColors.ink)
              .withValues(alpha: 0.5),
          icon: Icons.wifi_off_rounded,
          iconColor: AppColors.neutralCard,
          textColor: AppColors.neutralCard,
          title: 'No internet connection',
          message: 'Check your network settings',
        );

      case ConnectivityStatus.degraded:
        return _BannerConfig(
          backgroundColor:
              isDark ? AppColorsDark.accentSoft : AppColors.accentSoft,
          borderColor: AppColors.accent.withValues(alpha: 0.3),
          icon: Icons.signal_wifi_connected_no_internet_4_rounded,
          iconColor: AppColors.accent,
          textColor: isDark ? AppColorsDark.ink : AppColors.ink,
          title: 'Limited connectivity',
          message: 'Some features may be unavailable',
        );

      case ConnectivityStatus.online:
        // Should never reach here due to parent widget check
        return _BannerConfig(
          backgroundColor: Colors.transparent,
          borderColor: Colors.transparent,
          icon: Icons.check_circle_outline,
          iconColor: Colors.green,
          textColor: Colors.black,
          title: 'Connected',
          message: '',
        );
    }
  }
}

class _BannerConfig {
  const _BannerConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.textColor,
    required this.title,
    required this.message,
  });

  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final String title;
  final String message;
}
