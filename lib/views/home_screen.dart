import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/utils/app_theme.dart';
import 'package:past_question_paper_stem/viewmodels/home_viewmodel.dart';
import 'package:past_question_paper_stem/model/subject.dart';
import 'package:past_question_paper_stem/views/subject_topics_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeViewModel = ref.read(homeViewModelProvider.notifier);

    // Listen for errors
    ref.listen(homeViewModelProvider, (previous, current) {
      if (current.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(current.error!),
            backgroundColor: AppColors.charcoal,
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () => homeViewModel.clearError(),
            ),
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child:
            homeState.isLoading || homeState.isSigningOut
                ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            color: AppColors.charcoal,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : RefreshIndicator(
                  onRefresh: () => homeViewModel.refresh(),
                  child: LayoutBuilder(
                    builder:
                        (context, constraints) => SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                24,
                                20,
                                16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Welcome Section
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.charcoal.withOpacity(
                                          0.3,
                                        ),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Welcome back,',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.charcoal
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          homeViewModel.userDisplayName,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.charcoal,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Ready to practice your STEM subjects?',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.charcoal
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // My Subjects Section
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'My Subjects',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.charcoal,
                                          shadows: [
                                            Shadow(
                                              color: AppColors.chalkWhite
                                                  .withOpacity(0.3),
                                              blurRadius: 2,
                                              offset: const Offset(1, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed:
                                            homeViewModel.navigateToSubjects,
                                        style: TextButton.styleFrom(
                                          backgroundColor: AppColors.charcoal
                                              .withOpacity(0.1),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'View All',
                                          style: TextStyle(
                                            color: AppColors.charcoal,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Subjects List
                                  if (homeViewModel
                                      .userSubjects
                                      .isNotEmpty) ...[
                                    ...homeViewModel.userSubjects
                                        .map(
                                          (subject) => _buildSubjectCard(
                                            context,
                                            subject,
                                          ),
                                        )
                                        .toList(),
                                  ] else ...[
                                    // No subjects selected yet
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: ChalkboardGradients.deep,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.chalkWhite
                                              .withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.chalkboard
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.book_outlined,
                                            size: 48,
                                            color: AppColors.chalkWhite,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'No subjects selected yet',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.chalkWhite,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Add subjects to start practicing',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.chalkWhite
                                                  .withOpacity(0.8),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton.icon(
                                            onPressed:
                                                homeViewModel
                                                    .navigateToSubjects,
                                            icon: Icon(
                                              Icons.add,
                                              color: AppColors.chalkboard,
                                            ),
                                            label: Text(
                                              'Add Subjects',
                                              style: TextStyle(
                                                color: AppColors.chalkboard,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.chalkWhite,
                                              foregroundColor:
                                                  AppColors.chalkboard,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                  ),
                ),
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, Subject subject) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: ChalkboardGradients.vertical,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.chalkboard.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.chalkWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.chalkWhite.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Icon(Icons.book, color: AppColors.chalkWhite, size: 24),
          ),
          title: Text(
            subject.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.chalkWhite,
            ),
          ),
          subtitle: Text(
            subject.description,
            style: TextStyle(
              color: AppColors.chalkWhite.withOpacity(0.8),
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.chalkWhite,
          ),
          onTap: () {
            print('🏠 Tapping subject: ${subject.name} (ID: "${subject.id}")');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubjectTopicsScreen(subject: subject),
              ),
            );
          },
        ),
      ),
    );
  }
}
