import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:past_question_paper_v1/core/models/quiz_type.dart';
import 'quiz_type_selector.dart';

class QuizHomeScreen extends ConsumerWidget {
  final String subjectId;
  final String subjectName;
  final String gradeId;
  final String gradeName;

  const QuizHomeScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.gradeId,
    required this.gradeName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$subjectName Quiz - $gradeName'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: QuizTypeSelector(
        subjectId: subjectId,
        onSelect: (quizType, selectedSubjectId) {
          // Navigate to quiz flow using GoRouter
          context.pushNamed(
            'quizFlow',
            queryParameters: {
              'subjectId': selectedSubjectId,
              'subjectName': subjectName,
              'gradeId': gradeId,
              'gradeName': gradeName,
              'quizType': quizType.toString().split('.').last,
            },
          );
        },
      ),
    );
  }
}