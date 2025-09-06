import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/utils/app_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/viewmodels/testconfiguration_viewmodel.dart';

// ViewModel to handle the logic for this screen

class TestConfigurationScreen extends StatefulWidget {
  final String subject;
  final int grade;

  const TestConfigurationScreen({
    super.key,
    required this.subject,
    required this.grade,
  });

  @override
  State<TestConfigurationScreen> createState() =>
      _TestConfigurationScreenState();
}

class _TestConfigurationScreenState extends State<TestConfigurationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: Text(widget.subject),
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.neutralMid,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: 'Full Exam'),
            Tab(text: 'Quick Practice'),
            Tab(text: 'By Topic'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FullExamView(grade: widget.grade, subject: widget.subject),
          _QuickPracticeView(grade: widget.grade, subject: widget.subject),
          _ByTopicView(grade: widget.grade, subject: widget.subject),
        ],
      ),
    );
  }
}

// --- View for "Full Exam" Tab ---
class _FullExamView extends ConsumerStatefulWidget {
  final int grade;
  final String subject;
  const _FullExamView({required this.grade, required this.subject});

  @override
  ConsumerState<_FullExamView> createState() => _FullExamViewState();
}

class _FullExamViewState extends ConsumerState<_FullExamView> {
  // State for selected year and season
  int _selectedYear = DateTime.now().year;
  String _selectedSeason = 'November';

  @override
  Widget build(BuildContext context) {
    final loadingButtonId = ref.watch(testConfigurationViewModelProvider);
    final years = List.generate(4, (index) => DateTime.now().year - index);
    const seasons = ['November', 'June', 'March'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Find a Past Paper',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // --- Dropdowns for year and season ---
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _selectedYear,
                items: years
                    .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                    .toList(),
                onChanged: (value) => setState(() => _selectedYear = value!),
                decoration: const InputDecoration(labelText: 'Year'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedSeason,
                items: seasons
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedSeason = value!),
                decoration: const InputDecoration(labelText: 'Season'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildStartCard(
          title: 'Paper 1 ($_selectedSeason $_selectedYear)',
          icon: Icons.article,
          isLoading: loadingButtonId == 'paper1',
          onTap: () {
            ref
                .read(testConfigurationViewModelProvider.notifier)
                .startTest(context, {
                  'grade': widget.grade,
                  'subject': widget.subject,
                  'paper': 'p1',
                  'mode': 'full_exam',
                  'year': _selectedYear,
                  'season': _selectedSeason,
                }, 'paper1');
          },
        ),
        _buildStartCard(
          title: 'Paper 2 ($_selectedSeason $_selectedYear)',
          icon: Icons.article_outlined,
          isLoading: loadingButtonId == 'paper2',
          onTap: () {
            ref
                .read(testConfigurationViewModelProvider.notifier)
                .startTest(context, {
                  'grade': widget.grade,
                  'subject': widget.subject,
                  'paper': 'Paper 2',
                  'mode': 'full_exam',
                  'year': _selectedYear,
                  'season': _selectedSeason,
                }, 'paper2');
          },
        ),
      ],
    );
  }
}

// --- View for "Quick Practice" Tab ---
class _QuickPracticeView extends ConsumerWidget {
  final int grade;
  final String subject;
  const _QuickPracticeView({required this.grade, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingButtonId = ref.watch(testConfigurationViewModelProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Start a Quick, Mixed-Topic Test',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildStartCard(
          title: '15 Minute Sprint',
          subtitle: '~25 Marks',
          icon: Icons.timer_outlined,
          isLoading: loadingButtonId == 'quick15',
          onTap: () {
            ref.read(testConfigurationViewModelProvider.notifier).startTest(
              context,
              {
                'grade': grade,
                'subject': subject,
                'mode': 'quick_practice',
                'paper': 'p1', // Default to paper 1 for quick practice
                'duration': 15,
              },
              'quick15',
            );
          },
        ),
        _buildStartCard(
          title: '30 Minute Review',
          subtitle: '~50 Marks',
          icon: Icons.timer,
          isLoading: loadingButtonId == 'quick30',
          onTap: () {
            ref.read(testConfigurationViewModelProvider.notifier).startTest(
              context,
              {
                'grade': grade,
                'subject': subject,
                'mode': 'quick_practice',
                'paper': 'p1', // Default to paper 1 for quick practice
                'duration': 30,
              },
              'quick30',
            );
          },
        ),
      ],
    );
  }
}

// --- View for "By Topic" Tab ---
class _ByTopicView extends ConsumerWidget {
  final int grade;
  final String subject;
  const _ByTopicView({required this.grade, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingButtonId = ref.watch(testConfigurationViewModelProvider);
    // Get the topics for the current subject from your constants file
    final topics = AppConstants.topicsBySubject[subject] ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        final buttonId = 'topic_$index';
        return _buildStartCard(
          title: topic,
          icon: Icons.bookmark_border,
          isLoading: loadingButtonId == buttonId,
          onTap: () {
            ref.read(testConfigurationViewModelProvider.notifier).startTest(
              context,
              {
                'grade': grade,
                'subject': subject,
                'mode': 'by_topic',
                'topic': topic,
                'paper': 'p1', // Default to paper 1 for topic practice
              },
              buttonId,
            );
          },
        );
      },
    );
  }
}

// --- Reusable Card Widget for Starting a Test ---
Widget _buildStartCard({
  required String title,
  String? subtitle,
  required IconData icon,
  required bool isLoading,
  required VoidCallback onTap,
}) {
  return Card(
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.neutralBorder),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Icon(icon, color: AppColors.accent, size: 32),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : const Icon(
              Icons.play_circle_fill,
              color: AppColors.accent,
              size: 28,
            ),
      onTap: isLoading ? null : onTap,
    ),
  );
}
