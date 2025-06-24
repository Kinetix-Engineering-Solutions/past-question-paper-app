import 'package:flutter/material.dart';
import 'package:liver_port/liver_port.dart';

class QuizTypeScreen extends StatelessWidget {
  const QuizTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Liver.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Type')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _button(context, store, 'Multiple Choice'),
          _button(context, store, 'Short Answer'),
          _button(context, store, 'Long Answer / Essay'),
          _button(context, store, 'Drag and Drop'),
          _button(context, store, 'Match the Following'),
          _button(context, store, 'True or False'),
        ],
      ),
    );
  }

  Widget _button(BuildContext context, Store store, String title) {
    return ElevatedButton(
      onPressed: () => store.set('currentScreen', 'quiz'),
      child: Text(title),
    );
  }
}
