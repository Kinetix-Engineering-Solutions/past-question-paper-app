import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'package:past_question_paper_v1/utils/haptic_feedback.dart';
import 'package:past_question_paper_v1/viewmodels/practice_viewmodel.dart';
import 'package:past_question_paper_v1/views/practice_results_screen.dart';
import 'package:past_question_paper_v1/widgets/latex_text.dart';
import 'package:past_question_paper_v1/widgets/parent_question_context_card.dart';
import 'package:past_question_paper_v1/widgets/question_formats/mcq_text_widget.dart';
import 'package:past_question_paper_v1/widgets/question_formats/mcq_image_widget.dart';
import 'package:past_question_paper_v1/widgets/question_formats/true_false_widget.dart';
import 'package:past_question_paper_v1/widgets/question_formats/short_answer_widget.dart';
import 'package:past_question_paper_v1/widgets/question_formats/essay_widget.dart';
import 'package:past_question_paper_v1/widgets/question_formats/drag_and_drop_widget.dart';
import 'package:past_question_paper_v1/widgets/question_formats/drag_and_drop_ordering_widget.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  final List<Question> questions;
  final bool isPQPMode;
  final bool isSprintMode;
  final String? modeKey;
  final int? configuredDurationMinutes;
  final Map<String, dynamic>? sessionMetadata;
  final Color? topicColor;

  const PracticeScreen({
    super.key,
    required this.questions,
    this.isPQPMode = false,
    this.isSprintMode = false,
    this.modeKey,
    this.configuredDurationMinutes,
    this.sessionMetadata,
    this.topicColor,
  });

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  late final PageController _pageController;
  late final ScrollController _navigatorScrollController;
  int _currentPage = 0;
  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _navigatorScrollController = ScrollController();

    // Initialize countdown timer if duration is configured
    if (widget.configuredDurationMinutes != null) {
      _remainingSeconds = widget.configuredDurationMinutes! * 60;
      _startCountdownTimer();
    }

    // Initialize the ViewModel with the questions for this session
    Future.microtask(
      () => ref
          .read(practiceViewModelProvider.notifier)
          .startSession(
            widget.questions,
            isPQPMode: widget.isPQPMode,
            isSprintMode: widget.isSprintMode,
            durationMinutes: widget.configuredDurationMinutes,
            modeKey: widget.modeKey,
            sessionMetadata: widget.sessionMetadata,
          ),
    );
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
          // Auto-submit when time expires
          _submitTest();
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pageController.dispose();
    _navigatorScrollController.dispose();
    // Session cleanup is now handled automatically by autoDispose provider
    // No need to manually call clearSession() here to avoid "ref after dispose" error
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _scrollNavigatorToCurrentPage();
  }

  void _scrollNavigatorToCurrentPage() {
    if (!_navigatorScrollController.hasClients) return;

    // Calculate the position to scroll to
    // Each item is ~52 (minWidth 44 + padding) + 8 (separator)
    const itemWidth = 52.0 + 8.0;
    final targetOffset = (_currentPage * itemWidth) - 100; // Center the item

    // Clamp the offset to valid scroll range
    final maxScroll = _navigatorScrollController.position.maxScrollExtent;
    final scrollTo = targetOffset.clamp(0.0, maxScroll);

    _navigatorScrollController.animateTo(
      scrollTo,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _submitTest() async {
    final viewModel = ref.read(practiceViewModelProvider.notifier);
    final result = await viewModel.submitTest();

    if (result != null && mounted) {
      // Safely cast the grading results
      final gradingResults = result['gradingResults'];
      // Note: questions come from widget.questions, not from grading result

      // Convert to proper types with null safety
      final Map<String, dynamic> safeGradingResults = {};
      if (gradingResults != null) {
        if (gradingResults is Map) {
          gradingResults.forEach((key, value) {
            safeGradingResults[key.toString()] = value;
          });
        }
      }

      final List<Map<String, dynamic>> safeQuestions = [];
      // Use the original questions from widget.questions instead of result['questions']
      // because grading result doesn't contain question data - only grading results
      for (final question in widget.questions) {
        final Map<String, dynamic> safeQuestion = {};

        // Convert Question object to Map, preserving all essential fields including ID
        safeQuestion['id'] = question.id;
        safeQuestion['questionText'] = question.questionText;
        safeQuestion['format'] = question.format;
        safeQuestion['questionType'] = question.questionType;
        safeQuestion['subject'] = question.subject;
        safeQuestion['paper'] = question.paper;
        safeQuestion['grade'] = question.grade;
        safeQuestion['topic'] = question.topic;
        safeQuestion['cognitiveLevel'] = question.cognitiveLevel;
        safeQuestion['marks'] = question.marks;
        safeQuestion['year'] = question.year;
        safeQuestion['season'] = question.season;
        safeQuestion['correctOrder'] = question.correctOrder;
        safeQuestion['correctAnswer'] = question.correctAnswer;
        safeQuestion['explanation'] = question.explanation;
        safeQuestion['options'] = question.options;
        safeQuestion['imageUrl'] = question.imageUrl;

        // Handle complex objects - convert to simple maps
        if (question.pqpData != null) {
          safeQuestion['pqpData'] = {
            'questionNumber': question.pqpData!.questionNumber,
            'marks': question.pqpData!.marks,
            'questionText': question.pqpData!.questionText,
          };
        }

        if (question.sprintData != null) {
          safeQuestion['sprintData'] = {
            'questionText': question.sprintData!.questionText,
            'marks': question.sprintData!.marks,
            'difficulty': question.sprintData!.difficulty,
          };
        }

        if (question.parentContext != null) {
          safeQuestion['parentContext'] = question.parentContext;
        }

        // IMPORTANT: For drag-and-drop questions, preserve dragItems for step text mapping
        if (question.dragItems != null) {
          safeQuestion['dragItems'] = question.dragItems!
              .map((item) => {'id': item.id, 'text': item.text})
              .toList();
        }

        safeQuestions.add(safeQuestion);
      }

      // Clear session before navigation to prevent stale data
      if (mounted) {
        viewModel.clearSession();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PracticeResultsScreen(
            gradingResults: safeGradingResults,
            questions: safeQuestions,
            isPQPMode: widget.isPQPMode,
            isSprintMode: widget.isSprintMode,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to submit test. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  /// Builds the timer display widget for timed practice modes
  Widget _buildTimerDisplay(ColorScheme colorScheme) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Change color to warning when less than 5 minutes remain
    final isWarning = _remainingSeconds < 300; // 5 minutes
    final isCritical = _remainingSeconds < 60; // 1 minute

    Color timerColor;
    if (isCritical) {
      timerColor = Colors.red;
    } else if (isWarning) {
      timerColor = Colors.orange;
    } else {
      timerColor = widget.topicColor ?? colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: timerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: timerColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: timerColor, size: 18),
          const SizedBox(width: 6),
          Text(
            timeString,
            style: TextStyle(
              color: timerColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Gets the appropriate question title based on mode and question data
  String _getQuestionTitle(PracticeState practiceState) {
    final questions = practiceState.questions;
    if (questions.isEmpty) return 'Question';

    final question = questions[_currentPage];

    if (widget.isPQPMode) {
      final sequentialNumber = practiceState.pqpDisplayNumbers[question.id];
      final totalQuestions = questions.length;

      if (sequentialNumber != null) {
        final examNumber = question.pqpData?.questionNumber;
        if (examNumber != null && examNumber.isNotEmpty) {
          return 'Question $sequentialNumber of $totalQuestions • PQP $examNumber';
        }
        return 'Question $sequentialNumber of $totalQuestions';
      }
    }

    // Sprint/Regular Mode: Show sequential numbering with total count
    return 'Question ${_currentPage + 1} of ${questions.length}';
  }

  @override
  Widget build(BuildContext context) {
    final practiceState = ref.watch(practiceViewModelProvider);
    final questions = practiceState.questions;
    final colorScheme = Theme.of(context).colorScheme;

    if (questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: widget.topicColor ?? colorScheme.background,
        elevation: 0,
        foregroundColor: widget.topicColor != null
            ? Colors.white
            : colorScheme.onBackground,
        title: Text(_getQuestionTitle(practiceState)),
        centerTitle: true,
        actions: widget.configuredDurationMinutes != null
            ? [_buildTimerDisplay(colorScheme), const SizedBox(width: 16)]
            : null,
      ),
      body: Column(
        children: [
          // --- Progress Bar ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / questions.length,
              backgroundColor: colorScheme.outlineVariant,
              color: widget.topicColor ?? colorScheme.primary,
            ),
          ),

          if (questions.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: _buildQuickNavigator(practiceState),
            ),

          // --- Question Content ---
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: questions.length,
              itemBuilder: (context, index) {
                return _QuestionView(
                  question: questions[index],
                  isSprintMode: widget.isSprintMode,
                  isPQPMode: widget.isPQPMode,
                );
              },
            ),
          ),

          // --- Navigation Controls ---
          _buildBottomControls(context, questions.length),
        ],
      ),
    );
  }

  Widget _buildQuickNavigator(PracticeState practiceState) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = practiceState.questions.length;

    return SizedBox(
      height: 52,
      child: ListView.separated(
        controller: _navigatorScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: total,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final question = practiceState.questions[index];
          final isCurrent = index == _currentPage;
          final isAnswered =
              practiceState.userAnswers.containsKey(question.id) &&
              (practiceState.userAnswers[question.id]?.toString().isNotEmpty ??
                  false);

          final sequentialLabel = '${index + 1}';
          final sequentialNumber =
              practiceState.pqpDisplayNumbers[question.id] ?? (index + 1);
          final examNumber = question.pqpData?.questionNumber;
          final displayLabel = widget.isPQPMode
              ? (examNumber != null && examNumber.isNotEmpty
                    ? examNumber
                    : '$sequentialNumber')
              : sequentialLabel;

          final backgroundColor = isCurrent
              ? colorScheme.primary
              : isAnswered
              ? colorScheme.secondaryContainer
              : colorScheme.surfaceVariant;

          final foregroundColor = isCurrent
              ? colorScheme.onPrimary
              : isAnswered
              ? colorScheme.onSecondaryContainer
              : colorScheme.onSurfaceVariant;

          return GestureDetector(
            onTap: () {
              AppHaptics.selection();
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              constraints: const BoxConstraints(minWidth: 44),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrent
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  width: isCurrent ? 1.5 : 1,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  displayLabel,
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, int totalQuestions) {
    final isLastPage = _currentPage == totalQuestions - 1;
    final practiceState = ref.watch(practiceViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0 + bottomPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- Previous Button ---
          TextButton(
            onPressed: _currentPage == 0
                ? null
                : () {
                    AppHaptics.light();
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
            child: const Text('Previous'),
          ),

          // --- Next / Submit Button ---
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: isLastPage
                ? (practiceState.isSubmitting
                      ? null
                      : () {
                          AppHaptics.medium();
                          _submitTest();
                        })
                : () {
                    AppHaptics.light();
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
            child: practiceState.isSubmitting && isLastPage
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(isLastPage ? 'Submit Test' : 'Next'),
          ),
        ],
      ),
    );
  }
}

// --- Widget to Display a Single Question ---
class _QuestionView extends ConsumerStatefulWidget {
  final Question question;
  final bool isSprintMode;
  final bool isPQPMode;

  const _QuestionView({
    required this.question,
    this.isSprintMode = false,
    this.isPQPMode = false,
  });

  @override
  ConsumerState<_QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends ConsumerState<_QuestionView> {
  bool _showHints = false;

  @override
  Widget build(BuildContext context) {
    final practiceState = ref.watch(practiceViewModelProvider);
    final selectedOption = practiceState.userAnswers[widget.question.id];
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- Option 3: Parent Question Context (NEW) ---
        ParentQuestionContextCard(question: widget.question),

        // --- Sprint Mode Context ---
        if (widget.isSprintMode && widget.question.providedContext != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Provided Context:',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...widget.question.providedContext!.entries.map(
                  (entry) => Text(
                    '${entry.key}: ${entry.value}',
                    style: TextStyle(color: colorScheme.primary, fontSize: 12),
                  ),
                ),
                Text(
                  'Marks: ${widget.question.getSprintMarks()} | Difficulty: ${widget.question.difficulty ?? 'N/A'}',
                  style: TextStyle(color: colorScheme.primary, fontSize: 12),
                ),
              ],
            ),
          ),

        if ((widget.isPQPMode && widget.question.hasParent) ||
            (widget.isSprintMode && widget.question.providedContext != null))
          const SizedBox(height: 16),

        // --- Question Text with LaTeX and Marks ---
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LatexText(
                widget.isPQPMode
                    ? widget.question.getPQPQuestionText()
                    : widget.isSprintMode
                    ? widget.question.getSprintQuestionText()
                    : widget.question.questionText,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${widget.isPQPMode
                    ? widget.question.getPQPMarks()
                    : widget.isSprintMode
                    ? widget.question.getSprintMarks()
                    : widget.question.marks} marks',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // --- Question Image (Option 3: supports inherited images) ---
        // Only show image if:
        // 1. Question has its own unique image (not inherited from parent), OR
        // 2. Question has no parent (standalone question with image)
        if ((widget.question.hasQuestionImage &&
                !widget.question.usesParentImage) ||
            (widget.question.displayImageUrl != null &&
                !widget.question.hasParent))
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.question.displayImageUrl ?? widget.question.imageUrl!,
                fit: BoxFit.contain,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      'Image failed to load',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  );
                },
              ),
            ),
          ),
        const SizedBox(height: 24),

        // --- Sprint Mode Hint Button ---
        if (widget.isSprintMode)
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showHints = !_showHints;
                  });
                },
                icon: Icon(
                  _showHints ? Icons.visibility_off : Icons.lightbulb_outline,
                ),
                label: Text(_showHints ? 'Hide Hints' : 'Show Hints'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary.withOpacity(0.12),
                  foregroundColor: colorScheme.primary,
                ),
              ),
            ],
          ),

        // --- Hints Display (Sprint Mode) ---
        if (widget.isSprintMode && _showHints)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Hints:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_getHintsForQuestion().isNotEmpty)
                  ...(_getHintsForQuestion().asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${entry.key + 1}. ${entry.value}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ))
                else
                  const Text(
                    'No hints available for this question.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // --- Render different question formats ---
        _buildQuestionContent(context, ref, selectedOption),
      ],
    );
  }

  List<String> _getHintsForQuestion() {
    final hints = <String>[];

    // Try to get hints from the question data
    // We'll need to enhance the Question model to support hints
    // For now, provide meaningful hints based on question content and type

    if (widget.question.format.toLowerCase().contains('short')) {
      // Enhanced hints for short answer questions
      if (widget.question.questionText.toLowerCase().contains('equation')) {
        hints.addAll([
          'Substitute the given function into the transformation equation',
          'Simplify by combining like terms',
          'Write your final answer in the form g(x) = ...',
        ]);
      } else if (widget.question.questionText.toLowerCase().contains(
        'domain',
      )) {
        hints.addAll([
          'Remember: Domain of inverse = Range of original function',
          'Consider what values the exponential function can produce',
          'Use interval notation (0; ∞) for your answer',
        ]);
      } else if (widget.question.questionText.toLowerCase().contains(
        'derivative',
      )) {
        hints.addAll([
          'Identify the outer and inner functions',
          'Apply the chain rule: d/dx[g(h(x))] = g\'(h(x)) × h\'(x)',
          'Don\'t forget to differentiate the inner function',
        ]);
      } else {
        hints.addAll([
          'Read the question carefully and identify what is being asked',
          'Look for key mathematical terms and operations',
          'Show your working step by step',
        ]);
      }
    } else if (widget.question.format.toLowerCase() == 'mcq') {
      hints.addAll([
        'Eliminate obviously wrong answers first',
        'Look for clues in the question wording',
        'Consider each option carefully',
        'Check your answer by substituting back into the original',
      ]);
    } else if (widget.question.format.toLowerCase().contains('true')) {
      hints.addAll([
        'Consider trigonometric identities you know',
        'Think about fundamental mathematical relationships',
        'Remember basic properties of the functions involved',
      ]);
    } else {
      hints.addAll([
        'Take your time to understand the question',
        'Use the provided context to guide your answer',
        'Break the problem down into smaller steps',
      ]);
    }

    return hints;
  }

  Widget _buildQuestionContent(
    BuildContext context,
    WidgetRef ref,
    String? selectedOption,
  ) {
    final format = widget.question.format.toLowerCase();
    switch (format) {
      case 'mcq':
        if (widget.question.hasImageOptions) {
          return MCQImageWidget(
            question: widget.question,
            selectedOption: selectedOption,
          );
        } else {
          return MCQTextWidget(
            question: widget.question,
            selectedOption: selectedOption,
          );
        }
      case 'draganddrop':
      case 'drag_drop':
      case 'drag-and-drop':
      case 'drag and drop':
        // Check if this is ordering format (has correctOrder) or matching format
        if (widget.question.correctOrder.isNotEmpty) {
          return DragAndDropOrderingWidget(
            question: widget.question,
            currentAnswer: selectedOption,
          );
        } else {
          return DragAndDropWidget(
            question: widget.question,
            currentAnswers: _parseDragDropAnswer(selectedOption),
          );
        }
      case 'true_false':
      case 'true-false':
      case 'true false':
        return TrueFalseWidget(
          question: widget.question,
          selectedOption: selectedOption,
        );
      case 'short_answer':
      case 'short-answer':
      case 'short answer':
        return ShortAnswerWidget(
          question: widget.question,
          initialAnswer: selectedOption,
        );
      case 'essay':
        return EssayWidget(
          question: widget.question,
          initialAnswer: selectedOption,
        );
      default:
        return MCQTextWidget(
          question: widget.question,
          selectedOption: selectedOption,
        );
    }
  }

  Map<String, String>? _parseDragDropAnswer(String? answerString) {
    if (answerString == null || answerString.isEmpty) return null;

    final Map<String, String> result = {};
    final pairs = answerString.split(',');

    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        result[parts[0]] = parts[1];
      }
    }

    return result.isNotEmpty ? result : null;
  }
}
