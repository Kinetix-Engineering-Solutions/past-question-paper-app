import 'package:flutter/material.dart';

import '../../auth/domain/app_user.dart';
import '../../comments/presentation/widgets/question_discussion_button.dart';
import '../../questions/data/models/question.dart';
import '../../questions/presentation/widgets/question_bookmark_button.dart';
import '../../questions/presentation/widgets/question_content_card.dart';

class SavedQuestionDetailScreen extends StatefulWidget {
  const SavedQuestionDetailScreen({
    required this.user,
    required this.question,
    super.key,
  });

  final AppUser user;
  final Question question;

  @override
  State<SavedQuestionDetailScreen> createState() =>
      _SavedQuestionDetailScreenState();
}

class _SavedQuestionDetailScreenState extends State<SavedQuestionDetailScreen> {
  bool _showMemo = false;

  @override
  Widget build(BuildContext context) {
    final question = widget.question;

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${question.questionNumber}'),
        actions: [
          QuestionDiscussionButton(question: question),
          QuestionBookmarkButton(user: widget.user, question: question),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${question.topicName} • '
                '${question.examYear} • '
                '${question.examSeason} • '
                'Paper ${question.paperNumber}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          Expanded(
            child: QuestionContentCard(question: question, showMemo: _showMemo),
          ),
          SafeArea(
            minimum: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _showMemo = !_showMemo;
                  });
                },
                icon: Icon(
                  _showMemo
                      ? Icons.description_outlined
                      : Icons.visibility_outlined,
                ),
                label: Text(_showMemo ? 'Show question' : 'Reveal memo'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
