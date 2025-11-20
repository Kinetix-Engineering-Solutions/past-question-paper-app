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

// Enum for journey node position
enum JourneyPosition { start, middle, end }

// Custom painter for the winding path
class _PathPainter extends CustomPainter {
  final Color color;

  _PathPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Start from top center
    path.moveTo(size.width * 0.5, 80);
    
    // Curve to left
    path.quadraticBezierTo(
      size.width * 0.3, 150,
      size.width * 0.2, 260,
    );
    
    // Curve to right
    path.quadraticBezierTo(
      size.width * 0.1, 350,
      size.width * 0.5, 370,
    );
    
    // Curve to final position
    path.quadraticBezierTo(
      size.width * 0.8, 390,
      size.width * 0.65, 450,
    );

    canvas.drawPath(path, paint);
    
    // Draw dotted overlay
    final dashPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    _drawDashedPath(canvas, path, dashPaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 10.0;
    const dashSpace = 8.0;
    double distance = 0.0;

    for (var pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        final segment = pathMetric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

  // Mode selection screen with Candy Crush-style level map UI
  Widget _buildModeSelection() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Choose Practice Mode',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select the type of practice that best suits your learning goals',
                  style: textTheme.bodyMedium?.copyWith(
                    color: textTheme.bodyMedium?.color?.withOpacity(0.75) ??
                        colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 700,
            child: Stack(
              children: [
                // Winding path background
                CustomPaint(
                  size: Size(screenWidth, 700),
                  painter: _PathPainter(colorScheme.primary.withOpacity(0.2)),
                ),
                
                // Level nodes positioned along the path
                Positioned(
                  left: screenWidth * 0.5 - 60,
                  top: 80,
                  child: _buildLevelNode(
                    context: context,
                    level: 1,
                    icon: Icons.bookmark_border,
                    title: 'By Topic',
                    subtitle: 'Master the basics',
                    color: Colors.green,
                    mode: TestMode.byTopic,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ),
                
                Positioned(
                  left: screenWidth * 0.2 - 60,
                  top: 260,
                  child: _buildLevelNode(
                    context: context,
                    level: 2,
                    icon: Icons.timer_outlined,
                    title: 'Quick Practice',
                    subtitle: 'Speed challenge',
                    color: Colors.orange,
                    mode: TestMode.quickPractice,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ),
                
                Positioned(
                  left: screenWidth * 0.65 - 60,
                  top: 450,
                  child: _buildLevelNode(
                    context: context,
                    level: 3,
                    icon: Icons.article,
                    title: 'Full Exam',
                    subtitle: 'Final boss!',
                    color: Colors.blue,
                    mode: TestMode.fullExam,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Candy Crush style level node
  Widget _buildLevelNode({
    required BuildContext context,
    required int level,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required TestMode mode,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: Column(
        children: [
          // Main circular level button
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: Colors.white,
                width: 5,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icon,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                // Level number badge
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '$level',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Label container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
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

// Custom painter for topic path (alternating left-right)
class _TopicPathPainter extends CustomPainter {
  final Color color;
  final int topicCount;
  final double screenWidth;

  _TopicPathPainter(this.color, this.topicCount, this.screenWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Start from first topic position (centered)
    path.moveTo(screenWidth * 0.5, 130);
    
    // Draw straight line down through all topics
    for (int i = 0; i < topicCount - 1; i++) {
      final nextY = 130.0 + ((i + 1) * 180.0);
      path.lineTo(screenWidth * 0.5, nextY);
    }

    canvas.drawPath(path, paint);
    
    // Draw dotted overlay
    final dashPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    _drawDashedPath(canvas, path, dashPaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 10.0;
    const dashSpace = 8.0;
    double distance = 0.0;

    for (var pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        final segment = pathMetric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    final topics = AppConstants.topicsBySubject[subject] ?? [];
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Define colors for topics (cycle through colors)
    final topicColors = [
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.deepOrange,
      Colors.cyan,
      Colors.amber,
      Colors.green,
      Colors.red,
      Colors.blue,
    ];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Select a Topic',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a topic to practice',
                  style: textTheme.bodyMedium?.copyWith(
                    color: textTheme.bodyMedium?.color?.withOpacity(0.75) ??
                        colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: topics.length * 180.0 + 100,
            child: Stack(
              children: [
                // Winding path connecting topics
                CustomPaint(
                  size: Size(screenWidth, topics.length * 180.0 + 100),
                  painter: _TopicPathPainter(
                    colorScheme.primary.withOpacity(0.2),
                    topics.length,
                    screenWidth,
                  ),
                ),
                // Position topic nodes along the path
                ...List.generate(topics.length, (index) {
                  final topic = topics[index];
                  final buttonId = 'topic_$index';
                  final color = topicColors[index % topicColors.length];
                  final isLoading = loadingButtonId == buttonId;
                  
                  // Center all nodes
                  final leftPosition = screenWidth * 0.5 - 50;
                  final topPosition = 80.0 + (index * 180.0);

                  return Positioned(
                    left: leftPosition,
                    top: topPosition,
                    child: GestureDetector(
                      onTap: isLoading
                          ? null
                          : () {
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
                                    },
                                    buttonId,
                                    modeKey: 'by_topic',
                                    sessionMetadata: {'topic': topic},
                                  );
                            },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Circular node
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Icon
                                Center(
                                  child: Icon(
                                    Icons.bookmark_border,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                                // Level number badge
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: color, width: 2),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Loading indicator
                                if (isLoading)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Label
                          Container(
                            width: 120,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              topic,
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
