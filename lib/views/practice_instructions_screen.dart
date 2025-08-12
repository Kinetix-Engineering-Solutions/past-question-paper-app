import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/viewmodels/practice_viewmodel.dart';
import 'package:past_question_paper_stem/views/practice_session_screen.dart';
import 'package:past_question_paper_stem/model/topic.dart';
import 'package:past_question_paper_stem/model/practice_mode.dart';

class PracticeInstructionsScreen extends ConsumerWidget {
  final Topic topic;
  final PracticeMode mode;

  const PracticeInstructionsScreen({
    super.key,
    required this.topic,
    required this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final practiceState = ref.watch(practiceViewModelProvider);
    final practiceViewModel = ref.read(practiceViewModelProvider.notifier);

    // Load questions when the screen is first built if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (practiceState.availableQuestions.isEmpty &&
          !practiceState.isLoading) {
        practiceViewModel.loadQuestionsForTopic(topic);
      }
    });

    // Listen for session creation and navigate to practice screen
    ref.listen(practiceViewModelProvider, (previous, current) {
      // If questions are loaded and we have a session, we're ready
      if (current.currentSession != null &&
          current.currentSession!.isActive &&
          previous?.currentSession != current.currentSession) {
        // Navigate to practice session screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const PracticeSessionScreen(),
          ),
        );
      }
    });

    // Check if we can start the quiz (questions are available)
    final canStartQuiz =
        practiceState.availableQuestions.isNotEmpty &&
        !practiceState.isLoading &&
        practiceState.error == null;

    return Scaffold(
      appBar: AppBar(title: const Text('Instructions'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Instructions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              '• Read each question carefully.\n'
              '• Select the best answer for each question.\n'
              '• You can navigate between questions.\n'
              '• Your progress and time will be tracked.\n'
              '• Good luck!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            if (practiceState.isLoading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Loading questions...', style: TextStyle(fontSize: 16)),
                ],
              ),
            if (practiceState.error != null)
              Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'Error: ${practiceState.error}',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      practiceViewModel.clearError();
                      practiceViewModel.loadQuestionsForTopic(topic);
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            if (!practiceState.isLoading && practiceState.error == null)
              Column(
                children: [
                  if (canStartQuiz)
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Questions loaded! Ready to start.'),
                      ],
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          canStartQuiz
                              ? () async {
                                // Start the practice session
                                await practiceViewModel.startPracticeSession(
                                  topic,
                                  mode,
                                );
                              }
                              : null,
                      child: const Text('Start Quiz'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
