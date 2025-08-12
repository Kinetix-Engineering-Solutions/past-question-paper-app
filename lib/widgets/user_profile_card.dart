import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/viewmodels/auth_viewmodel.dart';
import 'package:past_question_paper_stem/utils/app_colors.dart';
import 'package:past_question_paper_stem/providers/profile_providers.dart';

class UserProfileCard extends ConsumerWidget {
  const UserProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final gradesAsync = ref.watch(availableGradesProvider);
    final subjectsAsync = ref.watch(availableSubjectsProvider);

    return authState.when(
      data: (user) {
        if (user?.profile == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No profile information available'),
            ),
          );
        }

        final profile = user!.profile!;

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        profile.displayName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (profile.schoolName != null)
                            Text(
                              profile.schoolName!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Grade Information
                gradesAsync.when(
                  loading:
                      () => Row(
                        children: const [
                          Icon(Icons.school, color: AppColors.accent),
                          SizedBox(width: 8),
                          Text('Loading grade...'),
                        ],
                      ),
                  error:
                      (error, stack) => Row(
                        children: const [
                          Icon(Icons.school, color: AppColors.accent),
                          SizedBox(width: 8),
                          Text('Grade: Error loading'),
                        ],
                      ),
                  data: (grades) {
                    final grade =
                        grades
                            .where((g) => g.id == profile.gradeId)
                            .firstOrNull;
                    return Row(
                      children: [
                        const Icon(Icons.school, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Text(
                          'Grade: ${grade?.name ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Subjects
                subjectsAsync.when(
                  loading:
                      () => const Row(
                        children: [
                          Icon(Icons.book, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Loading subjects...'),
                        ],
                      ),
                  error:
                      (error, stack) => Row(
                        children: [
                          Icon(Icons.book, color: Colors.green[600]),
                          const SizedBox(width: 8),
                          const Text('Subjects: Error loading'),
                        ],
                      ),
                  data: (subjects) {
                    final userSubjects =
                        subjects
                            .where((s) => profile.subjectIds.contains(s.id))
                            .toList();

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.book, color: Colors.green[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Subjects:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children:
                                    userSubjects.map((subject) {
                                      return Chip(
                                        label: Text(
                                          subject.name,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.1),
                                        side: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 1,
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Edit Profile Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to edit profile screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit profile feature coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading:
          () => const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      error:
          (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error loading profile: $error'),
            ),
          ),
    );
  }
}
