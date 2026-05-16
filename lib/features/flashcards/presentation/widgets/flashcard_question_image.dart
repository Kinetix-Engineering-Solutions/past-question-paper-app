import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FlashcardQuestionImage extends StatelessWidget {
  final String? imageUrl;
  final bool blurred;

  const FlashcardQuestionImage({
    super.key,
    required this.imageUrl,
    this.blurred = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return Center(
        child: Icon(
          Icons.broken_image,
          size: 52,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth;

        Image buildImage(ImageProvider provider) {
          return Image(
            image: provider,
            width: contentWidth,
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          );
        }

        Widget wrapScrollable(Widget child) {
          return SingleChildScrollView(
            primary: false,
            physics: const ClampingScrollPhysics(),
            child: child,
          );
        }

        return CachedNetworkImage(
          imageUrl: imageUrl!,
          imageBuilder: (context, provider) {
            if (!blurred) {
              return wrapScrollable(buildImage(provider));
            }

            const lightSigma = 4.0;
            const strongSigma = 16.0;

            final lightBlurLayer = ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: lightSigma,
                sigmaY: lightSigma,
              ),
              child: buildImage(provider),
            );

            final strongBlurLayer = ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: <double>[0.0, 0.35, 1.0],
                  colors: <Color>[
                    Color(0x00FFFFFF),
                    Color(0x88FFFFFF),
                    Color(0xFFFFFFFF),
                  ],
                ).createShader(rect);
              },
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: strongSigma,
                  sigmaY: strongSigma,
                ),
                child: buildImage(provider),
              ),
            );

            final blurredWidget = ClipRect(
              child: Stack(
                children: <Widget>[
                  lightBlurLayer,
                  strongBlurLayer,
                  Container(color: colorScheme.scrim.withValues(alpha: 0.06)),
                ],
              ),
            );

            return wrapScrollable(blurredWidget);
          },
          placeholder: (context, url) => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Center(
            child: Icon(
              Icons.broken_image,
              size: 52,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}
