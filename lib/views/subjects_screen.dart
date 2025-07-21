import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/subject.dart';
import 'package:past_question_paper_stem/viewmodels/home_viewmodel.dart';

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeViewModel = ref.read(homeViewModelProvider.notifier);
    final userSubjects = homeViewModel.userSubjects;

    return Scaffold(
      appBar: AppBar(title: const Text('My Subjects'), centerTitle: true),
      body: SafeArea(
        child:
            userSubjects.isEmpty
                ? _buildEmptyState()
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Subjects',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap a subject on the home screen to view its topics',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: ListView.builder(
                          itemCount: userSubjects.length,
                          itemBuilder: (context, index) {
                            final subject = userSubjects[index];
                            return _buildSubjectInfoCard(subject);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No Subjects Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Complete your profile on the home screen to see your subjects here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectInfoCard(Subject subject) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getSubjectColor(subject.name).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getSubjectColor(subject.name).withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  _getSubjectIcon(subject.name),
                  color: _getSubjectColor(subject.name),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Available on Home',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSubjectColor(String subjectName) {
    switch (subjectName.toLowerCase()) {
      case 'mathematics':
      case 'math':
        return Colors.blue;
      case 'physics':
        return Colors.purple;
      case 'chemistry':
        return Colors.green;
      case 'biology':
        return Colors.teal;
      case 'computer science':
      case 'programming':
        return Colors.orange;
      default:
        return Colors.indigo;
    }
  }

  IconData _getSubjectIcon(String subjectName) {
    switch (subjectName.toLowerCase()) {
      case 'mathematics':
      case 'math':
        return Icons.calculate;
      case 'physics':
        return Icons.science;
      case 'chemistry':
        return Icons.biotech;
      case 'biology':
        return Icons.local_florist;
      case 'computer science':
      case 'programming':
        return Icons.computer;
      default:
        return Icons.book;
    }
  }
}
