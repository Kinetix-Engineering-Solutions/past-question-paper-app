import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/utils/app_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/question_repository.dart';
import 'practice_screen.dart';

// ViewModel to handle the logic for this screen
final testConfigurationViewModelProvider =
    StateNotifierProvider<TestConfigurationViewModel, String?>((ref) {
      return TestConfigurationViewModel(
        ref.watch(questionRepositoryProvider),
        ref,
      );
    });

class TestConfigurationViewModel extends StateNotifier<String?> {
  final QuestionRepository _questionRepository;

  TestConfigurationViewModel(this._questionRepository, Ref ref) : super(null);

  // The main function to start any type of test
  Future<void> startTest(
    BuildContext context,
    Map<String, dynamic> options,
    String buttonId, { // Unique identifier for the button being pressed
    bool isPQPMode = false,
    bool isSprintMode = false,
  }) async {
    if (state != null)
      return; // Prevent multiple taps while any button is loading
    state = buttonId; // Set the specific button as loading
    try {
      // Double check authentication state before proceeding
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Please log in to access this feature.');
      }

      // Refresh the auth token to ensure it's valid
      await user.getIdToken(true);

      final questions = await _questionRepository.generateTest(options);
      if (questions.isEmpty) {
        throw Exception('No questions found for the selected criteria.');
      }
      // Navigate to the practice screen with the fetched questions
      // Ensure the context is still valid before navigating
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PracticeScreen(
              questions: questions,
              isPQPMode: isPQPMode,
              isSprintMode: isSprintMode,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting test: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      state = null; // Clear the loading state
    }
  }
}

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(widget.subject),
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onBackground,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: textTheme.bodyMedium?.color?.withOpacity(0.7),
          indicatorColor: colorScheme.primary,
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
  int _selectedYear = DateTime.now().year - 1;
  String _selectedSeason = 'November';

  @override
  Widget build(BuildContext context) {
    final loadingButtonId = ref.watch(testConfigurationViewModelProvider);
    final currentYear = DateTime.now().year;
    final years = List.generate(
      5,
      (index) => currentYear - index - 1,
    ).where((year) => year > 2000).toList();
    const seasons = ['November', 'June', 'March'];
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final paper1Meta = AppConstants.getFullExamPaperMeta(
      widget.subject,
      widget.grade,
      'p1',
    );
    final paper2Meta = AppConstants.getFullExamPaperMeta(
      widget.subject,
      widget.grade,
      'p2',
    );
    final paper1Subtitle =
        paper1Meta?.summary() ?? 'Blueprint details syncing soon';
    final paper2Subtitle =
        paper2Meta?.summary() ?? 'Blueprint details syncing soon';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Full Exam Mode',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Practice with authentic past exam papers. Questions appear exactly as they did in the original exam, with proper numbering and question chains.',
          style: textTheme.bodyMedium?.copyWith(
            color:
                textTheme.bodyMedium?.color?.withOpacity(0.75) ??
                colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Find a Past Paper',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
          context,
          title: 'Paper 1 ($_selectedSeason $_selectedYear)',
          subtitle: paper1Subtitle,
          icon: Icons.article,
          isLoading: loadingButtonId == 'paper1',
          onTap: () {
            ref
                .read(testConfigurationViewModelProvider.notifier)
                .startTest(
                  context,
                  {
                    'grade': widget.grade,
                    'subject': widget.subject,
                    'paper': 'p1',
                    'mode': 'full_exam',
                    'year': _selectedYear,
                    'season': _selectedSeason,
                  },
                  'paper1',
                  isPQPMode: true,
                );
          },
        ),
        _buildStartCard(
          context,
          title: 'Paper 2 ($_selectedSeason $_selectedYear)',
          subtitle: paper2Subtitle,
          icon: Icons.article_outlined,
          isLoading: loadingButtonId == 'paper2',
          onTap: () {
            ref
                .read(testConfigurationViewModelProvider.notifier)
                .startTest(
                  context,
                  {
                    'grade': widget.grade,
                    'subject': widget.subject,
                    'paper': 'Paper 2',
                    'mode': 'full_exam',
                    'year': _selectedYear,
                    'season': _selectedSeason,
                  },
                  'paper2',
                  isPQPMode: true,
                );
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Quick Practice Mode',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Fast-paced practice with mixed topics. Questions are simplified for learning, with hints available to help you understand concepts better.',
          style: textTheme.bodyMedium?.copyWith(
            color:
                textTheme.bodyMedium?.color?.withOpacity(0.75) ??
                colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Start a Quick, Mixed-Topic Test',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _buildStartCard(
          context,
          title: '15 Minute Sprint',
          subtitle: '~25 Marks',
          icon: Icons.timer_outlined,
          isLoading: loadingButtonId == 'quick15',
          onTap: () {
            ref
                .read(testConfigurationViewModelProvider.notifier)
                .startTest(
                  context,
                  {
                    'grade': grade,
                    'subject': subject,
                    'mode': 'quick_practice',
                    'paper': 'p1', // Default to paper 1 for quick practice
                    'duration': 15,
                  },
                  'quick15',
                  isSprintMode: true,
                );
          },
        ),
        _buildStartCard(
          context,
          title: '30 Minute Review',
          subtitle: '~50 Marks',
          icon: Icons.timer,
          isLoading: loadingButtonId == 'quick30',
          onTap: () {
            ref
                .read(testConfigurationViewModelProvider.notifier)
                .startTest(
                  context,
                  {
                    'grade': grade,
                    'subject': subject,
                    'mode': 'quick_practice',
                    'paper': 'p1', // Default to paper 1 for quick practice
                    'duration': 30,
                  },
                  'quick30',
                  isSprintMode: true,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topics.length + 1, // +1 for header
      itemBuilder: (context, index) {
        // Header section
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'By Topic Mode',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Focus on specific topics to strengthen weak areas. Select a topic below to practice questions only from that section.',
                  style: textTheme.bodyMedium?.copyWith(
                    color:
                        textTheme.bodyMedium?.color?.withOpacity(0.75) ??
                        colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Select a Topic',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        // Topic cards
        final topicIndex = index - 1;
        final topic = topics[topicIndex];
        final buttonId = 'topic_$topicIndex';
        return _buildStartCard(
          context,
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
Widget _buildStartCard(
  BuildContext context, {
  required String title,
  String? subtitle,
  required IconData icon,
  required bool isLoading,
  required VoidCallback onTap,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return Card(
    elevation: 0,
    margin: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide.none,
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Icon(icon, color: colorScheme.primary, size: 32),
      title: Text(
        title,
        style:
            textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600) ??
            const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color:
                    textTheme.bodySmall?.color?.withOpacity(0.75) ??
                    colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: colorScheme.primary),
            )
          : null,
      onTap: isLoading ? null : onTap,
    ),
  );
}
