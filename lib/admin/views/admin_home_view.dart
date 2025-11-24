import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/views/question_create_view.dart';
import 'package:past_question_paper_v1/admin/views/parent_question_create_view.dart';
import 'package:past_question_paper_v1/admin/views/question_list_view.dart';
import 'package:past_question_paper_v1/admin/views/parent_child_browser_view.dart';
import 'package:past_question_paper_v1/admin/views/paper_upload_view.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';

// Provider to track selected navigation index
final adminNavigationProvider = StateProvider<int>((ref) => 0);

/// Admin Home View with Sidebar Navigation
class AdminHomeView extends ConsumerWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(adminNavigationProvider);
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _AdminSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              ref.read(adminNavigationProvider.notifier).state = index;
            },
            isWideScreen: isWideScreen,
          ),

          // Main content area
          Expanded(child: _getContentForIndex(selectedIndex)),
        ],
      ),
    );
  }

  Widget _getContentForIndex(int index) {
    switch (index) {
      case 0:
        return const _AdminDashboard();
      case 1:
        return const QuestionCreateView();
      case 2:
        return const ParentQuestionCreateView();
      case 3:
        return const QuestionListView();
      case 4:
        return const ParentChildBrowserView();
      case 5:
        return const PaperUploadView();
      default:
        return const _AdminDashboard();
    }
  }
}

/// Sidebar Navigation
class _AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isWideScreen;

  const _AdminSidebar({
    required this.selectedIndex,
    required this.onItemSelected,
    required this.isWideScreen,
  });

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = isWideScreen ? 280.0 : 72.0;

    return Container(
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: AppColors.neutralBorder, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: AppColors.accent,
                  size: 32,
                ),
                if (isWideScreen) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'PQP Admin',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  index: 0,
                ),
                const SizedBox(height: 4),
                if (isWideScreen)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Text(
                      'QUESTIONS',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.neutralMid,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                _buildNavItem(
                  context: context,
                  icon: Icons.add_circle_outline,
                  label: 'Create Question',
                  index: 1,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.account_tree,
                  label: 'Create Parent',
                  index: 2,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.list_alt,
                  label: 'Browse Questions',
                  index: 3,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.device_hub,
                  label: 'Parent-Child Sets',
                  index: 4,
                ),
                const SizedBox(height: 4),
                if (isWideScreen)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Text(
                      'PAPERS',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.neutralMid,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                _buildNavItem(
                  context: context,
                  icon: Icons.upload_file,
                  label: 'Upload Papers',
                  index: 5,
                ),
              ],
            ),
          ),

          // Sign out button
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.neutralMid),
            title: isWideScreen
                ? Text(
                    'Sign Out',
                    style: TextStyle(color: AppColors.neutralMid),
                  )
                : null,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        selected: isSelected,
        leading: Icon(
          icon,
          color: isSelected ? AppColors.accent : AppColors.neutralMid,
        ),
        title: isWideScreen
            ? Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.accent : AppColors.neutralMid,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              )
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selectedTileColor: AppColors.accent.withOpacity(0.1),
        onTap: () => onItemSelected(index),
      ),
    );
  }
}

/// Dashboard View with metrics
class _AdminDashboard extends ConsumerWidget {
  const _AdminDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome header
            Text(
              'Welcome Back!',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Overview of your content management system',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.neutralMid),
            ),
            const SizedBox(height: 32),

            // Metrics cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildMetricCard(
                      context: context,
                      title: 'Total Questions',
                      icon: Icons.quiz,
                      color: AppColors.accent,
                      width: isWide
                          ? (constraints.maxWidth - 32) / 3
                          : constraints.maxWidth,
                      streamBuilder: _buildQuestionCountStream(context),
                    ),
                    _buildMetricCard(
                      context: context,
                      title: 'Past Papers',
                      icon: Icons.picture_as_pdf,
                      color: Colors.blue,
                      width: isWide
                          ? (constraints.maxWidth - 32) / 3
                          : constraints.maxWidth,
                      streamBuilder: _buildPaperCountStream(context),
                    ),
                    _buildMetricCard(
                      context: context,
                      title: 'Parent Questions',
                      icon: Icons.account_tree,
                      color: Colors.purple,
                      width: isWide
                          ? (constraints.maxWidth - 32) / 3
                          : constraints.maxWidth,
                      streamBuilder: _buildParentCountStream(context),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Recent activity section
            Text(
              'Recent Activity',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRecentActivityCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required double width,
    required Widget streamBuilder,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const Spacer(),
                  streamBuilder,
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.neutralMid),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCountStream(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('questions')
          .where('isParent', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'Error',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        final count = snapshot.data!.docs.length;
        return Text(
          count.toString(),
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        );
      },
    );
  }

  Widget _buildPaperCountStream(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('papers').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'Error',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        final count = snapshot.data!.docs.length;
        return Text(
          count.toString(),
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        );
      },
    );
  }

  Widget _buildParentCountStream(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('questions')
          .where('isParent', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'Error',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        final count = snapshot.data!.docs.length;
        return Text(
          count.toString(),
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        );
      },
    );
  }

  Widget _buildRecentActivityCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('questions')
              .orderBy('createdAt', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(
                'Error loading recent activity',
                style: TextStyle(color: AppColors.neutralMid),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No recent questions yet. Start creating!',
                  style: TextStyle(color: AppColors.neutralMid),
                ),
              );
            }

            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final subject = data['subject'] ?? 'Unknown';
                final topic = data['topic'] ?? 'No topic';
                final format =
                    data['format'] ?? data['questionType'] ?? 'Unknown';
                final isParent = data['isParent'] == true;

                return ListTile(
                  leading: Icon(
                    isParent ? Icons.account_tree : Icons.quiz,
                    color: AppColors.accent,
                  ),
                  title: Text('$subject - $topic'),
                  subtitle: Text(isParent ? 'Parent Question' : format),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.neutralMid,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
