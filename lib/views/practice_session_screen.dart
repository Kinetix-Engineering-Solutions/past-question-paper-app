import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/practice_session.dart';
import 'package:past_question_paper_stem/model/question.dart';
import 'package:past_question_paper_stem/viewmodels/practice_viewmodel.dart';
import 'package:past_question_paper_stem/views/practice_results_screen.dart';

class PracticeSessionScreen extends ConsumerStatefulWidget {
  const PracticeSessionScreen({super.key});

  @override
  ConsumerState<PracticeSessionScreen> createState() =>
      _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends ConsumerState<PracticeSessionScreen> {
  String? selectedAnswer;

  @override
  Widget build(BuildContext context) {
    final practiceState = ref.watch(practiceViewModelProvider);
    final practiceViewModel = ref.read(practiceViewModelProvider.notifier);

    // Listen for session completion and navigate to results
    ref.listen(practiceViewModelProvider, (previous, current) {
      if (current.showResults && current.currentSession != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const PracticeResultsScreen(),
          ),
        );
      }
    });

    final session = practiceState.currentSession;
    if (session == null) {
      return const Scaffold(
        body: Center(child: Text('No active practice session')),
      );
    }

    final currentQuestion = session.currentQuestion;
    if (currentQuestion == null) {
      return const Scaffold(body: Center(child: Text('No current question')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(session.topic.name),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.pause),
          onPressed: () => _showPauseDialog(practiceViewModel),
        ),
        actions: [
          if (session.mode.isTimeLimited)
            _buildTimerDisplay(practiceState.remainingTime),
        ],
      ),
      body: Column(
        children: [
          _buildProgressBar(session),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionInfo(session),
                  const SizedBox(height: 24),
                  _buildQuestionCard(currentQuestion),
                  const SizedBox(height: 24),
                  _buildAnswerOptions(currentQuestion),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildNavigationButtons(session, practiceViewModel),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(Duration? remainingTime) {
    if (remainingTime == null) return const SizedBox.shrink();

    final minutes = remainingTime.inMinutes;
    final seconds = remainingTime.inSeconds % 60;
    final isUrgent = remainingTime.inMinutes < 2;

    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.red.shade100 : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isUrgent ? Colors.red.shade700 : Colors.white,
        ),
      ),
    );
  }

  Widget _buildProgressBar(PracticeSession session) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${session.currentQuestionIndex + 1} of ${session.questions.length}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${(session.progress * 100).round()}% Complete',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: session.progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionInfo(PracticeSession session) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            session.mode.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${session.answeredCount}/${session.questions.length} Answered',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getQuestionTypeColor(
                      question.questionType,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    question.questionType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getQuestionTypeColor(question.questionType),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              question.questionText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            if (question.hasQuestionImage) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  question.questionImage!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(Question question) {
    switch (question.questionType.toLowerCase()) {
      case 'multiple-choice':
      case 'true-false':
        return _buildMultipleChoiceOptions(question);
      case 'drag-and-drop':
        return _buildDragAndDropOptions(question);
      default:
        return const Text('Unsupported question type');
    }
  }

  Widget _buildMultipleChoiceOptions(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select your answer:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...question.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final optionLabel = String.fromCharCode(65 + index); // A, B, C, D...
          final isSelected = selectedAnswer == option;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Card(
              elevation: isSelected ? 3 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color:
                      isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: InkWell(
                onTap: () => _selectAnswer(option),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Colors.blue.shade600
                                  : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            optionLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected ? Colors.blue.shade600 : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDragAndDropOptions(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Drag and drop to arrange in correct order:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        const Text(
          'Drag and drop functionality coming soon...',
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
        // TODO: Implement drag and drop functionality
      ],
    );
  }

  Widget _buildNavigationButtons(
    PracticeSession session,
    PracticeViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          if (session.currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  viewModel.previousQuestion();
                  setState(() {
                    selectedAnswer = null;
                  });
                },
                child: const Text('Previous'),
              ),
            ),
          if (session.currentQuestionIndex > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed:
                  selectedAnswer != null || session.currentQuestionIndex > 0
                      ? () => _nextQuestion(viewModel)
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
              child: Text(session.isLastQuestion ? 'Finish' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
    });
  }

  void _nextQuestion(PracticeViewModel viewModel) {
    if (selectedAnswer != null) {
      viewModel.answerQuestion(selectedAnswer);
    }
    viewModel.nextQuestion();
    setState(() {
      selectedAnswer = null;
    });
  }

  void _showPauseDialog(PracticeViewModel viewModel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pause Practice'),
          content: const Text('Do you want to pause this practice session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue'),
            ),
            TextButton(
              onPressed: () {
                viewModel.pauseSession();
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to topic screen
              },
              child: const Text('Pause'),
            ),
          ],
        );
      },
    );
  }

  Color _getQuestionTypeColor(String questionType) {
    switch (questionType.toLowerCase()) {
      case 'multiple-choice':
        return Colors.blue;
      case 'true-false':
        return Colors.green;
      case 'drag-and-drop':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
