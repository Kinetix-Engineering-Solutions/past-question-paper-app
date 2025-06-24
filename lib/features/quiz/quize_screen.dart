import 'package:flutter/material.dart';
import '../../../core/models/quiz_question_model.dart';

class QuizScreen extends StatelessWidget {
  QuizScreen({super.key});

  final List<QuizQuestion> questions = [
    QuizQuestion(
      question: 'Which part of the human cell contains DNA?',
      options: ['Cytoplasm', 'Nucleus', 'Cell Membrane', 'Ribosome'],
      answer: 'Nucleus',
    ),
    QuizQuestion(
      question: 'What process do plants use to make their own food?',
      options: ['Respiration', 'Digestion', 'Photosynthesis', 'Fermentation'],
      answer: 'Photosynthesis',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q.question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...q.options.map((option) {
                    return RadioListTile(
                      title: Text(option),
                      value: option,
                      groupValue: null,
                      onChanged: (value) {},
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('End Quiz?'),
                content: const Text('Are you sure you want to end this session?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Submit')),
                ],
              ),
            );
          },
          child: const Text('Submit Quiz'),
        ),
      ),
    );
  }
}
