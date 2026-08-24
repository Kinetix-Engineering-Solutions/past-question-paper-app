import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/legal/legal_document_launcher.dart';

class PrivacyPolicyButton extends ConsumerWidget {
  const PrivacyPolicyButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () => _open(context, ref),
      icon: const Icon(Icons.open_in_new, size: 18),
      label: const Text('Read Privacy Policy'),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(legalDocumentLauncherProvider).openPrivacyPolicy();
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the Privacy Policy.')),
      );
    }
  }
}
