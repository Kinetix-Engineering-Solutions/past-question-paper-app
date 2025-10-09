import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'package:past_question_paper_v1/viewmodels/practice_viewmodel.dart';

class EssayWidget extends ConsumerStatefulWidget {
  final Question question;
  final String? initialAnswer;

  const EssayWidget({Key? key, required this.question, this.initialAnswer})
    : super(key: key);

  @override
  ConsumerState<EssayWidget> createState() => _EssayWidgetState();
}

class _EssayWidgetState extends ConsumerState<EssayWidget> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAnswer ?? '');
    _updateWordCount(_controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateWordCount(String text) {
    final words = text.trim().split(RegExp(r'\s+'));
    setState(() {
      _wordCount = text.trim().isEmpty ? 0 : words.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.article_outlined,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Essay Question',
                      style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ) ??
                          TextStyle(
                            color: colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Structure your answer with clear introduction, body, and conclusion\n'
                '• Support your points with relevant examples\n'
                '• Write in complete sentences and paragraphs',
                style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      height: 1.4,
                    ) ??
                    TextStyle(
                      color: colorScheme.primary,
                      fontSize: 12,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          maxLines: 12,
          minLines: 8,
          style: textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                color: colorScheme.onSurface,
                height: 1.5,
              ) ??
              TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface,
                height: 1.5,
              ),
          decoration: InputDecoration(
            hintText:
                'Write your essay here...\n\n'
                'Tip: Start with an outline of your main points, then elaborate on each point with examples and explanations.',
            hintStyle: textTheme.bodyMedium?.copyWith(
                  color: textTheme.bodyMedium?.color?.withOpacity(0.6) ??
                      colorScheme.onSurfaceVariant,
                  fontSize: 15,
                  height: 1.4,
                ) ??
                TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 15,
                  height: 1.4,
                ),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.primary.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: (value) {
            _updateWordCount(value);
            ref
                .read(practiceViewModelProvider.notifier)
                .answerQuestion(widget.question.id, value);
          },
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Word count: $_wordCount',
                style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ) ??
                    TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const Spacer(),
              Text(
                'Marks: ${widget.question.marks}',
                style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ) ??
                    TextStyle(
                      color: colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: colorScheme.onSurfaceVariant,
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Take time to plan your answer. Quality is more important than quantity.',
                style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ) ??
                    TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
