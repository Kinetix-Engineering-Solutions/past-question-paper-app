import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/question.dart';
import 'package:past_question_paper_stem/utils/app_colors.dart';
import 'package:past_question_paper_stem/viewmodels/practice_viewmodel.dart';
import 'package:past_question_paper_stem/views/practice_results_screen.dart';
import 'package:past_question_paper_stem/widgets/latex_text.dart';
import 'package:past_question_paper_stem/widgets/question_formats/mcq_text_widget.dart';
import 'package:past_question_paper_stem/widgets/question_formats/mcq_image_widget.dart';
import 'package:past_question_paper_stem/widgets/question_formats/true_false_widget.dart';
import 'package:past_question_paper_stem/widgets/question_formats/short_answer_widget.dart';
import 'package:past_question_paper_stem/widgets/question_formats/essay_widget.dart';
import 'package:past_question_paper_stem/widgets/question_formats/drag_and_drop_widget.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  final List<Question> questions;

  const PracticeScreen({Key? key, required this.questions}) : super(key: key);

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => PracticeResultsScreen(
                //score: result['score']!,
                //totalMarks: result['totalMarks']!,
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
                return _QuestionView(question: questions[index]);
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
            onPressed:
                _currentPage == 0
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
            onPressed:
                isLastPage
                    ? (practiceState.isSubmitting ? null : _submitTest)
                    : () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
            child:
                practiceState.isSubmitting && isLastPage
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
class _QuestionView extends ConsumerWidget {
  final Question question;

  const _QuestionView({required this.question});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final practiceState = ref.watch(practiceViewModelProvider);
    final selectedOption = practiceState.userAnswers[question.id];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- Question Text with LaTeX ---
        LatexText(question.questionText),
        const SizedBox(height: 16),

        // --- Question Image ---
        if (question.hasQuestionImage)
          Image.network(
            question.imageUrl!,
          ), // Consider using CachedNetworkImage
        const SizedBox(height: 24),

        // --- Render different question formats ---
        _buildQuestionContent(context, ref, selectedOption),
      ],
    );
  }

  Widget _buildQuestionContent(
    BuildContext context,
    WidgetRef ref,
    String? selectedOption,
  ) {
    switch (question.format.toLowerCase()) {
      case 'mcq':
        if (question.hasImageOptions) {
          return MCQImageWidget(
            question: question,
            selectedOption: selectedOption,
          );
        } else {
          return MCQTextWidget(
            question: question,
            selectedOption: selectedOption,
          );
        }
      case 'drag-and-drop':
        return DragAndDropWidget(
          question: question,
          currentAnswers: _parseDragDropAnswer(selectedOption),
        );
      case 'true_false':
      case 'true-false':
        return TrueFalseWidget(
          question: question,
          selectedOption: selectedOption,
        );
      case 'short_answer':
      case 'short-answer':
        return ShortAnswerWidget(
          question: question,
          initialAnswer: selectedOption,
        );
      case 'essay':
        return EssayWidget(question: question, initialAnswer: selectedOption);
      default:
        return MCQTextWidget(
          question: question,
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
