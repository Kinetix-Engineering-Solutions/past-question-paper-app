import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/question.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/viewmodels/practice_viewmodel.dart';
import 'package:past_question_paper_v1/views/practice_results_screen.dart';
import 'package:past_question_paper_v1/widgets/latex_text.dart';
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

  const PracticeScreen({
    super.key,
    required this.questions,
    this.isPQPMode = false,
    this.isSprintMode = false,
  });

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Initialize the ViewModel with the questions for this session
    Future.microtask(
      () => ref
          .read(practiceViewModelProvider.notifier)
          .startSession(widget.questions),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Session cleanup is now handled automatically by autoDispose provider
    // No need to manually call clearSession() here to avoid "ref after dispose" error
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _submitTest() async {
    final viewModel = ref.read(practiceViewModelProvider.notifier);
    final result = await viewModel.submitTest();

    if (result != null && mounted) {
      // Safely cast the grading results
      final gradingResults = result['gradingResults'];
      final questions = result['questions'];

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
      if (questions is List) {
        for (final question in questions) {
          if (question is Map) {
            final Map<String, dynamic> safeQuestion = {};
            question.forEach((key, value) {
              safeQuestion[key.toString()] = value;
            });
            safeQuestions.add(safeQuestion);
          }
        }
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
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit test. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final practiceState = ref.watch(practiceViewModelProvider);
    final questions = practiceState.questions;

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        foregroundColor: AppColors.ink,
        title: Text('Question ${_currentPage + 1} of ${questions.length}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- Progress Bar ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / questions.length,
              backgroundColor: AppColors.neutralBorder,
              color: AppColors.accent,
            ),
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
          _buildBottomControls(questions.length),
        ],
      ),
    );
  }

  Widget _buildBottomControls(int totalQuestions) {
    final isLastPage = _currentPage == totalQuestions - 1;
    final practiceState = ref.watch(practiceViewModelProvider);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- Previous Button ---
          TextButton(
            onPressed: _currentPage == 0
                ? null
                : () {
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
              backgroundColor: isLastPage ? Colors.green : AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: isLastPage
                ? (practiceState.isSubmitting ? null : _submitTest)
                : () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
            child: practiceState.isSubmitting && isLastPage
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white),
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

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- Mode Indicator ---
        if (widget.isPQPMode || widget.isSprintMode)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.isPQPMode
                  ? Colors.blue.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isPQPMode ? Colors.blue : Colors.orange,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isPQPMode
                      ? Icons.assignment_outlined
                      : Icons.flash_on_outlined,
                  size: 16,
                  color: widget.isPQPMode ? Colors.blue : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.isPQPMode ? 'PQP Mode' : 'Sprint Mode',
                  style: TextStyle(
                    color: widget.isPQPMode ? Colors.blue : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        if (widget.isPQPMode || widget.isSprintMode) const SizedBox(height: 12),

        // --- PQP Mode Chain Info ---
        if (widget.isPQPMode && widget.question.isPartOfChain)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question Chain: ${widget.question.pqpData?.questionNumber ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (widget.question.dependencies.isNotEmpty)
                  Text(
                    'Depends on: ${widget.question.dependencies.join(', ')}',
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                  ),
                Text(
                  'Marks: ${widget.question.getPQPMarks()}',
                  style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                ),
              ],
            ),
          ),

        // --- Sprint Mode Context ---
        if (widget.isSprintMode && widget.question.providedContext != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Provided Context:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...widget.question.providedContext!.entries.map(
                  (entry) => Text(
                    '${entry.key}: ${entry.value}',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  'Marks: ${widget.question.getSprintMarks()} | Difficulty: ${widget.question.difficulty ?? 'N/A'}',
                  style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                ),
              ],
            ),
          ),

        if ((widget.isPQPMode && widget.question.isPartOfChain) ||
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
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent, width: 1.5),
              ),
              child: Text(
                '${widget.isPQPMode
                    ? widget.question.getPQPMarks()
                    : widget.isSprintMode
                    ? widget.question.getSprintMarks()
                    : widget.question.marks} marks',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // --- Question Image ---
        if (widget.question.hasQuestionImage)
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.question.imageUrl!,
                fit: BoxFit.contain,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text(
                      'Image failed to load',
                      style: TextStyle(color: Colors.redAccent),
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
                  backgroundColor: Colors.orange.shade100,
                  foregroundColor: Colors.orange.shade700,
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
              color: Colors.yellow.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Hints:',
                      style: TextStyle(fontWeight: FontWeight.bold),
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

    // Try to get hints from the test_questions_firestore.json data
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
    switch (widget.question.format.toLowerCase()) {
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
        return TrueFalseWidget(
          question: widget.question,
          selectedOption: selectedOption,
        );
      case 'short_answer':
      case 'short-answer':
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
