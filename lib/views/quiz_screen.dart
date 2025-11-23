import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/utils/app_constants.dart';
import 'package:past_question_paper_v1/viewmodels/home_viewmodel.dart';
import 'package:past_question_paper_v1/viewmodels/view_mode_viewmodel.dart';
import 'package:past_question_paper_v1/widgets/subject_3d_carousel.dart';
import 'package:past_question_paper_v1/widgets/subject_list_view.dart';

/// Quiz Screen - Subject Selection for Practice Sessions
///
/// This screen allows users to select a subject to start a practice quiz.
/// Supports both 3D carousel and traditional list views.
class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(viewModeProvider);
    final isCarouselView = viewMode.homeViewMode == ViewMode.carousel3D;

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
        actions: [
          IconButton(
            icon: Icon(
              isCarouselView
                  ? Icons.view_list_rounded
                  : Icons.view_carousel_rounded,
              color: AppColors.ink,
            ),
            onPressed: () {
              ref.read(viewModeProvider.notifier).toggleHomeViewMode();
            },
            tooltip: isCarouselView
                ? 'Switch to List View'
                : 'Switch to Carousel View',
          ),
          const SizedBox(width: 8),
        ],
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: isCarouselView
                    ? const _SubjectCarouselSection(key: ValueKey('carousel'))
                    : const _SubjectListSection(key: ValueKey('list')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectCarouselSection extends ConsumerWidget {
  const _SubjectCarouselSection({super.key});

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
        Subject3DCarousel(
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

class _SubjectListSection extends ConsumerWidget {
  const _SubjectListSection({super.key});

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
