import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
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
    int? durationMinutes,
    String? modeKey,
    Map<String, dynamic>? sessionMetadata,
  }) async {
    if (state != null) {
      return; // Prevent multiple taps while any button is loading
    }
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
              configuredDurationMinutes: durationMinutes,
              modeKey: modeKey ?? options['mode']?.toString(),
              sessionMetadata: {
                'options': options,
                if (sessionMetadata != null) ...sessionMetadata,
                if (durationMinutes != null)
                  'configuredDurationMinutes': durationMinutes,
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Determine if it's an offline/connectivity error
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        final isNetworkError = errorMessage.toLowerCase().contains('network') ||
            errorMessage.toLowerCase().contains('internet') ||
            errorMessage.toLowerCase().contains('connection');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isNetworkError ? Icons.wifi_off : Icons.error_outline,
                  color: AppColors.neutralCard,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: AppColors.neutralCard),
                  ),
                ),
              ],
            ),
            backgroundColor: isNetworkError ? AppColors.ink : Colors.redAccent,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            action: isNetworkError
                ? SnackBarAction(
                    label: 'Retry',
                    textColor: AppColors.accent,
                    onPressed: () {
                      // Retry the same action
                      startTest(
                        context,
                        options,
                        buttonId,
                        isPQPMode: isPQPMode,
                        isSprintMode: isSprintMode,
                        durationMinutes: durationMinutes,
                        modeKey: modeKey,
                        sessionMetadata: sessionMetadata,
                      );
                    },
                  )
                : null,
          ),
        );
      }
    } finally {
      state = null; // Clear the loading state
    }
  }
}

// Enum for test modes
enum TestMode { fullExam, quickPractice, byTopic }

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

class _TestConfigurationScreenState extends State<TestConfigurationScreen> {
  TestMode? _selectedMode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(widget.subject),
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onBackground,
        elevation: 0,
        leading: _selectedMode != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedMode = null;
                  });
                },
              )
            : null,
      ),
      body: _selectedMode == null
          ? _buildModeSelection()
          : _buildModeConfiguration(_selectedMode!),
    );
  }

  // Mode selection screen with three cards
  Widget _buildModeSelection() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Choose Practice Mode',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the type of practice that best suits your learning goals.',
          style: textTheme.bodyMedium?.copyWith(
            color:
                textTheme.bodyMedium?.color?.withOpacity(0.75) ??
                colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        _buildModeCard(
          icon: Icons.article,
          title: 'Full Exam Mode',
          description:
              'Practice with authentic past exam papers. Questions appear exactly as they did in the original exam, with proper numbering and question chains.',
          mode: TestMode.fullExam,
          colorScheme: colorScheme,
          textTheme: textTheme,
        ),
        const SizedBox(height: 16),
        _buildModeCard(
          icon: Icons.timer_outlined,
          title: 'Quick Practice',
          description:
              'Fast-paced practice with mixed topics. Questions are simplified for learning, with hints available. Choose your own duration.',
          mode: TestMode.quickPractice,
          colorScheme: colorScheme,
          textTheme: textTheme,
        ),
        const SizedBox(height: 16),
        _buildModeCard(
          icon: Icons.bookmark_border,
          title: 'By Topic',
          description:
              'Focus on specific topics to strengthen weak areas. Select a topic to practice questions only from that section.',
          mode: TestMode.byTopic,
          colorScheme: colorScheme,
          textTheme: textTheme,
        ),
      ],
    );
  }

  // Individual mode card
  Widget _buildModeCard({
    required IconData icon,
    required String title,
    required String description,
    required TestMode mode,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMode = mode;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: colorScheme.primary, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(
                  color:
                      textTheme.bodyMedium?.color?.withOpacity(0.75) ??
                      colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Configuration screen based on selected mode
  Widget _buildModeConfiguration(TestMode mode) {
    switch (mode) {
      case TestMode.fullExam:
        return _FullExamView(grade: widget.grade, subject: widget.subject);
      case TestMode.quickPractice:
        return _QuickPracticeView(grade: widget.grade, subject: widget.subject);
      case TestMode.byTopic:
        return _ByTopicView(grade: widget.grade, subject: widget.subject);
    }
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
          'Select Past Paper',
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
                  modeKey: 'full_exam',
                  sessionMetadata: {
                    'year': _selectedYear,
                    'season': _selectedSeason,
                    'paper': 'p1',
                  },
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
                  modeKey: 'full_exam',
                  sessionMetadata: {
                    'year': _selectedYear,
                    'season': _selectedSeason,
                    'paper': 'Paper 2',
                  },
                );
          },
        ),
      ],
    );
  }
}

// --- View for "Quick Practice" Tab ---

class _QuickPracticeView extends ConsumerStatefulWidget {
  final int grade;
  final String subject;
  const _QuickPracticeView({required this.grade, required this.subject});

  @override
  ConsumerState<_QuickPracticeView> createState() => _QuickPracticeViewState();
}

class _QuickPracticeViewState extends ConsumerState<_QuickPracticeView> {
  double _selectedDuration = 15;

  @override
  Widget build(BuildContext context) {
    final loadingButtonId = ref.watch(testConfigurationViewModelProvider);
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Choose Duration',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Slider(
                min: 5,
                max: 60,
                divisions: 11,
                value: _selectedDuration,
                label: '${_selectedDuration.round()} min',
                onChanged: (value) {
                  setState(() {
                    _selectedDuration = value;
                  });
                },
              ),
            ),
            SizedBox(width: 12),
            Text(
              '${_selectedDuration.round()} min',
              style: textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildStartCard(
          context,
          title: 'Start Sprint',
          subtitle: 'Custom duration: ${_selectedDuration.round()} min',
          icon: Icons.timer_outlined,
          isLoading: loadingButtonId == 'quick_custom',
          onTap: () {
            ref
                .read(testConfigurationViewModelProvider.notifier)
                .startTest(
                  context,
                  {
                    'grade': widget.grade,
                    'subject': widget.subject,
                    'mode': 'quick_practice',
                    'paper': 'p1',
                    'duration': _selectedDuration.round(),
                  },
                  'quick_custom',
                  isSprintMode: true,
                  modeKey: 'quick_practice',
                  durationMinutes: _selectedDuration.round(),
                  sessionMetadata: {'duration': _selectedDuration.round()},
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
                  'Select a Topic',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a topic to practice',
                  style: textTheme.bodyMedium?.copyWith(
                    color: textTheme.bodyMedium?.color?.withOpacity(0.75),
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
            ref
                .read(testConfigurationViewModelProvider.notifier)
                .startTest(
                  context,
                  {
                    'grade': grade,
                    'subject': subject,
                    'mode': 'by_topic',
                    'topic': topic,
                    'paper': 'p1', // Default to paper 1 for topic practice
                  },
                  buttonId,
                  modeKey: 'by_topic',
                  sessionMetadata: {'topic': topic},
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
