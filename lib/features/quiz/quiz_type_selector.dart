import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:past_question_paper_v1/core/models/quiz_type.dart';

class QuizTypeSelector extends ConsumerWidget {
  final String subjectId;
  final void Function(QuizType type, String subjectId) onSelect;

  const QuizTypeSelector({
    super.key,
    required this.onSelect,
    required this.subjectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = [
      {
        'icon': Icons.check_circle_outline,
        'title': 'True or False',
        'desc': 'Choose true or false for each question',
        'type': QuizType.trueFalse,
      },
      {
        'icon': Icons.checklist_outlined,
        'title': 'Multiple Choice',
        'desc': 'Select one correct answer from options',
        'type': QuizType.multipleChoice,
      },
      {
        'icon': Icons.link,
        'title': 'Match the Following',
        'desc': 'Connect related pairs correctly',
        'type': QuizType.matching,
      },
      {
        'icon': Icons.edit,
        'title': 'Short Answer',
        'desc': 'Write a brief answer to each question',
        'type': QuizType.shortAnswer,
      },
      {
        'icon': Icons.notes,
        'title': 'Long Answer',
        'desc': 'Write a detailed explanation or essay',
        'type': QuizType.longAnswer,
      },
      {
        'icon': Icons.swap_vert_circle_outlined,
        'title': 'Drag and Drop',
        'desc': 'Match or sort items interactively',
        'type': QuizType.dragDrop,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final item = types[index];
        return GestureDetector(
          onTap: () {
            final type = item['type'] as QuizType;
            onSelect(type, subjectId);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(item['icon'] as IconData, size: 32, color: Colors.deepPurple),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['desc'] as String,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}