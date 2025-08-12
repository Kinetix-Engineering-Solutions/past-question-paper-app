import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/question.dart';
import 'package:past_question_paper_stem/model/drag_and_drop%20models/drag_and_drop_question.dart';
import 'package:past_question_paper_stem/viewmodels/practice_viewmodel.dart';
import 'package:past_question_paper_stem/widgets/drag-and-drop%20widgets/drag_n_drop_widget.dart';

class QuestionScreenTest extends ConsumerStatefulWidget {
  final String questionId;
  final List<String>?
  questionIds; // Optional list of question IDs for navigation

  const QuestionScreenTest({
    super.key,
    required this.questionId,
    this.questionIds,
  });

  @override
  ConsumerState<QuestionScreenTest> createState() => _QuestionScreenTestState();
}

class _QuestionScreenTestState extends ConsumerState<QuestionScreenTest> {
  late String currentQuestionId;
  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    currentQuestionId = widget.questionId;

    // Find the current question index if questionIds list is provided
    if (widget.questionIds != null) {
      currentQuestionIndex = widget.questionIds!.indexOf(widget.questionId);
      if (currentQuestionIndex == -1) currentQuestionIndex = 0;
    }
  }

  void _goToNextQuestion() {
    final practiceNotifier = ref.read(practiceViewModelProvider.notifier);

    if (widget.questionIds != null &&
        currentQuestionIndex < widget.questionIds!.length - 1) {
      setState(() {
        currentQuestionIndex++;
        currentQuestionId = widget.questionIds![currentQuestionIndex];
      });
      // Move to next question in practice session
      practiceNotifier.nextQuestion();
    } else {
      // If it's the last question, complete the practice session
      practiceNotifier.finishSession();
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Quiz Complete!'),
            content: Text('You have completed all questions. Great job!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                child: Text('Finish'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final practiceState = ref.watch(practiceViewModelProvider);
    final currentQuestion = practiceState.currentQuestion;

    return Scaffold(
      body:
          practiceState.isLoading
              ? Center(child: CircularProgressIndicator())
              : currentQuestion == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('No question available'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Go Back'),
                    ),
                  ],
                ),
              )
              : _buildQuestionContent(currentQuestion),
    );
  }

  Widget _buildQuestionContent(Question question) {
    final practiceState = ref.watch(practiceViewModelProvider);
    final isLastQuestion = !practiceState.currentSession!.hasNextQuestion;

    if (question.isDragAndDrop && question.hasDragDropData) {
      // Convert to DragDropQuestion for the widget
      final dragDropQuestion = DragDropQuestion(
        questionText: question.questionText,
        dragItems: question.dragItems!,
        dropTargets: question.dragTargets!,
      );

      return DragDropQuestionWidget(
        question: dragDropQuestion,
        onNextQuestion: _goToNextQuestion,
        isLastQuestion: isLastQuestion,
      );
    } else {
      // Handle other question types (multiple choice, true/false, etc.)
      return _buildOtherQuestionTypes(question, isLastQuestion);
    }
  }

  Widget _buildOtherQuestionTypes(Question question, bool isLastQuestion) {
    // For now, show a placeholder for non-drag-drop questions
    // You can implement other question type widgets here
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Question Type: ${question.questionType}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          Text(
            question.questionText,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Text(
            'Other question types coming soon!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: _goToNextQuestion,
            child: Text(isLastQuestion ? 'Finish' : 'Next Question'),
          ),
        ],
      ),
    );
  }
}
