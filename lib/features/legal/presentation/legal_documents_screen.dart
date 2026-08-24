import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/legal/legal_document_launcher.dart';

class LegalDocumentsScreen extends ConsumerWidget {
  const LegalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final launcher = ref.read(legalDocumentLauncherProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Legal and privacy')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Past Papers', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Review how the service works, how your information '
            'is handled, and how to request account deletion.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _LegalDocumentTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we collect, use and protect information.',
            onTap: () => _open(context, launcher.openPrivacyPolicy),
          ),
          const SizedBox(height: 12),
          _LegalDocumentTile(
            icon: Icons.description_outlined,
            title: 'Terms of Use',
            subtitle: 'Rules for using Past Papers.',
            onTap: () => _open(context, launcher.openTermsOfUse),
          ),
          const SizedBox(height: 12),
          _LegalDocumentTile(
            icon: Icons.delete_forever_outlined,
            title: 'Account deletion',
            subtitle: 'How to permanently delete an account and its data.',
            onTap: () => _open(context, launcher.openAccountDeletion),
          ),
        ],
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    Future<void> Function() operation,
  ) async {
    try {
      await operation();
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open this document.')),
      );
    }
  }
}

class _LegalDocumentTile extends StatelessWidget {
  const _LegalDocumentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.open_in_new),
      ),
    );
  }
}
