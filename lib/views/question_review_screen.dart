import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/widgets/latex_text.dart';

class QuestionReviewScreen extends StatefulWidget {
  final Map<String, dynamic> gradingResults;
  final List<Map<String, dynamic>> questions;
  final bool isPQPMode;
  final bool isSprintMode;

  const QuestionReviewScreen({
    super.key,
    required this.gradingResults,
    required this.questions,
    this.isPQPMode = false,
    this.isSprintMode = false,
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

    // Build an ordered list of (result, question) pairs to simplify rendering
    final items = results.map<Map<String, dynamic>>((r) {
      final rm = _extractMap(r) ?? {};
      final qid = rm['questionId']?.toString();
      final q = qid != null ? questionMap[qid] : null;
      return {'result': rm, 'question': q};
    }).toList();

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        foregroundColor: colorScheme.onBackground,
        title: _buildTitle(items),
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

          // Quick jump navigator
          if (items.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final res = items[index]['result'] as Map<String, dynamic>;
                  final isCorrect = res['isCorrect'] == true;
                  final wasUnanswered = res['wasUnanswered'] == true;
                  final label = _questionLabel(items, index);
                  Color bg;
                  if (wasUnanswered) {
                    bg = Colors.grey.withOpacity(0.15);
                  } else {
                    bg = (isCorrect ? Colors.green : Colors.red).withOpacity(
                      0.15,
                    );
                  }
                  final selected = index == _currentQuestionIndex;
                  return InkWell(
                    onTap: () => _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accent.withOpacity(0.15)
                            : bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? AppColors.accent
                              : bg.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.accent
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: items.length,
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
                final item = items[index];
                final result = item['result'] as Map<String, dynamic>;
                final question = item['question'] as Map<String, dynamic>?;
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
    final format = _normalizeFormat(result['format']?.toString());
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

          // Parent context (if any)
          if (question != null &&
              _extractMap(question['parentContext']) != null) ...[
            _buildParentContext(question),
            const SizedBox(height: 12),
          ],

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
            LatexText(
              question['questionText'],
              textStyle: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Question image
          if (question != null &&
              (question['imageUrl'] != null ||
                  _extractMap(question['parentContext'])?['imageUrl'] !=
                      null)) ...[
            Image.network(
              question['imageUrl'] ??
                  _extractMap(question['parentContext'])?['imageUrl'],
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
              (format == 'mcq' || format == 'multiplechoice')) ...[
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
                child: LatexText(
                  '$optionLabel) $option',
                  textStyle: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
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
            question,
          ),
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
    Map<String, dynamic>? question,
  ) {
    final normalizedFormat = format.toLowerCase();
    // Robust detection for drag-drop variants and fallbacks
    final subFormat = (result['subFormat']?.toString().toLowerCase() ?? '');
    final isDragDrop =
        normalizedFormat.contains('drag') && normalizedFormat.contains('drop');
    final isOrdering =
        isDragDrop &&
        (subFormat == 'ordering' ||
            normalizedFormat.contains('ordering') ||
            (result['correctOrder'] != null));
    final isMatching =
        isDragDrop &&
        (subFormat == 'matching' ||
            normalizedFormat.contains('matching') ||
            (result['detailedResults'] != null));
    if (isOrdering) {
      return _buildOrderingComparison(result, question, colorScheme);
    }
    if (isMatching) {
      return _buildMatchingComparison(result, colorScheme);
    }

    // Beautify MCQ/True-False answers using options where available
    String renderAnswer(dynamic value) {
      final raw = value?.toString();
      if (raw == null) return 'No answer';
      if (question != null && (format == 'mcq' || format == 'multiplechoice')) {
        final opts = _extractList(question['options']) ?? [];
        int? idx;
        if (raw.length == 1 && RegExp(r'^[A-Za-z]$').hasMatch(raw)) {
          idx = raw.toUpperCase().codeUnitAt(0) - 65; // A->0
        } else {
          idx = int.tryParse(raw);
        }
        if (idx != null && idx >= 0 && idx < opts.length) {
          final label = String.fromCharCode(65 + idx);
          return '$label) ${opts[idx].toString()}';
        }
      }
      if (normalizedFormat == 'true_false' ||
          raw.toLowerCase() == 'true' ||
          raw.toLowerCase() == 'false') {
        return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
      }
      return raw;
    }

    // Helper to check if answer is an image URL
    bool isImageUrl(String text) {
      if (text.isEmpty) return false;
      // Extract the actual URL if format is "A) https://..."
      String urlPart = text;
      if (text.contains(') ')) {
        urlPart = text.split(') ').last;
      }
      return urlPart.startsWith('http') &&
          (urlPart.contains('.jpg') ||
              urlPart.contains('.jpeg') ||
              urlPart.contains('.png') ||
              urlPart.contains('.gif') ||
              urlPart.contains('.webp'));
    }

    // Helper to build answer widget (text or image)
    Widget buildAnswerWidget(String text, TextStyle style) {
      if (isImageUrl(text)) {
        // Extract option letter (e.g., "A") and URL
        String optionLetter = '';
        String imageUrl = text;
        if (text.contains(') ')) {
          final parts = text.split(') ');
          optionLetter = parts.first;
          imageUrl = parts.last;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (optionLetter.isNotEmpty)
              Text(
                '$optionLetter)',
                style: style.copyWith(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    'Failed to load image',
                    style: style.copyWith(color: Colors.red),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      } else {
        return LatexText(text, textStyle: style);
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
              buildAnswerWidget(
                renderAnswer(userAnswer),
                TextStyle(fontSize: 14, color: colorScheme.onSurface),
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
              buildAnswerWidget(
                renderAnswer(correctAnswer) == 'No answer'
                    ? (correctAnswer?.toString() ?? 'N/A')
                    : renderAnswer(correctAnswer),
                TextStyle(fontSize: 14, color: colorScheme.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderingComparison(
    Map<String, dynamic> result,
    Map<String, dynamic>? question,
    ColorScheme colorScheme,
  ) {
    final detailedResults = _extractList(result['detailedResults']) ?? [];

    // Extract correctOrder from result or from detailedResults
    List<String> correctOrder = [];
    if (result['correctOrder'] != null) {
      correctOrder =
          _extractList(
            result['correctOrder'],
          )?.map((e) => e.toString()).toList() ??
          [];
    } else if (detailedResults.isNotEmpty) {
      // Fallback: extract from detailedResults
      correctOrder = detailedResults
          .map((detail) {
            final detailMap = _extractMap(detail) ?? {};
            return detailMap['correctAnswer']?.toString() ?? '';
          })
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (question != null && question['correctOrder'] != null) {
      correctOrder =
          _extractList(
            question['correctOrder'],
          )?.map((e) => e.toString()).toList() ??
          [];
    } else if (question != null && question['dragTargets'] != null) {
      correctOrder = (_extractList(question['dragTargets']) ?? [])
          .map((detail) => _extractMap(detail)?['id']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    // Extract userOrder from result
    List<String> userOrder = [];
    if (result['userAnswers'] != null) {
      userOrder =
          _extractList(
            result['userAnswers'],
          )?.map((e) => e.toString()).toList() ??
          [];
    } else if (result['userAnswer'] != null) {
      final rawAnswer = result['userAnswer'].toString();
      userOrder = rawAnswer
          .split(',')
          .map((e) => e.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (detailedResults.isNotEmpty) {
      // Fallback: extract from detailedResults
      userOrder = detailedResults
          .map((detail) {
            final detailMap = _extractMap(detail) ?? {};
            return detailMap['userAnswer']?.toString() ?? '';
          })
          .where((s) => s.isNotEmpty)
          .toList();
    }

    // Create a mapping from step IDs to step text for better display
    Map<String, String> stepIdToText = {};
    if (question != null && question['dragItems'] != null) {
      final dragItems = _extractList(question['dragItems']) ?? [];
      for (final item in dragItems) {
        final itemMap = _extractMap(item) ?? {};
        final id = itemMap['id']?.toString();
        final text = itemMap['text']?.toString();
        if (id != null && text != null) {
          stepIdToText[id] = text;
        }
      }
    }

    // Helper function to get step display text
    String getStepDisplayText(String stepId) {
      return stepIdToText[stepId] ?? stepId; // Fallback to ID if text not found
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary boxes
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Order',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 4),
              if (userOrder.isNotEmpty) ...[
                ...userOrder.asMap().entries.map((entry) {
                  final index = entry.key;
                  final stepId = entry.value;
                  final stepText = getStepDisplayText(stepId);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: LatexText(
                      '${index + 1}. $stepText',
                      textStyle: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  );
                }),
              ] else
                Text(
                  'No answer provided',
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Correct Order',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              if (correctOrder.isNotEmpty) ...[
                ...correctOrder.asMap().entries.map((entry) {
                  final index = entry.key;
                  final stepId = entry.value;
                  final stepText = getStepDisplayText(stepId);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: LatexText(
                      '${index + 1}. $stepText',
                      textStyle: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  );
                }),
              ] else
                Text(
                  'N/A',
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
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
                      Row(
                        children: [
                          Text(
                            'Your: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Expanded(
                            child: LatexText(
                              getStepDisplayText(userAnswer),
                              textStyle: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!isCorrect) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Correct: ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(
                              child: LatexText(
                                getStepDisplayText(correctAnswer),
                                textStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // Helpers
  String _normalizeFormat(String? format) {
    final f = (format ?? '').toLowerCase().trim();
    switch (f) {
      case 'mcq':
      case 'multiple':
      case 'multiplechoice':
      case 'multiple_choice':
        return 'mcq';
      case 'short_answer':
      case 'shortanswer':
        return 'short_answer';
      case 'drag_drop':
      case 'draganddrop':
      case 'drag-and-drop':
      case 'drag and drop':
        return 'drag_drop';
      case 'true_false':
      case 'truefalse':
        return 'true_false';
      default:
        return f;
    }
  }

  Widget _buildParentContext(Map<String, dynamic> question) {
    final parent = _extractMap(question['parentContext']) ?? {};
    final text = parent['questionText'];
    if (text == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Context:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          LatexText(
            text.toString(),
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return const SizedBox();
    final item = items[_currentQuestionIndex];
    final q = item['question'] as Map<String, dynamic>?;
    String base = 'Question ${_currentQuestionIndex + 1} of ${items.length}';

    // Only show PQP numbers if in PQP mode
    if (widget.isPQPMode) {
      final pqpNumber = _extractMap(q?['pqpData'])?['questionNumber']?.toString();
      if (pqpNumber != null && pqpNumber.isNotEmpty) {
        base = 'Question $pqpNumber • ${_currentQuestionIndex + 1}/${items.length}';
      }
    }

    return Text(base);
  }

  String _questionLabel(List<Map<String, dynamic>> items, int index) {
    // Only show PQP numbers if in PQP mode
    if (widget.isPQPMode) {
      final q = items[index]['question'] as Map<String, dynamic>?;
      final pqpNumber = _extractMap(q?['pqpData'])?['questionNumber']?.toString();
      if (pqpNumber != null && pqpNumber.isNotEmpty) {
        return pqpNumber;
      }
    }

    // For Sprint/By Topic mode, always use sequential numbering
    return '${index + 1}';
  }
}
