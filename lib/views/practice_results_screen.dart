import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/practice_session.dart';
import 'package:past_question_paper_stem/model/question.dart';
import 'package:past_question_paper_stem/viewmodels/practice_viewmodel.dart';

class PracticeResultsScreen extends ConsumerWidget {
  const PracticeResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final practiceState = ref.watch(practiceViewModelProvider);
    final practiceViewModel = ref.read(practiceViewModelProvider.notifier);

    final session = practiceState.currentSession;
    if (session == null) {
      return const Scaffold(
        body: Center(child: Text('No session data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Results'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreCard(session),
            const SizedBox(height: 24),
            _buildSessionSummary(session),
            const SizedBox(height: 24),
            _buildQuestionReview(session),
            const SizedBox(height: 32),
            _buildActionButtons(context, practiceViewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(PracticeSession session) {
    final score = session.score ?? 0;
    final isGoodScore = score >= 70;
    final isExcellentScore = score >= 90;

    Color scoreColor;
    String scoreEmoji;
    String scoreMessage;

    if (isExcellentScore) {
      scoreColor = Colors.green;
      scoreEmoji = '🎉';
      scoreMessage = 'Excellent work!';
    } else if (isGoodScore) {
      scoreColor = Colors.orange;
      scoreEmoji = '👍';
      scoreMessage = 'Good job!';
    } else {
      scoreColor = Colors.red;
      scoreEmoji = '💪';
      scoreMessage = 'Keep practicing!';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scoreColor.withOpacity(0.1), scoreColor.withOpacity(0.05)],
          ),
        ),
        child: Column(
          children: [
            Text(scoreEmoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              '$score%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              scoreMessage,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: scoreColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your practice score',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionSummary(PracticeSession session) {
    final duration = session.duration ?? session.elapsedTime;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              icon: Icons.topic,
              label: 'Topic',
              value: session.topic.name,
              color: Colors.blue,
            ),
            _buildSummaryRow(
              icon: Icons.access_time,
              label: 'Mode',
              value: session.mode.name,
              color: Colors.green,
            ),
            _buildSummaryRow(
              icon: Icons.timer,
              label: 'Duration',
              value: '${minutes}m ${seconds}s',
              color: Colors.orange,
            ),
            _buildSummaryRow(
              icon: Icons.quiz,
              label: 'Questions',
              value: '${session.questions.length} total',
              color: Colors.purple,
            ),
            _buildSummaryRow(
              icon: Icons.check_circle,
              label: 'Answered',
              value: '${session.answeredCount}/${session.questions.length}',
              color: Colors.teal,
            ),
            if (session.status == PracticeSessionStatus.timeExpired)
              _buildSummaryRow(
                icon: Icons.warning,
                label: 'Status',
                value: 'Time Expired',
                color: Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionReview(PracticeSession session) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Question Review',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...session.questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return _buildQuestionReviewItem(session, question, index);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionReviewItem(
    PracticeSession session,
    Question question,
    int index,
  ) {
    final userAnswer = session.userAnswers[question.id];
    final isAnswered = userAnswer != null;
    final isCorrect = isAnswered && _isAnswerCorrect(question, userAnswer);

    Icon statusIcon;
    Color statusColor;

    if (!isAnswered) {
      statusIcon = const Icon(Icons.help_outline, color: Colors.grey);
      statusColor = Colors.grey;
    } else if (isCorrect) {
      statusIcon = const Icon(Icons.check_circle, color: Colors.green);
      statusColor = Colors.green;
    } else {
      statusIcon = const Icon(Icons.cancel, color: Colors.red);
      statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.questionText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (isAnswered) ...[
                  Text(
                    'Your answer: $userAnswer',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (!isCorrect) ...[
                    Text(
                      'Correct: ${question.correctAnswer.join(', ')}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ] else ...[
                  Text(
                    'Not answered',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          statusIcon,
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    PracticeViewModel viewModel,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              viewModel.endSession();
              Navigator.of(context).popUntil(
                (route) => route.settings.name == '/' || route.isFirst,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Back to Topics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // TODO: Implement practice again functionality
              viewModel.endSession();
              Navigator.of(context).pop();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Practice Again',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  bool _isAnswerCorrect(Question question, dynamic userAnswer) {
    switch (question.questionType.toLowerCase()) {
      case 'multiple-choice':
      case 'true-false':
        return question.correctAnswer.contains(userAnswer.toString());

      case 'drag-and-drop':
        if (userAnswer is List<int>) {
          return _listsEqual(userAnswer, question.correctOrder);
        }
        return false;

      default:
        return false;
    }
  }

  bool _listsEqual<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
