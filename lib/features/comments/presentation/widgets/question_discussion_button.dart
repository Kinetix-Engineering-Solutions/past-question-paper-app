import 'package:flutter/material.dart';
import '../../../questions/data/models/question.dart';
import '../question_comments_screen.dart';

class QuestionDiscussionButton extends StatelessWidget {
  const QuestionDiscussionButton({required this.question, super.key});

  final Question question;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Question discussion',
      icon: const Icon(Icons.forum_outlined),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => QuestionCommentsScreen(question: question),
          ),
        );
      },
    );
  }
}
