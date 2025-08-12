import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/practice_mode.dart';
import 'package:past_question_paper_stem/model/topic.dart';
import 'package:past_question_paper_stem/viewmodels/practice_viewmodel.dart';
import 'package:past_question_paper_stem/views/question_screen_test.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  final Topic topic;
  final PracticeMode mode;

  const PracticeScreen({super.key, required this.topic, required this.mode});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  @override
  void initState() {
    super.initState();
    // Load questions and start practice session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePractice();
    });
  }

  Future<void> _initializePractice() async {
    final practiceNotifier = ref.read(practiceViewModelProvider.notifier);

    // Load questions for the topic
    await practiceNotifier.loadQuestionsForTopic(widget.topic);

    // Start the practice session
    await practiceNotifier.startPracticeSession(widget.topic, widget.mode);
  }

  @override
  Widget build(BuildContext context) {
    final practiceState = ref.watch(practiceViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.topic.id} - ${widget.mode.toString().split('.').last}',
        ),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        actions: [
          if (practiceState.hasActiveSession) ...[
            // Show progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  '${practiceState.currentSession!.currentQuestionIndex + 1}/${practiceState.currentSession!.questions.length}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            // Show timer if applicable
            if (practiceState.remainingTime != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    _formatTime(practiceState.remainingTime!),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color:
                          practiceState.remainingTime!.inMinutes < 2
                              ? Colors.red[300]
                              : Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
      body: _buildBody(practiceState),
    );
  }

  Widget _buildBody(PracticeState practiceState) {
    if (practiceState.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading questions...'),
          ],
        ),
      );
    }

    if (practiceState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error: ${practiceState.error}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(practiceViewModelProvider.notifier).clearError();
                _initializePractice();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (practiceState.showResults) {
      return _buildResultsScreen(practiceState);
    }

    if (!practiceState.hasActiveSession) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 64, color: Colors.brown),
            SizedBox(height: 16),
            Text(
              'Ready to start practice?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _initializePractice,
              child: Text('Start Practice'),
            ),
          ],
        ),
      );
    }

    // Show the current question
    return QuestionScreenTest(
      questionId: practiceState.currentQuestion!.id,
      questionIds:
          practiceState.currentSession!.questions.map((q) => q.id).toList(),
    );
  }

  Widget _buildResultsScreen(PracticeState practiceState) {
    final session = practiceState.currentSession!;
    final score = session.score ?? 0;
    final totalQuestions = session.questions.length;
    final percentage =
        totalQuestions > 0 ? (score / totalQuestions * 100).round() : 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              percentage >= 70 ? Icons.celebration : Icons.sentiment_neutral,
              size: 80,
              color: percentage >= 70 ? Colors.green : Colors.orange,
            ),
            SizedBox(height: 24),
            Text(
              'Practice Complete!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 16),
            Text(
              'Score: $score/$totalQuestions ($percentage%)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              'Time: ${_formatDuration(session.duration)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ref.read(practiceViewModelProvider.notifier).endSession();
                    Navigator.of(context).pop();
                  },
                  child: Text('Finish'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(practiceViewModelProvider.notifier).endSession();
                    _initializePractice();
                  },
                  child: Text('Practice Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'N/A';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  void dispose() {
    // Clean up practice session when leaving the screen
    ref.read(practiceViewModelProvider.notifier).endSession();
    super.dispose();
  }
}
