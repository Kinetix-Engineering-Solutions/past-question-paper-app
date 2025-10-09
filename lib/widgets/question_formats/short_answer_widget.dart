import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'package:past_question_paper_v1/viewmodels/practice_viewmodel.dart';

class ShortAnswerWidget extends ConsumerStatefulWidget {
  final Question question;
  final String? initialAnswer;

  const ShortAnswerWidget({
    Key? key,
    required this.question,
    this.initialAnswer,
  }) : super(key: key);

  @override
  ConsumerState<ShortAnswerWidget> createState() => _ShortAnswerWidgetState();
}

class _ShortAnswerWidgetState extends ConsumerState<ShortAnswerWidget> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAnswer ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
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
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Type your answer below. Be specific and clear.',
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
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          maxLines: 3,
          minLines: 3,
          style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ) ??
              TextStyle(fontSize: 16, color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Enter your answer here...',
            hintStyle: textTheme.bodyMedium?.copyWith(
                  color: textTheme.bodyMedium?.color?.withOpacity(0.6) ??
                      colorScheme.onSurfaceVariant,
                ) ??
                TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _controller.clear();
                      ref
                          .read(practiceViewModelProvider.notifier)
                          .answerQuestion(widget.question.id, '');
                    },
                    icon: Icon(
                      Icons.clear,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {}); // Update UI for suffix icon
            ref
                .read(practiceViewModelProvider.notifier)
                .answerQuestion(widget.question.id, value);
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Marks: ${widget.question.marks} • Be concise but complete',
                style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ) ??
                    TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
