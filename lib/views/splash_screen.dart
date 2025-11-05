import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final Duration displayDuration;
  final String? nextRoute;

  const SplashScreen({
    Key? key,
    this.displayDuration = const Duration(
      milliseconds: 2300,
    ), // slightly longer for stability
    this.nextRoute,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _logoLift;
  Timer? _timer; // keeps reference so we can cancel on dispose

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _scale = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCirc));

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 1.0, curve: Curves.easeIn),
      ),
    );

    _logoLift = Tween<double>(
      begin: 8.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    // Start the animation first
    _controller.forward().whenComplete(() {
      // Once animation finishes, wait display duration before navigating
      _timer = Timer(widget.displayDuration, () {
        if (!mounted) return;
        final next = widget.nextRoute ?? '/login';
        Navigator.of(context).pushReplacementNamed(next);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel(); // avoid late callback after dispose
    super.dispose();
  }

  Widget _decorativeBlobs() {
    return Stack(
      children: [
        Positioned(
          left: -60,
          top: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.accent.withOpacity(0.18),
                  AppColors.accent.withOpacity(0.02),
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -80,
          bottom: -60,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.ink.withOpacity(0.06),
                  AppColors.ink.withOpacity(0.0),
                ],
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // background gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.paper,
                        AppColors.paper.withOpacity(0.95),
                      ],
                    ),
                  ),
                ),

                // Decorative blobs behind logo
                Positioned.fill(
                  child: IgnorePointer(child: _decorativeBlobs()),
                ),

                // Centered content
                SafeArea(
                  child: Center(
                    child: FadeTransition(
                      opacity: _fade,
                      child: Transform.translate(
                        offset: Offset(0, _logoLift.value),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // frosted circular logo area
                            ClipOval(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX:
                                      4.5, // reduced slightly for smoothness
                                  sigmaY: 4.5,
                                ),
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: AppColors.neutralCard.withOpacity(
                                      0.3,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.ink.withOpacity(0.06),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: AppColors.neutralCard.withOpacity(
                                        0.14,
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: Image.asset(
                                      'assets/images/splash_logo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            Opacity(
                              opacity: _fade.value,
                              child: Column(
                                children: [
                                  Text(
                                    'Past Question Papers',
                                    style: TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Practice. Learn. Improve.',
                                    style: TextStyle(
                                      color: AppColors.ink.withOpacity(0.6),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
