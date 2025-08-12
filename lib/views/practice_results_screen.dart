import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/practice_session.dart';
import 'package:past_question_paper_stem/model/question.dart';
import 'package:past_question_paper_stem/viewmodels/practice_viewmodel.dart';
import 'package:past_question_paper_stem/utils/app_colors.dart';
import 'package:past_question_paper_stem/views/practice_session_screen.dart';

class PracticeResultsScreen extends ConsumerWidget {
  const PracticeResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final practiceState = ref.watch(practiceViewModelProvider);
    final practiceViewModel = ref.read(practiceViewModelProvider.notifier);

    // Listen for new session creation and navigate to it
    ref.listen(practiceViewModelProvider, (previous, current) {
      // Check if a new session was created (different from results screen session)
      if (current.currentSession != null &&
          previous?.currentSession != current.currentSession &&
          current.currentSession!.status == PracticeSessionStatus.inProgress) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const PracticeSessionScreen(),
          ),
        );
      }
    });

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
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.neutralCard,
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
            _buildActionButtons(context, ref, practiceViewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(PracticeSession session) {
    final score = session.score ?? 0;
    final isGoodScore = score >= 70;
    final isExcellentScore = score >= 90;

    // Calculate detailed stats for debugging
    int correctAnswers = 0;
    int totalQuestions = session.questions.length;
    int answeredQuestions = 0;

    for (final question in session.questions) {
      final userAnswer = session.userAnswers[question.id];
      if (userAnswer != null) {
        answeredQuestions++;
        if (session.isAnswerCorrect(question, userAnswer)) {
          correctAnswers++;
        }
      }
    }

    // Manual score calculation for verification
    final manualScore =
        totalQuestions > 0
            ? (correctAnswers / totalQuestions * 100).round()
            : 0;

    // Debug print to console
    print('🏆 Score Debug:');
    print('   Session score: $score');
    print('   Manual calculation: $manualScore');
    print('   Correct: $correctAnswers / $totalQuestions');
    print('   Answered: $answeredQuestions');
    print('   Session status: ${session.status}');
    print('   Session completed: ${session.isCompleted}');
    print('   Session expired: ${session.isExpired}');
    print('   Session finished: ${session.isFinished}');

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
            const SizedBox(height: 8),
            Text(
              '$correctAnswers out of $totalQuestions correct ($answeredQuestions answered)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (score != manualScore) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '⚠️ Score mismatch: Expected $manualScore%',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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
              color: AppColors.accent,
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
    final isCorrect =
        isAnswered && session.isAnswerCorrect(question, userAnswer);

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
                    'Your answer: ${session.formatUserAnswer(question, userAnswer)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (!isCorrect) ...[
                    Text(
                      'Correct: ${session.formatCorrectAnswer(question)}',
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
    WidgetRef ref,
    PracticeViewModel viewModel,
  ) {
    final practiceState = ref.watch(practiceViewModelProvider);
    final isStartingNewSession = practiceState.isLoading;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              viewModel.endSession();
              // Navigate back to the beginning of the navigation stack
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.neutralCard,
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
            onPressed:
                isStartingNewSession
                    ? null
                    : () async {
                      try {
                        await viewModel.startNewSession();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to start new session: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child:
                isStartingNewSession
                    ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Starting new session...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                    : const Text(
                      'Practice Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}
