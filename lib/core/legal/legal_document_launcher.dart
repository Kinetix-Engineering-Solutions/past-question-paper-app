import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final legalDocumentLauncherProvider = Provider<LegalDocumentLauncher>((ref) {
  return const LegalDocumentLauncher();
});

final class LegalDocumentLauncher {
  const LegalDocumentLauncher();

  static final Uri privacyPolicyUri = Uri.parse(
    'https://kinetix-engineering-solutions.github.io/'
    'past-question-paper-app/privacy/',
  );

  static final Uri termsOfUseUri = Uri.parse(
    'https://kinetix-engineering-solutions.github.io/'
    'past-question-paper-app/terms/',
  );

  static final Uri accountDeletionUri = Uri.parse(
    'https://kinetix-engineering-solutions.github.io/'
    'past-question-paper-app/account-deletion/',
  );

  Future<void> openPrivacyPolicy() async {
    final opened = await launchUrl(
      privacyPolicyUri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      throw StateError('Unable to open the Privacy Policy.');
    }
  }

  Future<void> openTermsOfUse() async {
    final opened = await launchUrl(
      termsOfUseUri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      throw StateError('Unable to open the Terms of Use.');
    }
  }

  Future<void> openAccountDeletion() async {
    final opened = await launchUrl(
      accountDeletionUri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      throw StateError('Unable to open account deletion information.');
    }
  }
}
