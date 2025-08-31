import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/question.dart';
import 'package:past_question_paper_stem/utils/app_colors.dart';
import 'package:past_question_paper_stem/viewmodels/practice_viewmodel.dart';
import 'package:past_question_paper_stem/views/practice_results_screen.dart';
import 'package:past_question_paper_stem/widgets/latex_text.dart'; // Assuming you have a LaTeX widget

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

  Widget _buildQuestionContent(BuildContext context, WidgetRef ref, String? selectedOption) {
    switch (question.format.toLowerCase()) {
      case 'mcq':
        return _buildMCQOptions(ref, selectedOption);
      case 'drag-and-drop':
        return _buildDragAndDropOptions(ref);
      case 'true_false':
        return _buildTrueFalseOptions(ref, selectedOption);
      case 'short_answer':
        return _buildShortAnswerInput(ref);
      case 'essay':
        return _buildEssayInput(ref);
      default:
        return _buildMCQOptions(ref, selectedOption); // Default to MCQ
    }
  }

  // MCQ Options (Current implementation)
  Widget _buildMCQOptions(WidgetRef ref, String? selectedOption) {
    // Handle image options vs text options
    if (question.hasImageOptions) {
      return _buildImageOptions(ref, selectedOption);
    } else {
      return _buildTextOptions(ref, selectedOption);
    }
  }

  // Text-based MCQ options
  Widget _buildTextOptions(WidgetRef ref, String? selectedOption) {
    return Column(
      children: question.options.map((option) {
        final isSelected = selectedOption == option;
        return Card(
          color: isSelected ? AppColors.accentSoft : AppColors.neutralCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppColors.accent : AppColors.neutralBorder,
              width: 1.5,
            ),
          ),
          child: ListTile(
            title: LatexText(option),
            onTap: () {
              ref
                  .read(practiceViewModelProvider.notifier)
                  .answerQuestion(question.id, option);
            },
          ),
        );
      }).toList(),
    );
  }

  // Image-based MCQ options
  Widget _buildImageOptions(WidgetRef ref, String? selectedOption) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: question.optionImages?.length ?? 0,
      itemBuilder: (context, index) {
        final imageUrl = question.optionImages![index];
        final isSelected = selectedOption == imageUrl;
        
        return GestureDetector(
          onTap: () {
            ref
                .read(practiceViewModelProvider.notifier)
                .answerQuestion(question.id, imageUrl);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.neutralBorder,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  // True/False options
  Widget _buildTrueFalseOptions(WidgetRef ref, String? selectedOption) {
    return Row(
      children: [
        Expanded(
          child: _buildOptionButton(ref, 'True', selectedOption == 'True'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOptionButton(ref, 'False', selectedOption == 'False'),
        ),
      ],
    );
  }

  Widget _buildOptionButton(WidgetRef ref, String option, bool isSelected) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.accent : AppColors.neutralCard,
        foregroundColor: isSelected ? Colors.white : AppColors.ink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: () {
        ref
            .read(practiceViewModelProvider.notifier)
            .answerQuestion(question.id, option);
      },
      child: Text(option, style: const TextStyle(fontSize: 18)),
    );
  }

  // Short answer input
  Widget _buildShortAnswerInput(WidgetRef ref) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Enter your answer here...',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        ref
            .read(practiceViewModelProvider.notifier)
            .answerQuestion(question.id, value);
      },
    );
  }

  // Essay input
  Widget _buildEssayInput(WidgetRef ref) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Write your essay here...',
        border: OutlineInputBorder(),
      ),
      maxLines: 8,
      onChanged: (value) {
        ref
            .read(practiceViewModelProvider.notifier)
            .answerQuestion(question.id, value);
      },
    );
  }

  // Drag and drop (placeholder - would need more complex implementation)
  Widget _buildDragAndDropOptions(WidgetRef ref) {
    if (!question.isValidDragAndDrop) {
      return const Text('Invalid drag and drop question');
    }
    
    // This would need a more complex drag-and-drop UI implementation
    return const Center(
      child: Text(
        'Drag and Drop questions coming soon!',
        style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
      ),
    );
  }
}
