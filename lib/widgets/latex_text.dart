import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class LatexText extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final double? fontSize;
  final Color? textColor;
  final TextAlign? textAlign;

  const LatexText(
    this.text, {
    super.key,
    this.textStyle,
    this.fontSize,
    this.textColor,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    // Use theme color if no textColor is provided
    final defaultColor = textColor ?? Theme.of(context).colorScheme.onSurface;
    final errorColor = Theme.of(context).colorScheme.error;
    
    final defaultStyle = TextStyle(
      fontSize: fontSize ?? 16,
      color: defaultColor,
    );

    final style = textStyle?.merge(defaultStyle) ?? defaultStyle;

    return _buildMixedContent(text, style, errorColor);
  }

  Widget _buildMixedContent(String text, TextStyle style, Color errorColor) {
    // First check if text contains LaTeX wrapped in $ or $$
    final wrappedLatexPattern = RegExp(r'\$\$(.+?)\$\$|\$(.+?)\$');
    final wrappedMatches = wrappedLatexPattern.allMatches(text);

    if (wrappedMatches.isNotEmpty) {
      return _buildWrappedLatexContent(text, style, wrappedMatches, errorColor);
    }

    // Check for common LaTeX patterns and try to build mixed content
    final mathPattern = RegExp(
      r'([^a-zA-Z]*)([a-zA-Z]*\s*)(\d*[a-zA-Z]+[\^\{\}0-9]*[+\-=][^$]*)',
      multiLine: true,
    );
    final mathMatches = mathPattern.allMatches(text);

    if (mathMatches.isNotEmpty) {
      return _buildMixedTextAndMath(text, style);
    }

    // Check for simple superscript patterns
    if (text.contains(RegExp(r'\w\^\{?\d+\}?'))) {
      return _buildMixedTextAndMath(text, style);
    }

    // No LaTeX found, return regular text with proper spacing
    return _buildTextWithSpacing(text, style);
  }

  Widget _buildMixedTextAndMath(String text, TextStyle style) {
    // Split text into words and identify math parts
    final words = text.split(' ');
    List<InlineSpan> spans = [];

    for (int i = 0; i < words.length; i++) {
      final word = words[i];

      // Check if word contains math notation
      if (word.contains(RegExp(r'[\^\{\}+\-=]|\d+[a-zA-Z]|[a-zA-Z]+\d'))) {
        try {
          // Try to render as LaTeX
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Math.tex(
                    word,
                    mathStyle: MathStyle.text,
                    textStyle: style,
                  ),
                ),
              ),
            ),
          );
        } catch (e) {
          // If LaTeX fails, render as regular text
          spans.add(TextSpan(text: word, style: style));
        }
      } else {
        // Regular word
        spans.add(TextSpan(text: word, style: style));
      }

      // Add space between words (except for the last word)
      if (i < words.length - 1) {
        spans.add(const TextSpan(text: ' '));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: textAlign ?? TextAlign.left,
    );
  }

  Widget _buildTextWithSpacing(String text, TextStyle style) {
    // Clean up spacing for better readability
    String processedText = text;

    // Ensure proper spacing around common words
    processedText = processedText.replaceAll(RegExp(r'\bfor\s*x\b'), 'for x ');
    processedText = processedText.replaceAll(
      RegExp(r'solve\s*for'),
      'solve for ',
    );

    // Add spaces around mathematical operators
    processedText = processedText.replaceAllMapped(
      RegExp(r'(\w)([+\-=])(\w)'),
      (match) => '${match.group(1)} ${match.group(2)} ${match.group(3)}',
    );

    // Clean up multiple spaces
    processedText = processedText.replaceAll(RegExp(r'\s+'), ' ').trim();

    return Text(processedText, style: style, textAlign: textAlign);
  }

  Widget _buildWrappedLatexContent(
    String text,
    TextStyle style,
    Iterable<RegExpMatch> matches,
    Color errorColor,
  ) {
    // Build mixed content with LaTeX and regular text
    List<InlineSpan> spans = [];
    int lastEnd = 0;

    for (final match in matches) {
      // Add regular text before LaTeX
      if (match.start > lastEnd) {
        final beforeLatex = text.substring(lastEnd, match.start);
        spans.add(TextSpan(text: beforeLatex, style: style));
      }

      // Add LaTeX content
      final latexContent = match.group(1) ?? match.group(2) ?? '';
      final isDisplayMode = match.group(1) != null; // $$ for display mode

      try {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Math.tex(
                  latexContent,
                  mathStyle: isDisplayMode ? MathStyle.display : MathStyle.text,
                  textStyle: style,
                ),
              ),
            ),
          ),
        );
      } catch (e) {
        // Fallback to regular text if LaTeX parsing fails
        spans.add(
          TextSpan(
            text: '\$${latexContent}\$',
            style: style.copyWith(
              color: errorColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      }

      lastEnd = match.end;
    }

    // Add remaining regular text
    if (lastEnd < text.length) {
      final remaining = text.substring(lastEnd);
      spans.add(TextSpan(text: remaining, style: style));
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: textAlign ?? TextAlign.left,
    );
  }
}
