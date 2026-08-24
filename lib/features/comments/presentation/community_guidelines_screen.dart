import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/community_guidelines_providers.dart';

class CommunityGuidelinesScreen extends ConsumerWidget {
  const CommunityGuidelinesScreen({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = communityGuidelinesControllerProvider(userId);
    final status = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: const Text('Community Guidelines')),
      body: status.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: FilledButton.icon(
            onPressed: () {
              ref.read(provider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ),
        data: (guidelinesStatus) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  children: [
                    Text(
                      'Help keep Past Papers safe '
                      'and useful for learners.',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'By participating in question discussions, '
                      'you agree to follow these rules.',
                    ),
                    const SizedBox(height: 24),
                    const _Guideline(
                      icon: Icons.school_outlined,
                      title: 'Keep it educational',
                      description:
                          'Comments should relate to the question, '
                          'memo, study method or explanation.',
                    ),
                    const _Guideline(
                      icon: Icons.people_outline,
                      title: 'Treat others with respect',
                      description:
                          'Do not harass, threaten, bully or attack '
                          'other learners.',
                    ),
                    const _Guideline(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Protect personal information',
                      description:
                          'Do not share phone numbers, addresses, '
                          'passwords or other private information.',
                    ),
                    const _Guideline(
                      icon: Icons.link_outlined,
                      title: 'Share safe and relevant links',
                      description:
                          'YouTube and TikTok links must provide '
                          'helpful educational content. Do not post '
                          'scams, misleading links or unrelated ads.',
                    ),
                    const _Guideline(
                      icon: Icons.do_not_disturb_alt_outlined,
                      title: 'No spam or harmful content',
                      description:
                          'Do not repeatedly post the same content, '
                          'impersonate others or share inappropriate '
                          'material.',
                    ),
                    const _Guideline(
                      icon: Icons.flag_outlined,
                      title: 'Use reporting responsibly',
                      description:
                          'Report content that breaks these rules. '
                          'Do not misuse reports to target another '
                          'learner.',
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Comments may be removed when they break '
                          'these guidelines. Repeated or serious '
                          'violations may result in restricted '
                          'access to community features.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (guidelinesStatus.isAccepted)
                SafeArea(
                  minimum: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text('Community Guidelines accepted'),
                    ],
                  ),
                )
              else
                SafeArea(
                  minimum: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final accepted = await ref
                            .read(provider.notifier)
                            .accept();

                        if (!context.mounted || !accepted) {
                          return;
                        }

                        Navigator.of(context).pop(true);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('I agree to the Community Guidelines'),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Guideline extends StatelessWidget {
  const _Guideline({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
