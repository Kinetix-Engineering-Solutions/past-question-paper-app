import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/utils/app_colors.dart';
import 'package:past_question_paper_stem/viewmodels/home_viewmodel.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeViewModel = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: AppColors.ink)),
        centerTitle: true,
        backgroundColor: AppColors.neutralCard,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.ink),
            onPressed: () => homeViewModel.showSignOutDialog(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body:
          homeState.isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: AppColors.neutralCard,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.edit, color: AppColors.accent),
                            title: Text(
                              'Edit Profile',
                              style: TextStyle(color: AppColors.ink),
                            ),
                            subtitle: Text(
                              'Update your information',
                              style: TextStyle(color: AppColors.neutralMid),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.neutralMid,
                              size: 16,
                            ),
                            onTap: () => homeViewModel.navigateToProfileSetup(),
                          ),
                          Divider(height: 1, color: AppColors.neutralBorder),
                          if (homeViewModel.userGrade != null) ...[
                            ListTile(
                              leading: Icon(
                                Icons.grade,
                                color: AppColors.accent,
                              ),
                              title: Text(
                                'Grade ${homeViewModel.userGrade!.level}',
                                style: TextStyle(color: AppColors.ink),
                              ),
                              subtitle: Text(
                                homeViewModel.userGrade!.name,
                                style: TextStyle(color: AppColors.neutralMid),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.neutralMid,
                                size: 16,
                              ),
                              onTap:
                                  () => homeViewModel.navigateToProfileSetup(),
                            ),
                            Divider(height: 1, color: AppColors.neutralBorder),
                          ],
                          ListTile(
                            leading: Icon(Icons.book, color: AppColors.accent),
                            title: Text(
                              'My Subjects',
                              style: TextStyle(color: AppColors.ink),
                            ),
                            subtitle: Text(
                              '${homeViewModel.userSubjects.length} subjects selected',
                              style: TextStyle(color: AppColors.neutralMid),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.neutralMid,
                              size: 16,
                            ),
                            onTap: () => homeViewModel.navigateToSubjects(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            () => homeViewModel.showSignOutDialog(context),
                        icon: Icon(Icons.logout, color: AppColors.neutralCard),
                        label: Text(
                          'Sign Out',
                          style: TextStyle(color: AppColors.neutralCard),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.ink,
                          foregroundColor: AppColors.neutralCard,
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
