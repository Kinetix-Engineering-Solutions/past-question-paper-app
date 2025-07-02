import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/core/models/quiz_type.dart';
import 'quiz_flow_screen.dart';

class QuizTypeSelector extends StatelessWidget {
  final void Function(QuizType type) onSelect;

  const QuizTypeSelector({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildQuizTypeTile(
            icon: Icons.check_circle_outline,
            title: 'True or False',
            subtitle: 'Choose true or false for each question',
            onTap: () => onSelect(QuizType.trueFalse),
          ),
          const SizedBox(height: 12),
          _buildQuizTypeTile(
            icon: Icons.check_circle_outline,
            title: 'Multiple Choice',
            subtitle: 'Answer one from 4 options',
            onTap: () => onSelect(QuizType.multipleChoice),
          ),
          const SizedBox(height: 12),
          _buildQuizTypeTile(
            icon: Icons.link,
            title: 'Match the Following',
            subtitle: 'Connect related pairs',
            onTap: () => onSelect(QuizType.matching),
          ),
          const SizedBox(height: 12),
          _buildQuizTypeTile(
            icon: Icons.drag_indicator,
            title: 'Drag and Drop',
            subtitle: 'Rearrange to match the question',
            onTap: () => onSelect(QuizType.dragDrop),
          ),
          const SizedBox(height: 12),
          _buildQuizTypeTile(
            icon: Icons.short_text,
            title: 'Short Answer',
            subtitle: 'Brief response required',
            onTap: () => onSelect(QuizType.shortAnswer),
          ),
          const SizedBox(height: 12),
          _buildQuizTypeTile(
            icon: Icons.subject,
            title: 'Long Answer',
            subtitle: 'Write a detailed response',
            onTap: () => onSelect(QuizType.longAnswer),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizTypeTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Icon(icon, size: 32, color: Colors.grey[700]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
