import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/utils/app_constants.dart';
import 'package:past_question_paper_v1/widgets/topic_list_view.dart';
import 'package:past_question_paper_v1/widgets/mode_list_view.dart' as list;

import '../repositories/question_repository.dart';
import 'practice_screen.dart';
import 'mistake_bank_screen.dart';

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
        // Extract topic color if available
        Color? topicColor;
        if (options['topicColor'] != null) {
          topicColor = Color(options['topicColor'] as int);
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PracticeScreen(
              questions: questions,
              isPQPMode: isPQPMode,
              isSprintMode: isSprintMode,
              configuredDurationMinutes: durationMinutes,
              modeKey: modeKey ?? options['mode']?.toString(),
              topicColor: topicColor,
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
        final isNetworkError =
            errorMessage.toLowerCase().contains('network') ||
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
enum TestMode { fullExam, quickPractice, byTopic, retryMistakes }

// Enum for journey node position
enum JourneyPosition { start, middle, end }

class TestConfigurationScreen extends ConsumerStatefulWidget {
  final String subject;
  final int grade;
  final Color? subjectColor;

  const TestConfigurationScreen({
    super.key,
    required this.subject,
    required this.grade,
    this.subjectColor,
  });

  @override
  ConsumerState<TestConfigurationScreen> createState() =>
      _TestConfigurationScreenState();
}

class _TestConfigurationScreenState
    extends ConsumerState<TestConfigurationScreen> {
  TestMode? _selectedMode;

  // Get the appropriate logo color for each mode
  Color _getModeColor(TestMode mode) {
    return AppColors.accent; // Use same orange accent color for all modes
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(widget.subject),
        backgroundColor: _selectedMode != null
            ? _getModeColor(_selectedMode!)
            : (widget.subjectColor ?? colorScheme.background),
        foregroundColor: (_selectedMode != null || widget.subjectColor != null)
            ? Colors.white
            : colorScheme.onBackground,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MistakeBankScreen(
                    subject: widget.subject,
                    grade: widget.grade,
                    subjectColor: widget.subjectColor,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.bookmarks_outlined),
            label: const Text('Mistakes'),
            style: TextButton.styleFrom(
              foregroundColor: (_selectedMode != null || widget.subjectColor != null)
                  ? Colors.white
                  : colorScheme.onBackground,
            ),
          ),
        ],
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

  // Mode selection screen showing available practice modes
  Widget _buildModeSelection() {
    final modeOptions = [
      {
        'list': list.ModeOption(
          name: 'By Topic',
          description: 'Master the basics with focused topic practice',
          icon: Icons.bookmark_border,
          color: AppColors.accent,
        ),
        'mode': TestMode.byTopic,
      },
      {
        'list': list.ModeOption(
          name: 'Quick Practice',
          description: 'Speed challenge with mixed questions',
          icon: Icons.timer_outlined,
          color: AppColors.accent,
        ),
        'mode': TestMode.quickPractice,
      },
      {
        'list': list.ModeOption(
          name: 'Retry Mistakes',
          description: 'Review questions you missed or skipped',
          icon: Icons.refresh,
          color: AppColors.accent,
        ),
        'mode': TestMode.retryMistakes,
      },
      {
        'list': list.ModeOption(
          name: 'Full Exam',
          description: 'Complete exam simulation - the final boss!',
          icon: Icons.article,
          color: AppColors.accent,
        ),
        'mode': TestMode.fullExam,
      },
    ];

    return list.ModeListView(
      modes: modeOptions
          .map((option) => option['list'] as list.ModeOption)
          .toList(),
      onModeSelected: (mode, index) {
        setState(() {
          _selectedMode = modeOptions[index]['mode'] as TestMode;
        });
      },
    );
  }

  // Configuration screen based on selected mode
  Widget _buildModeConfiguration(TestMode mode) {
    final modeColor = _getModeColor(mode);
    switch (mode) {
      case TestMode.fullExam:
        return _FullExamView(
          grade: widget.grade,
          subject: widget.subject,
          modeColor: modeColor,
        );
      case TestMode.quickPractice:
        return _QuickPracticeView(
          grade: widget.grade,
          subject: widget.subject,
          modeColor: modeColor,
        );
      case TestMode.byTopic:
        return _ByTopicView(
          grade: widget.grade,
          subject: widget.subject,
          subjectColor: widget.subjectColor,
          modeColor: modeColor,
        );
      case TestMode.retryMistakes:
        return _RetryMistakesView(
          grade: widget.grade,
          subject: widget.subject,
          modeColor: modeColor,
        );
    }
  }
}

// --- View for "Full Exam" Tab ---
class _FullExamView extends ConsumerStatefulWidget {
  final int grade;
  final String subject;
  final Color? modeColor;
  const _FullExamView({
    required this.grade,
    required this.subject,
    this.modeColor,
  });

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
  final Color? modeColor;
  const _QuickPracticeView({
    required this.grade,
    required this.subject,
    this.modeColor,
  });

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

// --- View for "Retry Mistakes" ---
class _RetryMistakesView extends ConsumerStatefulWidget {
  final int grade;
  final String subject;
  final Color? modeColor;

  const _RetryMistakesView({
    required this.grade,
    required this.subject,
    this.modeColor,
  });

  @override
  ConsumerState<_RetryMistakesView> createState() => _RetryMistakesViewState();
}

class _RetryMistakesViewState extends ConsumerState<_RetryMistakesView> {
  @override
  Widget build(BuildContext context) {
    final loadingButtonId = ref.watch(testConfigurationViewModelProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStartCard(
          context,
          title: 'Start Retry',
          subtitle: 'Focus on questions you missed or skipped',
          icon: Icons.refresh,
          isLoading: loadingButtonId == 'retry_mistakes_start',
          onTap: () {
            ref
                .read(testConfigurationViewModelProvider.notifier)
                .startTest(
                  context,
                  {
                    'grade': widget.grade,
                    'subject': widget.subject,
                    'mode': 'retry_mistakes',
                    'paper': 'p1',
                    'questionCount': 20,
                  },
                  'retry_mistakes_start',
                  modeKey: 'retry_mistakes',
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
  final Color? subjectColor;
  final Color? modeColor;
  const _ByTopicView({
    required this.grade,
    required this.subject,
    this.subjectColor,
    this.modeColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingButtonId = ref.watch(testConfigurationViewModelProvider);
    final topics = AppConstants.topicsBySubject[subject] ?? [];

    return Column(
      children: [
        Expanded(
          child: TopicListView(
            key: const ValueKey('topic_list'),
            topics: topics,
            loadingTopicId: loadingButtonId,
            modeColor: modeColor,
            onTopicSelected: (topic, index) {
              final buttonId = 'topic_$index';
              final topicColors = [
                AppColors.brandCyan,
                AppColors.brandMagenta,
                AppColors.brandLavender,
                AppColors.brandTeal,
                AppColors.accent,
                AppColors.brandCyan,
                AppColors.brandMagenta,
                AppColors.brandLavender,
              ];
              final topicColor = topicColors[index % topicColors.length];

              ref
                  .read(testConfigurationViewModelProvider.notifier)
                  .startTest(
                    context,
                    {
                      'grade': grade,
                      'subject': subject,
                      'mode': 'by_topic',
                      'topic': topic,
                      'paper': 'p1',
                      'topicColor': topicColor.value, // Pass color as int
                    },
                    buttonId,
                    modeKey: 'by_topic',
                    sessionMetadata: {
                      'topic': topic,
                      'topicColor': topicColor.value,
                    },
                  );
            },
          ),
        ),
      ],
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
