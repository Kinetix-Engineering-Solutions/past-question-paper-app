import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// One animation shared by a group of placeholders, with a static reduced-motion
/// fallback and a single accessible loading announcement.
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({required this.child, super.key});

  final Widget child;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 1500),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) || !TickerMode.of(context)) {
      _controller.stop();
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: 'Loading content',
      liveRegion: true,
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              child: widget.child,
              builder: (context, child) {
                if (reduceMotion) return child!;
                final offset = _controller.value * 4 - 2;
                return ShaderMask(
                  blendMode: BlendMode.srcATop,
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment(offset - 1, -0.2),
                    end: Alignment(offset + 1, 0.2),
                    colors: [
                      AppPalette.of(context).border,
                      AppPalette.of(context).neutralCard,
                      AppPalette.of(context).border,
                    ],
                    stops: [0.25, 0.5, 0.75],
                  ).createShader(bounds),
                  child: child,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({this.width, this.height = 14, super.key});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppPalette.of(context).border,
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

enum SkeletonLayout { discovery, list, question }

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({this.layout = SkeletonLayout.list, super.key});

  final SkeletonLayout layout;

  @override
  Widget build(BuildContext context) => ShimmerLoading(
    child: SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: switch (layout) {
          SkeletonLayout.discovery => [
            SkeletonBlock(width: 110, height: 20),
            SizedBox(height: 20),
            FractionallySizedBox(
              widthFactor: 0.75,
              child: SkeletonBlock(height: 28),
            ),
            SizedBox(height: 10),
            FractionallySizedBox(
              widthFactor: 0.6,
              child: SkeletonBlock(height: 14),
            ),
            SizedBox(height: 24),
            SkeletonBlock(height: 180),
            SizedBox(height: 24),
            Row(
              children: [
                SkeletonBlock(width: 100, height: 20),
                SizedBox(width: 24),
                Expanded(child: SkeletonBlock(height: 20)),
              ],
            ),
            SizedBox(height: 24),
            SkeletonBlock(width: 80, height: 18),
            SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) => GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: constraints.maxWidth < 300 ? 1 : 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio:
                    (constraints.maxWidth < 300
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 10) / 2) /
                    172,
                children: List.generate(4, (_) => _TopicPlaceholder()),
              ),
            ),
          ],
          SkeletonLayout.question => [
            SkeletonBlock(width: 150, height: 18),
            SizedBox(height: 20),
            SkeletonBlock(height: 300),
            SizedBox(height: 20),
            SkeletonBlock(height: 48),
          ],
          SkeletonLayout.list => List.generate(
            5,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBlock(height: 22),
                  SizedBox(height: 12),
                  FractionallySizedBox(
                    widthFactor: 0.65,
                    child: SkeletonBlock(),
                  ),
                  SizedBox(height: 12),
                  SkeletonBlock(width: 90, height: 12),
                ],
              ),
            ),
          ),
        },
      ),
    ),
  );
}

class _TopicPlaceholder extends StatelessWidget {
  const _TopicPlaceholder();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(14, 14, 14, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBlock(width: 46, height: 46),
        SizedBox(height: 12),
        SkeletonBlock(),
        SizedBox(height: 8),
        FractionallySizedBox(widthFactor: 0.7, child: SkeletonBlock()),
        Spacer(),
        SkeletonBlock(width: 75, height: 12),
      ],
    ),
  );
}
