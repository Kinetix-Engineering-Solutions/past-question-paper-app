import 'package:flutter/material.dart';

class QuizTypeSelector extends StatelessWidget {
  final void Function(String type) onSelect;

  const QuizTypeSelector({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final types = [
      {
        'icon': Icons.check_box,
        'title': 'True or False',
        'desc': 'Answer with true or false',
        'type': 'true false',
      },
      {
        'icon': Icons.check_circle_outline,
        'title': 'Multiple Choice',
        'desc': 'Answer one from 4 options',
        'type': 'mcq',
      },
      {
        'icon': Icons.link,
        'title': 'Match the Following',
        'desc': 'Connect related pairs',
        'type': 'matching',
      },
      {
        'icon': Icons.drag_indicator,
        'title': 'Drag and Drop',
        'desc': 'Rearrange to match the question',
        'type': 'dragdrop',
      },
      {
        'icon': Icons.short_text,
        'title': 'Short Answer',
        'desc': 'Brief response required',
        'type': 'short',
      },
      {
        'icon': Icons.subject,
        'title': 'Long Answer',
        'desc': 'Write a detailed response',
        'type': 'long',
      },
    ];

    return ListView.builder(
      itemCount: types.length,
      itemBuilder: (context, index) {
        final item = types[index];
        return GestureDetector(
          onTap: () => onSelect(item['type'] as String),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
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
                Icon(item['icon'] as IconData, size: 32, color: Colors.blueAccent),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'] as String,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(item['desc'] as String,
                          style: const TextStyle(color: Colors.grey)),
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
