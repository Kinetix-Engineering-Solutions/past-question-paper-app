import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/views/question_review_screen.dart';

class PracticeResultsScreen extends StatelessWidget {
  final Map<String, dynamic> gradingResults;
  final List<Map<String, dynamic>> questions;

  const PracticeResultsScreen({
    super.key,
    required this.gradingResults,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    // Safely extract statistics with type checking
    final statistics = _extractMap(gradingResults['statistics']) ?? {};
    
    // Create a map for easy question lookup (used by the review screen)
    final questionMap = <String, Map<String, dynamic>>{};
    for (var q in questions) {
      final id = q['id']?.toString();
      if (id != null) {
        questionMap[id] = q;
      }
    }

    final percentage = _extractInt(statistics['percentage']) ?? 0;
    final score = _extractInt(statistics['marksAwarded']) ?? 0;
    final totalMarks = _extractInt(statistics['totalMarks']) ?? 0;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Test Results'),
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
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
                  _getScoreColor(percentage),
                  _getScoreColor(percentage).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Your Score',
                  style: TextStyle(
                    color: _getTextColor(percentage).withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$score/$totalMarks',
                  style: TextStyle(
                    color: _getTextColor(percentage),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$percentage% (${_getGrade(percentage)})',
                  style: TextStyle(
                    color: _getTextColor(percentage),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      'Correct',
                      '${_extractInt(statistics['correctQuestions']) ?? 0}',
                      AppColors.neutralCard.withOpacity(0.9),
                      AppColors.accent,
                    ),
                    _buildStatItem(
                      'Total',
                      '${_extractInt(statistics['totalQuestions']) ?? 0}',
                      AppColors.neutralCard.withOpacity(0.9),
                      AppColors.ink,
                    ),
                    _buildStatItem(
                      'Accuracy',
                      '${_extractInt(statistics['accuracy']) ?? 0}%',
                      AppColors.neutralCard.withOpacity(0.9),
                      AppColors.neutralMid,
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
                color: AppColors.neutralCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 48,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Test Completed!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You answered ${_extractInt(statistics['correctQuestions']) ?? 0} out of ${_extractInt(statistics['totalQuestions']) ?? 0} questions correctly.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.neutralMid,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            gradingResults: gradingResults,
                            questions: questions,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.quiz),
                    label: const Text('Review Questions One by One'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.neutralCard,
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
                        onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                          '/', 
                          (route) => false,
                        ),
                        icon: const Icon(Icons.home),
                        label: const Text('Back to Home'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neutralMid,
                          foregroundColor: AppColors.neutralCard,
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
                          foregroundColor: AppColors.ink,
                          side: const BorderSide(color: AppColors.neutralBorder),
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
    );
  }

  Widget _buildStatItem(String label, String value, Color bgColor, Color textColor) {
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
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  
  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return AppColors.accent; // Great score - accent color
    if (percentage >= 60) return AppColors.neutralMid; // Good score - neutral mid
    return AppColors.ink; // Needs improvement - primary ink color
  }
  
  Color _getTextColor(int percentage) {
    // Return white for dark backgrounds, ink for light backgrounds
    if (percentage >= 80) return AppColors.neutralCard; // White text on accent background
    if (percentage >= 60) return AppColors.neutralCard; // White text on neutral mid background
    return AppColors.neutralCard; // White text on ink background
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
