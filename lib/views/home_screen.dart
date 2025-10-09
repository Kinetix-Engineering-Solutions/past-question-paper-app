import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/utils/app_constants.dart';
import 'package:past_question_paper_v1/viewmodels/home_viewmodel.dart';
import 'package:past_question_paper_v1/views/test_configuration_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final user = homeState.user;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Determine the user's grade. Default to 12 if not set.
    final userGrade = homeState.user?.grade ?? 12;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        title: Text(
          'Hello, ${user?.email ?? 'Student'}!',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        // The grade selector in actions has been removed for a cleaner look.
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                "Let's get practicing",
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // --- Subject List Header ---
              Text(
                'Your Subjects for Grade $userGrade',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // --- Personalized Subject List ---
              Expanded(
                child: _SubjectList(
                  subjects: AppConstants.allSubjects.where((subject) {
                    return user?.selectedSubjects?.isEmpty ?? true
                        ? true
                        : user!.selectedSubjects!.contains(subject);
                  }).toList(),
                  selectedGrade: userGrade,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Helper Widget for Displaying Subjects ---
class _SubjectList extends StatelessWidget {
  final List<String> subjects;
  final int selectedGrade;

  const _SubjectList({required this.subjects, required this.selectedGrade});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    if (subjects.isEmpty) {
      return Center(
        child: Text(
          'No subjects selected for this grade.\nGo to your profile to add subjects.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide.none,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            title: Text(
              subject,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Paper 1 & 2 Available',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: colorScheme.primary,
              size: 16,
            ),
            onTap: () {
              // Navigate to the new Test Configuration Screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TestConfigurationScreen(
                    subject: subject,
                    grade: selectedGrade,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
