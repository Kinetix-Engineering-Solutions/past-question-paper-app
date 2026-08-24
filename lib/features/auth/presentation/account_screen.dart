import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../bookmarks/presentation/saved_questions_screen.dart';
import '../../comments/presentation/blocked_learners_screen.dart';
import '../../comments/presentation/community_guidelines_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../profile/providers/profile_providers.dart';
import '../../progress/presentation/needs_review_screen.dart';
import '../../progress/presentation/progress_screen.dart';
import '../domain/app_user.dart';
import '../providers/auth_providers.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({required this.user, super.key});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final action = ref.watch(authActionControllerProvider);
    final profile = ref.watch(profileControllerProvider(user.id));
    final learnerProfile = profile.asData?.value;

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
            learnerProfile?.displayName ?? user.email ?? 'Signed-in learner',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          if (learnerProfile?.grade != null)
            Text(
              'Grade ${learnerProfile!.grade}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          const SizedBox(height: 4),
          Text(
            user.email ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
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
              leading: const Icon(Icons.manage_accounts_outlined),
              title: const Text('Edit profile'),
              subtitle: const Text('Update your display name and grade.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ProfileScreen(user: user),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.insights_outlined),
              title: const Text('Study progress'),
              subtitle: const Text('See your progress across topics.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ProgressScreen(user: user),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
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
              leading: const Icon(Icons.block),
              title: const Text('Blocked learners'),
              subtitle: const Text(
                'Review learners whose comments you have hidden.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const BlockedLearnersScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.policy_outlined),
              title: const Text('Community Guidelines'),
              subtitle: const Text(
                'Review the rules for question discussions.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CommunityGuidelinesScreen(userId: user.id),
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
            label: Text(action.isLoading ? 'Please wait...' : 'Sign out'),
          ),
          const SizedBox(height: 40),
          Divider(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          Text(
            'Danger zone',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Deleting your account permanently removes your profile, '
            'bookmarks, progress, comments and other account data. '
            'This action cannot be undone.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            onPressed: action.isLoading
                ? null
                : () => _confirmAccountDeletion(context, ref),
            icon: const Icon(Icons.delete_forever_outlined),
            label: Text(action.isLoading ? 'Please wait...' : 'Delete account'),
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

  Future<void> _confirmAccountDeletion(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _DeleteAccountDialog(),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final deleted = await ref
        .read(authActionControllerProvider.notifier)
        .deleteAccount(confirmation: 'DELETE');

    if (!context.mounted) {
      return;
    }

    if (!deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to delete your account. Please try again.'),
        ),
      );

      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _confirmationController = TextEditingController();

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = _confirmationController.text.trim() == 'DELETE';

    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: Theme.of(context).colorScheme.error,
        size: 40,
      ),
      title: const Text('Delete your account?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This permanently removes your learner profile, '
            'saved questions, study progress, comments and '
            'other account data.',
          ),
          const SizedBox(height: 16),
          const Text(
            'Type DELETE to confirm:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmationController,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Confirmation',
              hintText: 'DELETE',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: canDelete ? () => Navigator.of(context).pop(true) : null,
          child: const Text('Delete permanently'),
        ),
      ],
    );
  }
}
