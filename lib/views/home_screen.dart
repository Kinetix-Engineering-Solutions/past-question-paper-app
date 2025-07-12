import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/viewmodels/auth_viewmodel.dart';
import 'package:past_question_paper_stem/services/navigation_service.dart';
import 'package:past_question_paper_stem/utils/loading_state.dart';
import 'package:past_question_paper_stem/widgets/user_profile_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Question Papers'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed:
                isLoading ? null : () => _showSignOutDialog(context, ref),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Signing out...'),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.school, size: 100, color: Colors.blue),
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome to Past Question Papers',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your study companion for STEM subjects',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),

                    // User Profile Card
                    const UserProfileCard(),

                    const SizedBox(height: 30),

                    // Sign Out Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            isLoading
                                ? null
                                : () => _showSignOutDialog(context, ref),
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

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    NavigationService.showCustomDialog(
      child: AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => NavigationService.navigateBack(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              NavigationService.navigateBack();
              await _signOut(ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(WidgetRef ref) async {
    await ref
        .read(authViewModelProvider.notifier)
        .signOutUserInUI(context: NavigationService.context!);
  }
}
