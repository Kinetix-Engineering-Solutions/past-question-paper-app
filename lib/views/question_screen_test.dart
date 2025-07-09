import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:past_question_paper_stem/model/drag_and_drop%20models/drag_and_drop_question.dart';
import 'package:past_question_paper_stem/widgets/drag_n_drop_widget.dart';

class QuestionScreenTest extends StatefulWidget {
  final String questionId;
  final List<String>?
  questionIds; // Optional list of question IDs for navigation

  const QuestionScreenTest({
    super.key,
    required this.questionId,
    this.questionIds,
  });

  @override
  State<QuestionScreenTest> createState() => _QuestionScreenTestState();
}

class _QuestionScreenTestState extends State<QuestionScreenTest> {
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
    if (widget.questionIds != null &&
        currentQuestionIndex < widget.questionIds!.length - 1) {
      setState(() {
        currentQuestionIndex++;
        currentQuestionId = widget.questionIds![currentQuestionIndex];
      });
    } else {
      // If it's the last question or no question list, navigate back or show completion
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
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('questions')
                .doc(currentQuestionId)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Question not found'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final question = DragDropQuestion.fromFirestore(data);
          final isLastQuestion =
              widget.questionIds == null ||
              currentQuestionIndex >= widget.questionIds!.length - 1;

          return DragDropQuestionWidget(
            question: question,
            onNextQuestion: _goToNextQuestion,
            isLastQuestion: isLastQuestion,
          );
        },
      ),
    );
  }
}
