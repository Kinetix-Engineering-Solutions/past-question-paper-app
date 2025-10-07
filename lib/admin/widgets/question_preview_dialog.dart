import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';

/// Question Preview Dialog - Show full question details
class QuestionPreviewDialog extends StatelessWidget {
  final String questionId;

  const QuestionPreviewDialog({super.key, required this.questionId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 600),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('questions')
              .doc(questionId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                !snapshot.data!.exists) {
              return _buildErrorView(context);
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            return _buildPreviewContent(context, data);
          },
        ),
      ),
    );
  }

  Widget _buildPreviewContent(BuildContext context, Map<String, dynamic> data) {
    final format = data['questionType'] ?? '';

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.visibility, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Question Preview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Metadata badges
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildBadge(data['subject'] ?? '', Colors.blue),
                    _buildBadge('Grade ${data['grade']}', Colors.green),
                    _buildBadge(data['topic'] ?? '', Colors.orange),
                    _buildBadge(_getFormatLabel(format), Colors.purple),
                    _buildBadge('${data['marks']} marks', Colors.pink),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Question text
                const Text(
                  'Question:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.neutralMid.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    data['questionText'] ?? 'No question text',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),

                const SizedBox(height: 24),

                // Answer section based on format
                if (format == 'MCQ') _buildMCQAnswer(data),
                if (format == 'short_answer') _buildShortAnswer(data),
                if (format == 'drag_drop') _buildDragDropAnswer(data),

                const SizedBox(height: 24),

                // Additional info
                _buildInfoRow(
                  'Paper',
                  '${data['paper']} (${data['year']} ${data['season']})',
                ),
                _buildInfoRow('Cognitive Level', data['cognitiveLevel'] ?? '—'),
                _buildInfoRow('Difficulty', data['difficulty'] ?? '—'),
                _buildInfoRow(
                  'PQP Number',
                  data['pqpData']?['questionNumber'] ?? '—',
                ),
                _buildInfoRow('Created', _formatDate(data['createdAt'])),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMCQAnswer(Map<String, dynamic> data) {
    // Safely extract options
    List<String> options = [];
    if (data['options'] != null && data['options'] is List) {
      options = (data['options'] as List)
          .map((e) => e?.toString() ?? '')
          .toList();
    }

    final correctAnswer = (data['correctAnswer'] ?? '').toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Options:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...['A', 'B', 'C', 'D'].asMap().entries.map((entry) {
          final index = entry.key;
          final letter = entry.value;
          final isCorrect = correctAnswer == letter;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCorrect ? Colors.green.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCorrect
                    ? Colors.green
                    : AppColors.neutralMid.withOpacity(0.3),
                width: isCorrect ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green : AppColors.paper,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCorrect ? Colors.green : AppColors.neutralMid,
                    ),
                  ),
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.white : AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    index < options.length ? options[index] : 'N/A',
                    style: TextStyle(
                      fontWeight: isCorrect
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (isCorrect)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
          );
        }).toList(),

        if (data['explanation'] != null) ...[
          const SizedBox(height: 16),
          const Text(
            'Explanation:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(data['explanation']),
          ),
        ],
      ],
    );
  }

  Widget _buildShortAnswer(Map<String, dynamic> data) {
    final correctAnswer = (data['correctAnswer'] ?? '').toString();

    // Safely extract answer variations
    List<String> variations = [];
    if (data['answerVariations'] != null && data['answerVariations'] is List) {
      variations = (data['answerVariations'] as List)
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    final caseSensitive = data['caseSensitive'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Correct Answer:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green),
          ),
          child: Text(
            correctAnswer,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        if (variations.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Accepted Variations:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: variations.map((v) => Chip(label: Text(v))).toList(),
          ),
        ],

        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              caseSensitive ? Icons.check_circle : Icons.cancel,
              size: 16,
              color: caseSensitive ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text('Case Sensitive: ${caseSensitive ? "Yes" : "No"}'),
          ],
        ),
      ],
    );
  }

  Widget _buildDragDropAnswer(Map<String, dynamic> data) {
    // Safely extract drag items
    List<Map<String, dynamic>> dragItems = [];
    if (data['dragItems'] != null && data['dragItems'] is List) {
      dragItems = (data['dragItems'] as List)
          .map((item) {
            if (item is Map) {
              return Map<String, dynamic>.from(item);
            }
            return <String, dynamic>{};
          })
          .where((item) => item.isNotEmpty)
          .toList();
    }

    // Safely extract correct order
    List<String> correctOrder = [];
    if (data['correctOrder'] != null && data['correctOrder'] is List) {
      correctOrder = (data['correctOrder'] as List)
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Drag Items:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...dragItems.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.neutralMid.withOpacity(0.3)),
            ),
            child: Text(item['text'] ?? ''),
          );
        }).toList(),

        const SizedBox(height: 16),
        const Text(
          'Correct Order:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green),
          ),
          child: Text(
            correctOrder.join(' → '),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withOpacity(0.9),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.neutralMid,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text(
              'Failed to load question',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormatLabel(String format) {
    switch (format.toLowerCase()) {
      case 'mcq':
        return 'MCQ';
      case 'short_answer':
        return 'Short Answer';
      case 'drag_drop':
        return 'Drag & Drop';
      case 'true_false':
        return 'True/False';
      case 'essay':
        return 'Essay';
      default:
        return format;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '—';
    try {
      final date = (timestamp as Timestamp).toDate();
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '—';
    }
  }
}
