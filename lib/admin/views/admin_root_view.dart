import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/providers/admin_auth_providers.dart';
import 'package:past_question_paper_v1/admin/views/admin_home_view.dart';
import 'package:past_question_paper_v1/admin/views/admin_login_view.dart';

/// Root view that decides whether to show the admin dashboard or the login
/// screen based on the current authentication state.
class AdminRootView extends ConsumerWidget {
  const AdminRootView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(adminAuthStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const AdminHomeView();
        }
        return const AdminLoginView();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Authentication error',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(error.toString(), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
