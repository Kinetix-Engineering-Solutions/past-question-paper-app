import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/viewmodels/home_viewmodel.dart';
import 'package:past_question_paper_stem/widgets/user_profile_card.dart';

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
            icon: const Icon(Icons.logout),
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
                    // User Profile Card
                    const UserProfileCard(),

                    const SizedBox(height: 30),

                    // Profile Actions
                    const Text(
                      'Profile Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit, color: Colors.blue),
                            title: const Text('Edit Profile'),
                            subtitle: const Text('Update your information'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => homeViewModel.navigateToProfileSetup(),
                          ),
                          const Divider(height: 1),
                          if (homeViewModel.userGrade != null)
                            ListTile(
                              leading: const Icon(
                                Icons.grade,
                                color: Colors.orange,
                              ),
                              title: Text(
                                'Grade ${homeViewModel.userGrade!.level}',
                              ),
                              subtitle: Text(homeViewModel.userGrade!.name),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap:
                                  () => homeViewModel.navigateToProfileSetup(),
                            ),
                          if (homeViewModel.userGrade != null)
                            const Divider(height: 1),
                          ListTile(
                            leading: const Icon(
                              Icons.book,
                              color: Colors.green,
                            ),
                            title: const Text('My Subjects'),
                            subtitle: Text(
                              '${homeViewModel.userSubjects.length} subjects selected',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
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
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
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
