import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/utils/app_theme.dart';
import 'package:past_question_paper_stem/viewmodels/home_viewmodel.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeViewModel = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.charcoal),
            onPressed: () => homeViewModel.showSignOutDialog(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body:
          homeState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Actions
                    Text(
                      'Profile Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.inkBlack,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.edit,
                              color: AppColors.charcoal,
                            ),
                            title: const Text('Edit Profile'),
                            subtitle: Text(
                              'Update your information',
                              style: TextStyle(color: AppColors.graphite),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.charcoal,
                            ),
                            onTap: () => homeViewModel.navigateToProfileSetup(),
                          ),
                          const Divider(height: 1),
                          if (homeViewModel.userGrade != null)
                            ListTile(
                              leading: Icon(
                                Icons.grade,
                                color: AppColors.charcoal,
                              ),
                              title: Text(
                                'Grade ${homeViewModel.userGrade!.level}',
                              ),
                              subtitle: Text(
                                homeViewModel.userGrade!.name,
                                style: TextStyle(color: AppColors.graphite),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.charcoal,
                              ),
                              onTap:
                                  () => homeViewModel.navigateToProfileSetup(),
                            ),
                          if (homeViewModel.userGrade != null)
                            const Divider(height: 1),
                          ListTile(
                            leading: Icon(
                              Icons.book,
                              color: AppColors.charcoal,
                            ),
                            title: const Text('My Subjects'),
                            subtitle: Text(
                              '${homeViewModel.userSubjects.length} subjects selected',
                              style: TextStyle(color: AppColors.graphite),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.charcoal,
                            ),
                            onTap: () => homeViewModel.navigateToSubjects(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Sign Out Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            () => homeViewModel.showSignOutDialog(context),
                        icon: Icon(Icons.logout, color: AppColors.paperWhite),
                        label: Text(
                          'Sign Out',
                          style: TextStyle(color: AppColors.paperWhite),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.charcoal,
                          foregroundColor: AppColors.paperWhite,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
