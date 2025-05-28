import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/core/providers/question_providers.dart';
import 'package:past_question_paper_stem/presentation/views/topics_screen.dart';

/// Screen showing available exam types for a selected subject
class ExamTypesScreen extends ConsumerWidget {
  final String subjectId;

  const ExamTypesScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the Riverpod family provider to get exam types for the selected subject
    final examTypesAsync = ref.watch(examTypesProvider(subjectId));

    return Scaffold(
      appBar: AppBar(
        title: Text('$subjectId - Exam Types'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: examTypesAsync.when(
        data: (examTypes) {
          if (examTypes.isEmpty) {
            return const Center(
              child: Text(
                'No exam types available for this subject.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: examTypes.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    examTypes[index],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TopicsScreen(
                              subjectId: subjectId,
                              examTypeId: examTypes[index],
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load exam types: $error',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => ref.refresh(examTypesProvider(subjectId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
