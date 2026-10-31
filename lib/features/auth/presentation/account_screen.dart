import '../../../shared/widgets/appearance_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../bookmarks/presentation/saved_questions_screen.dart';
import '../../comments/presentation/blocked_learners_screen.dart';
import '../../comments/presentation/community_guidelines_screen.dart';
import '../../legal/presentation/legal_documents_screen.dart';
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
    final displayName = learnerProfile?.displayName?.trim();

    return Scaffold(
      appBar: AppBar(title: Text('Account')),
      body: ListView(
        padding: EdgeInsets.all(24),
        children: [
          const Card(child: AppearanceSetting()),
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 38,
            backgroundColor: AppPalette.of(context).primary,
            child: Icon(
              Icons.person,
              size: 40,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          SizedBox(height: 16),
          if (profile.isLoading)
            Center(
              child: SizedBox(
                width: 120,
                child: LinearProgressIndicator(minHeight: 3),
              ),
            )
          else
            Text(
              displayName == null || displayName.isEmpty
                  ? 'Learner'
                  : displayName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          SizedBox(height: 4),
          if (learnerProfile?.grade != null)
            Text(
              'Grade ${learnerProfile!.grade}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          SizedBox(height: 4),
          Text(
            user.email ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Your bookmarks and study progress '
            'will appear here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: 32),
          Card(
            child: ListTile(
              leading: Icon(Icons.manage_accounts_outlined),
              title: Text('Edit profile'),
              subtitle: Text('Update your display name and grade.'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ProfileScreen(user: user),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.insights_outlined),
              title: Text('Study progress'),
              subtitle: Text('See your progress across topics.'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ProgressScreen(user: user),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.bookmark),
              title: Text('Saved questions'),
              subtitle: Text('Review questions you bookmarked.'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SavedQuestionsScreen(user: user),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.block),
              title: Text('Blocked learners'),
              subtitle: Text('Review learners whose comments you have hidden.'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BlockedLearnersScreen(),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.policy_outlined),
              title: Text('Community Guidelines'),
              subtitle: Text('Review the rules for question discussions.'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CommunityGuidelinesScreen(userId: user.id),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.gavel_outlined),
              title: Text('Legal and privacy'),
              subtitle: Text(
                'Privacy Policy, Terms of Use and account deletion.',
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LegalDocumentsScreen(),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.replay_outlined),
              title: Text('Needs review'),
              subtitle: Text('Practise questions you have not understood yet.'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => NeedsReviewScreen(user: user),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: action.isLoading ? null : () => _signOut(context, ref),
            icon: Icon(Icons.logout),
            label: Text(action.isLoading ? 'Please wait...' : 'Sign out'),
          ),
          SizedBox(height: 40),
          Divider(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.35),
          ),
          SizedBox(height: 16),
          Text(
            'Danger zone',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Deleting your account permanently removes your profile, '
            'bookmarks, progress, comments and other account data. '
            'This action cannot be undone.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            onPressed: action.isLoading
                ? null
                : () => _confirmAccountDeletion(context, ref),
            icon: Icon(Icons.delete_forever_outlined),
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
      builder: (_) => _DeleteAccountDialog(),
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
        SnackBar(
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
      title: Text('Delete your account?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This permanently removes your learner profile, '
            'saved questions, study progress, comments and '
            'other account data.',
          ),
          SizedBox(height: 16),
          Text(
            'Type DELETE to confirm:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _confirmationController,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
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
          child: Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: canDelete ? () => Navigator.of(context).pop(true) : null,
          child: Text('Delete permanently'),
        ),
      ],
    );
  }
}
