import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../bookmarks/presentation/saved_questions_screen.dart';
import '../../progress/presentation/needs_review_screen.dart';
import '../domain/app_user.dart';
import '../providers/auth_providers.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({required this.user, super.key});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final action = ref.watch(authActionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const CircleAvatar(
            radius: 38,
            backgroundColor: AppColors.brandCyan,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            user.email ?? 'Signed-in learner',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Your bookmarks and study progress '
            'will appear here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Saved questions'),
              subtitle: const Text('Review questions you bookmarked.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SavedQuestionsScreen(user: user),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.replay_outlined),
              title: const Text('Needs review'),
              subtitle: const Text(
                'Practise questions you have not understood yet.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => NeedsReviewScreen(user: user),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: action.isLoading ? null : () => _signOut(context, ref),
            icon: const Icon(Icons.logout),
            label: Text(action.isLoading ? 'Signing out...' : 'Sign out'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authActionControllerProvider.notifier).signOut();

    if (!context.mounted) {
      return;
    }

    final state = ref.read(authActionControllerProvider);

    if (!state.hasError) {
      Navigator.of(context).pop();
    }
  }
}
