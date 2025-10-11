import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';

class QuestionReviewScreen extends StatefulWidget {
  final Map<String, dynamic> gradingResults;
  final List<Map<String, dynamic>> questions;

  const QuestionReviewScreen({
    super.key,
    required this.gradingResults,
    required this.questions,
  });

  @override
  State<QuestionReviewScreen> createState() => _QuestionReviewScreenState();
}

class _QuestionReviewScreenState extends State<QuestionReviewScreen> {
  late PageController _pageController;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final results = _extractList(widget.gradingResults['results']) ?? [];

    // Create a map for easy question lookup
    final questionMap = <String, Map<String, dynamic>>{};
    for (var q in widget.questions) {
      final id = q['id']?.toString();
      if (id != null) {
        questionMap[id] = q;
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        foregroundColor: colorScheme.onBackground,
        title: Text(
          'Question ${_currentQuestionIndex + 1} of ${results.length}',
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Simple progress indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: LinearProgressIndicator(
              value: ((_currentQuestionIndex + 1) / results.length),
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: AppColors.accent,
            ),
          ),

          // Question content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentQuestionIndex = index;
                });
              },
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = _extractMap(results[index]) ?? {};
                final questionId = result['questionId']?.toString();
                final question = questionId != null
                    ? questionMap[questionId]
                    : null;

                return _buildQuestionCard(result, question);
              },
            ),
          ),

          // Simple navigation
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentQuestionIndex > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentQuestionIndex < results.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    Map<String, dynamic> result,
    Map<String, dynamic>? question,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCorrect = result['isCorrect'] == true;
    final userAnswer = result['userAnswer'];
    final correctAnswer = result['correctAnswer'];
    final format = result['format']?.toString() ?? 'multipleChoice';
    final marksAwarded = _extractInt(result['marksAwarded']) ?? 0;
    final maxMarks = _extractInt(result['maxMarks']) ?? 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCorrect ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  isCorrect
                      ? 'Correct! ($marksAwarded/$maxMarks pts)'
                      : 'Incorrect ($marksAwarded/$maxMarks pts)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Question text
          if (question != null && question['questionText'] != null) ...[
            Text(
              'Question:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              question['questionText'],
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Question image
          if (question != null && question['imageUrl'] != null) ...[
            Image.network(
              question['imageUrl'],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 100,
                color: colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Text(
                    'Image unavailable',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Options for MCQ
          if (question != null &&
              question['options'] != null &&
              format.toLowerCase().contains('multiple')) ...[
            Text(
              'Options:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ...(_extractList(question['options']) ?? []).asMap().entries.map((
              entry,
            ) {
              final index = entry.key;
              final option = entry.value.toString();
              final optionLabel = String.fromCharCode(65 + index); // A, B, C, D
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '$optionLabel) $option',
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
          ],

          // Answer comparison
          _buildAnswerComparison(
            format,
            userAnswer,
            correctAnswer,
            result,
            colorScheme,
          ),

          // Explanation
          if (question != null && question['explanation'] != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Explanation',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    question['explanation'],
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerComparison(
    String format,
    dynamic userAnswer,
    dynamic correctAnswer,
    Map<String, dynamic> result,
    ColorScheme colorScheme,
  ) {
    final normalizedFormat = format.toLowerCase();
    if (normalizedFormat == 'draganddrop' ||
        normalizedFormat == 'drag-and-drop' ||
        normalizedFormat == 'drag_drop' ||
        normalizedFormat == 'drag and drop') {
      final subFormat = result['subFormat']?.toString();
      if (subFormat == 'ordering') {
        return _buildOrderingComparison(result, colorScheme);
      } else {
        return _buildMatchingComparison(result, colorScheme);
      }
    }

    return Column(
      children: [
        // Your answer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Answer',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userAnswer?.toString() ?? 'No answer',
                style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Correct answer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Correct Answer',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                correctAnswer?.toString() ?? 'N/A',
                style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderingComparison(
    Map<String, dynamic> result,
    ColorScheme colorScheme,
  ) {
    final detailedResults = _extractList(result['detailedResults']) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step Ordering Results:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        ...detailedResults.map((detail) {
          final detailMap = _extractMap(detail) ?? {};
          final isCorrect = detailMap['isCorrect'] == true;
          final stepPosition = detailMap['stepPosition']?.toString() ?? '';
          final userAnswer = detailMap['userAnswer']?.toString() ?? '';
          final correctAnswer = detailMap['correctAnswer']?.toString() ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCorrect
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isCorrect
                    ? Colors.green.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      stepPosition,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your: $userAnswer',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (!isCorrect)
                        Text(
                          'Correct: $correctAnswer',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 16,
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMatchingComparison(
    Map<String, dynamic> result,
    ColorScheme colorScheme,
  ) {
    final detailedResults = _extractList(result['detailedResults']) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Matching Results:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        ...detailedResults.map((detail) {
          final detailMap = _extractMap(detail) ?? {};
          final isCorrect = detailMap['isCorrect'] == true;
          final targetText = detailMap['targetText']?.toString() ?? '';
          final userAnswer = detailMap['userAnswer']?.toString() ?? '';
          final correctAnswer = detailMap['correctAnswer']?.toString() ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCorrect
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isCorrect
                    ? Colors.green.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target: $targetText',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Your: $userAnswer',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (!isCorrect)
                        Text(
                          'Correct: $correctAnswer',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // Helper methods
  List<dynamic>? _extractList(dynamic value) {
    if (value is List) return value;
    return null;
  }

  Map<String, dynamic>? _extractMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  int? _extractInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
