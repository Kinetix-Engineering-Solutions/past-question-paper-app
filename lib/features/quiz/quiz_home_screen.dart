import 'package:flutter/material.dart';
import 'package:liver_port/liver_port.dart';
import '../../../core/widgets/subject_button.dart';

class QuizHomeScreen extends StatelessWidget {
  const QuizHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Liver.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Subject')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SubjectButton(title: 'Life Sciences', onPressed: () => store.set('currentScreen', 'quizType')),
          SubjectButton(title: 'Physical Science', onPressed: () => store.set('currentScreen', 'quizType')),
          SubjectButton(title: 'Mathematics', onPressed: () => store.set('currentScreen', 'quizType')),
          SubjectButton(title: 'Economics', onPressed: () => store.set('currentScreen', 'quizType')),
          SubjectButton(title: 'Business Studies', onPressed: () => store.set('currentScreen', 'quizType')),
          SubjectButton(title: 'History', onPressed: () => store.set('currentScreen', 'quizType')),
        ],
      ),
    );
  }
}