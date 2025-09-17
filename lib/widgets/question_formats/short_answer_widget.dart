import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
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

  void _showHintsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.accent),
              const SizedBox(width: 8),
              const Text('Hints'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.question.hints!
                  .asMap()
                  .entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
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
            suffixIcon: _controller.text.isNotEmpty
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
            Text(
              'Marks: ${widget.question.marks}',
              style: TextStyle(color: AppColors.neutralMid, fontSize: 12),
            ),
            const Spacer(),
            // NEW: Hints Button (if available)
            if (widget.question.hints != null &&
                widget.question.hints!.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _showHintsDialog(context),
                icon: Icon(Icons.lightbulb_outline, size: 16),
                label: const Text('Hints'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),

        // NEW: Working Steps Section (if available and showWorking is true)
        if (widget.question.showWorking == true &&
            widget.question.workingSteps != null &&
            widget.question.workingSteps!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: ExpansionTile(
              title: const Text('Working Steps'),
              leading: Icon(Icons.list_alt, color: AppColors.accent),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.question.workingSteps!
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${entry.key + 1}. ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                  ),
                                ),
                                Expanded(child: Text(entry.value)),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
