import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/utils/app_constants.dart';
import 'package:past_question_paper_v1/viewmodels/home_viewmodel.dart';
import 'package:past_question_paper_v1/widgets/subject_list_view.dart';

/// Quiz Screen - Subject Selection for Practice Sessions
///
/// This screen allows users to select a subject to start a practice quiz.
/// Displays available subjects in a traditional list.
class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        title: Text(
          'PQP Quiz',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [const SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Text(
                'Select a Subject',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a subject to start practicing',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.ink.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Subject Selection Section
              const _SubjectListSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectListSection extends ConsumerWidget {
  const _SubjectListSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final selectedGrade = homeState.selectedGrade;

    final subjectColors = [
      AppColors.brandCyan,
      AppColors.brandMagenta,
      AppColors.brandLavender,
      AppColors.brandTeal,
      AppColors.accent,
    ];

    final subjectOptions = AppConstants.subjects.asMap().entries.map((entry) {
      final index = entry.key;
      final subject = entry.value;
      final isAvailable = AppConstants.availableSubjects.contains(subject);

      return SubjectOption(
        name: subject,
        color: subjectColors[index % subjectColors.length],
        isAvailable: isAvailable,
        subtitle: isAvailable
            ? 'Paper 1 & 2 Available'
            : 'Questions being prepared',
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subjects',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 16),
        SubjectListView(
          subjects: subjectOptions,
          onSubjectSelected: (subject, index) {
            Navigator.pushNamed(
              context,
              '/test-configuration',
              arguments: {'subject': subject.name, 'grade': selectedGrade},
            );
          },
        ),
      ],
    );
  }
}
