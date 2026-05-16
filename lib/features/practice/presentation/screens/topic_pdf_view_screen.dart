import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/core/theme/app_colors.dart';

class TopicPdfViewScreen extends StatefulWidget {
  final String topic;
  final String subject;
  final int grade;

  const TopicPdfViewScreen({
    super.key,
    required this.topic,
    required this.subject,
    required this.grade,
  });

  @override
  State<TopicPdfViewScreen> createState() => _TopicPdfViewScreenState();
}

class _TopicPdfViewScreenState extends State<TopicPdfViewScreen> {
  final Set<int> _attempted = <int>{};
  final Set<int> _reviewLater = <int>{};

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.topic} • PDF View'),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text('AI Help'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(label: _toTitle(widget.subject)),
                _MetaChip(label: 'Grade ${widget.grade}'),
                const _MetaChip(label: 'Read-only PDF'),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.picture_as_pdf_outlined,
                        size: 52,
                        color: AppColors.accent,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Topic PDF Packet Mockup',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'This area will render the view-only topic packet PDF.\nNo print/download actions are shown in this mode.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutralMid,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                    child: Row(
                      children: [
                        Text(
                          'Question Navigator',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_attempted.length}/10 attempted',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      itemCount: 10,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final questionNumber = index + 1;
                        final isAttempted = _attempted.contains(questionNumber);
                        final isReview = _reviewLater.contains(questionNumber);

                        return ListTile(
                          dense: true,
                          title: Text('Question $questionNumber'),
                          subtitle: Text(
                            isReview
                                ? 'Marked for review'
                                : isAttempted
                                ? 'Attempted'
                                : 'Not attempted',
                          ),
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              IconButton(
                                tooltip: 'Toggle attempted',
                                onPressed: () {
                                  setState(() {
                                    if (isAttempted) {
                                      _attempted.remove(questionNumber);
                                    } else {
                                      _attempted.add(questionNumber);
                                    }
                                  });
                                },
                                icon: Icon(
                                  isAttempted
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
                                  color: isAttempted
                                      ? Colors.green
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Mark for review',
                                onPressed: () {
                                  setState(() {
                                    if (isReview) {
                                      _reviewLater.remove(questionNumber);
                                    } else {
                                      _reviewLater.add(questionNumber);
                                    }
                                  });
                                },
                                icon: Icon(
                                  isReview ? Icons.flag : Icons.outlined_flag,
                                  color: isReview
                                      ? AppColors.accent
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _toTitle(String value) {
    return value
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return '${word[0].toUpperCase()}${word.substring(1)}';
        })
        .join(' ');
  }
}

class _MetaChip extends StatelessWidget {
  final String label;

  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: AppColors.neutralCard,
      side: const BorderSide(color: AppColors.neutralBorder),
      labelStyle: Theme.of(context).textTheme.bodySmall,
    );
  }
}
