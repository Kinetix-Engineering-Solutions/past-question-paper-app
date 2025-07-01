// pages/subject_selection_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/provider/grade_provider.dart';
import '../../core/provider/subject_provider.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/grade_selector.dart';
import '../../core/widgets/subject_card.dart';


class SubjectSelectionPage extends ConsumerWidget {
  const SubjectSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);
    final selectedSubjects = ref.watch(selectedSubjectsProvider);
    final selectedGrade = ref.watch(selectedGradeProvider);
    final selectedCount = selectedSubjects.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C5CE7).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.quiz,
                          color: Color(0xFF6C5CE7),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3436),
                              ),
                            ),
                            Text(
                              'Let\'s personalize your learning experience',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF636E72),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selectedCount > 0
                              ? const Color(0xFF6C5CE7).withOpacity(0.1)
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$selectedCount Selected',
                          style: TextStyle(
                            color: selectedCount > 0
                                ? const Color(0xFF6C5CE7)
                                : const Color(0xFF636E72),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Grade Selector (now outside the scrollable area)
            const GradeSelector(),

            // Subjects Section (now wrapped in SingleChildScrollView)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subjects Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Subjects',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        TextButton(
                          onPressed: selectedSubjects.isEmpty
                              ? null
                              : () => ref
                                  .read(selectedSubjectsProvider.notifier)
                                  .clearAll(),
                          child: const Text(
                            'Clear All',
                            style: TextStyle(
                              color: Color(0xFF6C5CE7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pick the subjects you want to practice',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF636E72),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Subjects List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjects[index];
                        final isSelected =
                            selectedSubjects.contains(subject.id);

                        return SubjectCard(
                          subject: subject,
                          isSelected: isSelected,
                          onTap: () => ref
                              .read(selectedSubjectsProvider.notifier)
                              .toggleSubject(subject.id),
                        );
                      },
                    ),

                    const SizedBox(height: 100), // Space for bottom buttons
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Select All',
                onPressed: () => ref
                    .read(selectedSubjectsProvider.notifier)
                    .selectAll(subjects.map((s) => s.id).toList()),
                isOutlined: true,
                icon: Icons.select_all,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                text: 'Continue',
                onPressed: (selectedCount > 0 && selectedGrade != null)
                    ? () => context.go('/dashboard')
                    : null,
                icon: Icons.arrow_forward,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
