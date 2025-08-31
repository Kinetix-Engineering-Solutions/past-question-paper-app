import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/question.dart';
import 'package:past_question_paper_stem/utils/app_colors.dart';
import 'package:past_question_paper_stem/viewmodels/practice_viewmodel.dart';

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
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Type your answer below. Be specific and clear.',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
          style: const TextStyle(fontSize: 16, color: AppColors.ink),
          decoration: InputDecoration(
            hintText: 'Enter your answer here...',
            hintStyle: TextStyle(color: AppColors.neutralMid, fontSize: 16),
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
            suffixIcon:
                _controller.text.isNotEmpty
                    ? IconButton(
                      onPressed: () {
                        _controller.clear();
                        ref
                            .read(practiceViewModelProvider.notifier)
                            .answerQuestion(widget.question.id, '');
                      },
                      icon: Icon(Icons.clear, color: AppColors.neutralMid),
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
            Icon(Icons.info_outline, color: AppColors.neutralMid, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Marks: ${widget.question.marks} • Be concise but complete',
                style: TextStyle(color: AppColors.neutralMid, fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
