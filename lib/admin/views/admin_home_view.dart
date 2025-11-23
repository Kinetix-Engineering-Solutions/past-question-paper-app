import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/views/question_create_view.dart';
import 'package:past_question_paper_v1/admin/views/parent_question_create_view.dart';
import 'package:past_question_paper_v1/admin/views/question_list_view.dart';
import 'package:past_question_paper_v1/admin/views/parent_child_browser_view.dart';
import 'package:past_question_paper_v1/admin/views/paper_upload_view.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';

/// Admin Home View - Simple landing page with quick actions
class AdminHomeView extends ConsumerWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PQP Admin Portal'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header
              Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: AppColors.accent,
              ),
              const SizedBox(height: 24),
              Text(
                'Question Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Quick data entry for past question papers',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.neutralMid),
              ),
              const SizedBox(height: 48),

              // Quick Actions
              _buildActionCard(
                context,
                title: 'Create Standalone Question',
                subtitle: 'Add a single question (MCQ, Short Answer, etc.)',
                icon: Icons.add_circle_outline,
                color: AppColors.accent,
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const QuestionCreateView(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                context,
                title: 'Create Parent Question',
                subtitle: 'Create context for multi-part questions',
                icon: Icons.account_tree,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const ParentQuestionCreateView(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                context,
                title: 'View Questions',
                subtitle: 'Browse and edit existing questions',
                icon: Icons.list_alt,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const QuestionListView(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                context,
                title: 'Parent-Child Browser',
                subtitle: 'View and manage parent-child question sets',
                icon: Icons.account_tree,
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const ParentChildBrowserView(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                context,
                title: 'Upload Past Papers',
                subtitle: 'Upload PDF files for past question papers',
                icon: Icons.upload_file,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const PaperUploadView(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: AppColors.neutralMid),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: AppColors.neutralMid),
            ],
          ),
        ),
      ),
    );
  }
}
