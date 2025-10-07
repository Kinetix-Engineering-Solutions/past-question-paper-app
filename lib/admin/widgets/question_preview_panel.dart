import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/viewmodels/question_create_viewmodel.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';

/// Question Preview Panel - Shows current question state
class QuestionPreviewPanel extends ConsumerWidget {
  const QuestionPreviewPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questionCreateViewModelProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutralMid.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility, color: AppColors.accent),
              const SizedBox(width: 8),
              const Text(
                'Preview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildPreviewItem('Subject', state.subject),
          _buildPreviewItem('Grade', '${state.grade}'),
          _buildPreviewItem('Topic', state.topic.isEmpty ? '—' : state.topic),
          _buildPreviewItem('Format', state.format),
          _buildPreviewItem('Marks', '${state.marks}'),
          const Divider(height: 24),
          const Text(
            'Question:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.neutralMid.withOpacity(0.2)),
            ),
            child: Text(
              state.questionText.isEmpty
                  ? 'Question text will appear here...'
                  : state.questionText,
              style: TextStyle(
                color: state.questionText.isEmpty
                    ? AppColors.neutralMid
                    : AppColors.ink,
                fontStyle: state.questionText.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),
          if (state.correctAnswer.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildPreviewItem('Correct Answer', state.correctAnswer),
          ],
          if (state.correctOrder.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildPreviewItem('Correct Order', state.correctOrder),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.neutralMid,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: AppColors.neutralMid)),
          ),
        ],
      ),
    );
  }
}
