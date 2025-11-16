import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
// Using theme ColorScheme for shimmer colours; AppColors extension provides semantic getters
import 'package:past_question_paper_v1/utils/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final _shimmerBase = colorScheme.cardBackground;
    final _shimmerHighlight = colorScheme.brightness == Brightness.dark
        ? Color.lerp(_shimmerBase, Colors.white, 0.06)!
        : colorScheme.paperBackground;

    return Shimmer.fromColors(
      baseColor: _shimmerBase,
      highlightColor: _shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colorScheme.cardBackground,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class SubjectCardShimmer extends StatelessWidget {
  const SubjectCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final _shimmerBase = colorScheme.cardBackground;
    final _shimmerHighlight = colorScheme.brightness == Brightness.dark
        ? Color.lerp(_shimmerBase, Colors.white, 0.06)!
        : colorScheme.paperBackground;

    return Shimmer.fromColors(
      baseColor: _shimmerBase,
      highlightColor: _shimmerHighlight,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.borderColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 20,
              decoration: BoxDecoration(
                color: colorScheme.borderColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 120,
              height: 14,
              decoration: BoxDecoration(
                color: colorScheme.borderColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryCardShimmer extends StatelessWidget {
  const HistoryCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final _shimmerBase = colorScheme.cardBackground;
    final _shimmerHighlight = colorScheme.brightness == Brightness.dark
        ? Color.lerp(_shimmerBase, Colors.white, 0.06)!
        : colorScheme.paperBackground;

    return Shimmer.fromColors(
      baseColor: _shimmerBase,
      highlightColor: _shimmerHighlight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colorScheme.borderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.borderColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 14,
              decoration: BoxDecoration(
                color: colorScheme.borderColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 150,
              height: 14,
              decoration: BoxDecoration(
                color: colorScheme.borderColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
