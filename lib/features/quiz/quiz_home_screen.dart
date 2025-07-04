import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/core/models/quiz_type.dart';
import 'package:go_router/go_router.dart';
import '../quiz/quiz_type_selector.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<String> subjects = const [
    'Biology',
    'Mathematics',
    'Physics',
    'Chemistry',
    'History',
    'Geography',
    'English',
    'Computer Science',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Subject')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(subject),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  isScrollControlled: true,
                  builder: (_) => SizedBox(
                    height: 450,
                    child: QuizTypeSelector(
                      subjectId: subject,
                      onSelect: (type, subjectId) {
                        Navigator.pop(context);
                        Future.microtask(() {
                          context.goNamed(
                            'quizSession',
                            queryParameters: {
                              'subjectId': subjectId,
                              'type': type.name,
                            },
                          );
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
