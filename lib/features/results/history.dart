import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class QuizHistoryPage extends ConsumerWidget {
  const QuizHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizHistory = [
      {'subject': 'Mathematics', 'score': 75, 'date': 'Apr 18'},
      {'subject': 'Life Sciences', 'score': 92, 'date': 'Apr 18'},
      {'subject': 'Geography', 'score': 60, 'date': 'Apr 20'},
    ];

    final avgScore = 78;
    final quizzesTaken = 12;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz History", style: TextStyle(fontSize: 30)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              // User Info
              const CircleAvatar(
                radius: 30,
                child: Text("JD", style: TextStyle(fontSize: 30)),
              ),
              const SizedBox(height: 12),
              const Text(
                "John Doe",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const Text("Grade 11", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 25),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        "$avgScore%",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("Avg. Score"),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "$quizzesTaken",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("Quizzes Taken"),
                    ],
                  ),
                  Column(
                    children: const [
                      Text(
                        "Mathematics",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Best Subject"),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),
              Center(
                child: const Text(
                  "Recent Quizzes",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: quizHistory.length,
                  itemBuilder: (context, index) {
                    final quiz = quizHistory[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
                      title: Text(quiz['subject'] as String),
                      subtitle: Text(quiz['date'] as String),
                      trailing: Text(
                        "${quiz['score']}%",
                        style: TextStyle(
                          color: (quiz['score'] as int) >= 50
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
