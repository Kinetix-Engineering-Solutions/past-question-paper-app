import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/account_type.dart';
import '../providers/auth_providers.dart';

class AccountDeclarationScreen extends ConsumerStatefulWidget {
  const AccountDeclarationScreen({super.key});

  @override
  ConsumerState<AccountDeclarationScreen> createState() =>
      _AccountDeclarationScreenState();
}

class _AccountDeclarationScreenState
    extends ConsumerState<AccountDeclarationScreen> {
  AccountType? _accountType;
  bool _accepted = false;
  String? _validationMessage;

  @override
  Widget build(BuildContext context) {
    final action = ref.watch(authActionControllerProvider);

    final actionError = action.hasError
        ? 'Unable to save your account declaration.'
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Account setup')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(Icons.verified_user_outlined, size: 56),
            const SizedBox(height: 20),
            Text(
              'Who manages this account?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'We need this information once before enabling '
              'account features. Guest study remains available.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            _AccountTypeOption(
              title: 'I am 18 or older',
              description: 'I am creating and managing my own learner account.',
              selected: _accountType == AccountType.adultLearner,
              onTap: () => _select(AccountType.adultLearner),
            ),
            const SizedBox(height: 12),
            _AccountTypeOption(
              title: 'Parent or guardian',
              description:
                  'I am creating and managing this account for '
                  'a learner under 18.',
              selected: _accountType == AccountType.guardianManagedLearner,
              onTap: () => _select(AccountType.guardianManagedLearner),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _accepted,
              onChanged: _accountType == null
                  ? null
                  : (value) {
                      setState(() {
                        _accepted = value ?? false;
                        _validationMessage = null;
                      });
                    },
              title: Text(switch (_accountType) {
                AccountType.adultLearner =>
                  'I confirm that I am 18 or older and that '
                      'this email belongs to me.',
                AccountType.guardianManagedLearner =>
                  'I confirm that I am the learner’s parent or '
                      'legal guardian, that this is my email '
                      'address, and that I consent to creating '
                      'and managing this learner account.',
                null => 'Select an account type before accepting.',
              }),
            ),
            if (_validationMessage != null || actionError != null) ...[
              const SizedBox(height: 8),
              Text(
                _validationMessage ?? actionError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: action.isLoading ? null : _submit,
              child: action.isLoading
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Continue'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: action.isLoading
                  ? null
                  : () => ref
                        .read(authActionControllerProvider.notifier)
                        .signOut(),
              child: const Text('Sign out and continue as guest'),
            ),
          ],
        ),
      ),
    );
  }

  void _select(AccountType accountType) {
    setState(() {
      _accountType = accountType;
      _accepted = false;
      _validationMessage = null;
    });
  }

  Future<void> _submit() async {
    final accountType = _accountType;

    if (accountType == null) {
      setState(() {
        _validationMessage = 'Select who manages this account.';
      });
      return;
    }

    if (!_accepted) {
      setState(() {
        _validationMessage = 'Accept the account declaration to continue.';
      });
      return;
    }

    await ref
        .read(authActionControllerProvider.notifier)
        .recordAccountDeclaration(
          accountType: accountType,
          declarationAccepted: true,
        );
  }
}

class _AccountTypeOption extends StatelessWidget {
  const _AccountTypeOption({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foregroundColor = selected ? colors.onPrimary : colors.onSurface;

    return Card(
      margin: EdgeInsets.zero,
      color: selected ? colors.primary : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? colors.primary : colors.outline,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? colors.onPrimary : colors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: foregroundColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: foregroundColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
