import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../discovery/presentation/discovery_screen.dart';
import '../providers/auth_providers.dart';
import 'account_declaration_screen.dart';

class AccountDeclarationGate extends ConsumerWidget {
  const AccountDeclarationGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authentication = ref.watch(authStateProvider);

    return authentication.when(
      loading: () => const _LoadingScreen(),
      error: (_, _) => const DiscoveryScreen(),
      data: (user) {
        if (user == null) {
          return const DiscoveryScreen();
        }

        final declaration = ref.watch(accountDeclarationProvider);

        return declaration.when(
          loading: () => const _LoadingScreen(),
          error: (error, stackTrace) => _DeclarationError(
            onRetry: () {
              ref.invalidate(accountDeclarationProvider);
            },
          ),
          data: (value) {
            if (value == null) {
              return const AccountDeclarationScreen();
            }

            return const DiscoveryScreen();
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _DeclarationError extends StatelessWidget {
  const _DeclarationError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Unable to check your account setup.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
