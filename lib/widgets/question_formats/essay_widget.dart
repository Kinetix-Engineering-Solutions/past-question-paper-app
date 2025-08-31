import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.article_outlined,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Essay Question',
                      style: TextStyle(
                        color: AppColors.accent,
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
                style: TextStyle(
                  color: AppColors.accent,
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
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.ink,
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText:
                'Write your essay here...\n\n'
                'Tip: Start with an outline of your main points, then elaborate on each point with examples and explanations.',
            hintStyle: TextStyle(
              color: AppColors.neutralMid,
              fontSize: 15,
              height: 1.4,
            ),
            filled: true,
            fillColor: AppColors.neutralCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.neutralBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.neutralBorder,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.accent, width: 2),
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
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.neutralBorder),
          ),
          child: Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppColors.neutralMid,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Word count: $_wordCount',
                style: TextStyle(
                  color: AppColors.neutralMid,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                'Marks: ${widget.question.marks}',
                style: TextStyle(
                  color: AppColors.accent,
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
              color: AppColors.neutralMid,
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Take time to plan your answer. Quality is more important than quantity.',
                style: TextStyle(
                  color: AppColors.neutralMid,
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


