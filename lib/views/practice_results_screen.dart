import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/views/question_review_screen.dart';
import 'package:confetti/confetti.dart';

class PracticeResultsScreen extends StatefulWidget {
  final Map<String, dynamic> gradingResults;
  final List<Map<String, dynamic>> questions;
  final bool isPQPMode;
  final bool isSprintMode;

  const PracticeResultsScreen({
    super.key,
    required this.gradingResults,
    required this.questions,
    this.isPQPMode = false,
    this.isSprintMode = false,
  });

  @override
  State<PracticeResultsScreen> createState() => _PracticeResultsScreenState();
}

class _PracticeResultsScreenState extends State<PracticeResultsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Play confetti if score is >= 70%
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final statistics = _extractMap(widget.gradingResults['statistics']) ?? {};
      final percentage = _extractInt(statistics['percentage']) ?? 0;
      if (percentage >= 70) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Safely extract statistics with type checking
    final statistics = _extractMap(widget.gradingResults['statistics']) ?? {};

    // Create a map for easy question lookup (used by the review screen)
    final questionMap = <String, Map<String, dynamic>>{};
    for (var q in widget.questions) {
      final id = q['id']?.toString();
      if (id != null) {
        questionMap[id] = q;
      }
    }

    final percentage = _extractInt(statistics['percentage']) ?? 0;
    final score = _extractInt(statistics['marksAwarded']) ?? 0;
    final totalMarks = _extractInt(statistics['totalMarks']) ?? 0;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            title: const Text('Test Results'),
            backgroundColor: colorScheme.background,
            foregroundColor: colorScheme.onBackground,
            elevation: 0,
          ),
          body: Column(
            children: [
              // Overall Statistics Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getScoreColor(percentage, colorScheme),
                      _getScoreColor(percentage, colorScheme).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Marks Earned',
                      style: TextStyle(
                        color: _getTextColor(
                          percentage,
                          colorScheme,
                        ).withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$score/$totalMarks',
                      style: TextStyle(
                        color: _getTextColor(percentage, colorScheme),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'marks',
                      style: TextStyle(
                        color: _getTextColor(
                          percentage,
                          colorScheme,
                        ).withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$percentage% (${_getGrade(percentage)})',
                      style: TextStyle(
                        color: _getTextColor(percentage, colorScheme),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          'Mark %',
                          '${percentage}%',
                          colorScheme.surface,
                          AppColors.accent,
                        ),
                        _buildStatItem(
                          'Grade',
                          _getGrade(percentage),
                          colorScheme.surface,
                          colorScheme.onSurface,
                        ),
                        _buildStatItem(
                          'Questions',
                          '${_extractInt(statistics['totalQuestions']) ?? 0}',
                          colorScheme.surface,
                          colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Summary Info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Test Completed!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You earned $score out of $totalMarks marks (${percentage}% - ${_getGrade(percentage)} grade).',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Use "Review Questions" below to see detailed answers',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Review Questions Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => QuestionReviewScreen(
                                gradingResults: widget.gradingResults,
                                questions: widget.questions,
                                isPQPMode: widget.isPQPMode,
                                isSprintMode: widget.isSprintMode,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.quiz),
                        label: const Text('Review Questions One by One'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Bottom action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/home',
                                  (route) => false,
                                ),
                            icon: const Icon(Icons.home),
                            label: const Text('Back to Home'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              foregroundColor: colorScheme.onSurface,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              side: BorderSide(color: colorScheme.outline),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Confetti widget overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [
              AppColors.accent,
              Color(0xFF00BCD4), // Cyan
              Color(0xFFE91E63), // Magenta
              Color(0xFF4CAF50), // Green
              Color(0xFFFFC107), // Amber
            ],
            createParticlePath: (size) {
              final path = Path();
              path.addOval(
                Rect.fromCircle(center: Offset.zero, radius: size.width / 2),
              );
              return path;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int percentage, ColorScheme colorScheme) {
    if (percentage >= 80) return AppColors.accent; // Great score - accent color
    if (percentage >= 60)
      return AppColors.neutralCard; // Good score - white/light card
    return AppColors.neutralMid; // Needs improvement - medium gray
  }

  Color _getTextColor(int percentage, ColorScheme colorScheme) {
    // Return white for accent background, dark text for light backgrounds
    if (percentage >= 80) return Colors.white;
    if (percentage >= 60) return AppColors.ink; // Dark text on light background
    return Colors.white; // White text on gray background
  }

  String _getGrade(int percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  // Helper methods for safe type extraction
  Map<String, dynamic>? _extractMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      final Map<String, dynamic> result = {};
      value.forEach((key, val) {
        result[key.toString()] = val;
      });
      return result;
    }
    return null;
  }

  int? _extractInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
