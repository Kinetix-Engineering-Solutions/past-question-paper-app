import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/practice_session.dart';
import 'package:past_question_paper_stem/utils/app_colors.dart';
import 'package:past_question_paper_stem/widgets/drag_and_drop/drag_item_card.dart';
import 'package:past_question_paper_stem/widgets/drag_and_drop/drop_target_slot.dart';
import 'package:past_question_paper_stem/widgets/latex_text.dart';
import 'package:past_question_paper_stem/model/question.dart';
import 'package:past_question_paper_stem/viewmodels/practice_viewmodel.dart';
import 'package:past_question_paper_stem/views/practice_results_screen.dart';

class PracticeSessionScreen extends ConsumerStatefulWidget {
  const PracticeSessionScreen({super.key});

  @override
  ConsumerState<PracticeSessionScreen> createState() =>
      _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends ConsumerState<PracticeSessionScreen> {
  String? selectedAnswer; // For multiple-choice and true-false questions
  String?
  selectedDragItemId; // For tracking selected drag item in drag-and-drop
  List<String>? dragAndDropAnswer; // For drag and drop answers
  late Map<String, String> dragAndDropPairs; // For tracking drag and drop pairs

  @override
  void initState() {
    super.initState();
    dragAndDropPairs = <String, String>{};
  }

  @override
  Widget build(BuildContext context) {
    final practiceState = ref.watch(practiceViewModelProvider);
    final practiceViewModel = ref.read(practiceViewModelProvider.notifier);

    // Listen for session completion and navigate to results
    ref.listen(practiceViewModelProvider, (previous, current) {
      if (current.showResults && current.currentSession != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const PracticeResultsScreen(),
          ),
        );
      }
    });

    final session = practiceState.currentSession;
    if (session == null) {
      return const Scaffold(
        body: Center(child: Text('No active practice session')),
      );
    }

    final currentQuestion = session.currentQuestion;
    if (currentQuestion == null) {
      return const Scaffold(body: Center(child: Text('No current question')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(session.topic.name),
        centerTitle: true,
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.neutralCard,
        leading: IconButton(
          icon: const Icon(Icons.pause),
          onPressed: () => _showPauseDialog(practiceViewModel),
        ),
        actions: [
          if (session.mode.isTimeLimited)
            _buildTimerDisplay(practiceState.remainingTime),
        ],
      ),
      body: Column(
        children: [
          _buildProgressBar(session),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionInfo(session),
                  const SizedBox(height: 24),
                  _buildQuestionCard(currentQuestion),
                  const SizedBox(height: 24),
                  _buildAnswerOptions(currentQuestion),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildNavigationButtons(session, practiceViewModel),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(Duration? remainingTime) {
    if (remainingTime == null) return const SizedBox.shrink();

    final minutes = remainingTime.inMinutes;
    final seconds = remainingTime.inSeconds % 60;
    final isUrgent = remainingTime.inMinutes < 2;

    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.red.shade100 : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isUrgent ? Colors.red.shade700 : Colors.white,
        ),
      ),
    );
  }

  Widget _buildProgressBar(PracticeSession session) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${session.currentQuestionIndex + 1} of ${session.questions.length}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${(session.progress * 100).round()}% Complete',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: session.progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionInfo(PracticeSession session) {
    return const SizedBox.shrink(); // Remove all chips for cleaner UI
  }

  Widget _buildQuestionCard(Question question) {
    return Padding(
      // Remove Card container for cleaner look
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LatexText(
            question.questionText,
            fontSize: 18,
            textStyle: const TextStyle(height: 1.3),
          ),
          if (question.hasQuestionImage) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                question.questionImage!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(Question question) {
    switch (question.questionType.toLowerCase()) {
      case 'multiple-choice':
      case 'true-false':
        return _buildMultipleChoiceOptions(question);
      case 'drag-and-drop':
        return _buildDragAndDropOptions(question);
      default:
        return const Text('Unsupported question type');
    }
  }

  Widget _buildMultipleChoiceOptions(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select your answer:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...question.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final optionLabel = String.fromCharCode(65 + index); // A, B, C, D...
          final isSelected = selectedAnswer == option;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Card(
              elevation: isSelected ? 3 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? AppColors.accent : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: InkWell(
                onTap: () => _selectAnswer(option),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.accent
                                  : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            optionLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected
                                      ? AppColors.neutralCard
                                      : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: LatexText(
                          option,
                          fontSize: 16,
                          textColor:
                              isSelected ? AppColors.accent : AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDragAndDropOptions(Question question) {
    if (!question.isDragAndDrop || !question.hasDragDropData) {
      return const Text(
        'Invalid drag and drop question data',
        style: TextStyle(color: Colors.red),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Drag items to the correct targets:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        // Drag Items Section
        const Text(
          'Items to Drag:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              question.dragItems!.map((dragItem) {
                final isUsed = dragAndDropPairs.containsValue(dragItem.id);
                return _buildDragItem(dragItem, isUsed);
              }).toList(),
        ),

        const SizedBox(height: 24),

        // Drop Targets Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Drop Targets:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children:
                    question.dragTargets!.map((dropTarget) {
                      return _buildDropTarget(question, dropTarget);
                    }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Instructions
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tap a blue item, then tap a green target to make a match',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDragItem(dynamic dragItem, bool isUsed) {
    return DragItemCard(
      dragItem: dragItem,
      isUsed: isUsed,
      selectedAnswerId: selectedDragItemId,
      onTap: _selectDragItem,
    );
  }

  Widget _buildDropTarget(Question question, dynamic dropTarget) {
    final dragItemId = dragAndDropPairs[dropTarget.id];
    final dragItem =
        dragItemId != null
            ? question.dragItems!
                .where((item) => item.id == dragItemId)
                .firstOrNull
            : null;

    return DropTargetSlot(
      dropTarget: dropTarget,
      dragItem: dragItem,
      onTap: _selectDropTarget,
      onRemove: _removePair,
    );
  }

  Widget _buildNavigationButtons(
    PracticeSession session,
    PracticeViewModel viewModel,
  ) {
    final currentQuestion = session.currentQuestion;
    final canProceed = _canProceedToNext(currentQuestion);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          if (session.currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _resetAnswerState();
                  viewModel.previousQuestion();
                },
                child: const Text('Previous'),
              ),
            ),
          if (session.currentQuestionIndex > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: canProceed ? () => _nextQuestion(viewModel) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.neutralCard,
              ),
              child: Text(session.isLastQuestion ? 'Finish' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceedToNext(Question? currentQuestion) {
    if (currentQuestion == null) return false;

    if (currentQuestion.isDragAndDrop && currentQuestion.hasDragDropData) {
      // For drag and drop, check if all targets have been paired
      return dragAndDropPairs.length == currentQuestion.dragTargets!.length;
    } else {
      // For other question types, check if an answer is selected
      return selectedAnswer != null;
    }
  }

  void _resetAnswerState() {
    setState(() {
      selectedAnswer = null;
      selectedDragItemId = null;
      dragAndDropAnswer = null;
      dragAndDropPairs = <String, String>{};
    });
  }

  void _selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
    });
  }

  void _selectDragItem(String dragItemId) {
    setState(() {
      selectedDragItemId = dragItemId;
    });
  }

  void _selectDropTarget(String dropTargetId) {
    if (selectedDragItemId != null) {
      setState(() {
        // Remove any existing pair for this drop target
        dragAndDropPairs.removeWhere((key, value) => key == dropTargetId);
        // Remove any existing pair for this drag item
        dragAndDropPairs.removeWhere(
          (key, value) => value == selectedDragItemId,
        );
        // Create new pair
        dragAndDropPairs[dropTargetId] = selectedDragItemId!;
        selectedDragItemId = null; // Clear selection
      });

      // Update the practice session with current pairs
      _updateDragDropAnswer();
    }
  }

  void _removePair(String dropTargetId) {
    setState(() {
      dragAndDropPairs.remove(dropTargetId);
    });
    _updateDragDropAnswer();
  }

  void _updateDragDropAnswer() {
    // Convert pairs to answer format
    final answerList =
        dragAndDropPairs.entries
            .map((entry) => '${entry.value}->${entry.key}')
            .toList();

    dragAndDropAnswer = answerList;

    // Submit answer to practice viewmodel if all pairs are made
    final practiceState = ref.read(practiceViewModelProvider);
    final currentQuestion = practiceState.currentQuestion;

    if (currentQuestion != null &&
        currentQuestion.isDragAndDrop &&
        currentQuestion.hasDragDropData &&
        dragAndDropPairs.length == currentQuestion.dragTargets!.length) {
      // All targets have been paired, submit answer
      ref.read(practiceViewModelProvider.notifier).answerQuestion(answerList);
    }
  }

  void _nextQuestion(PracticeViewModel viewModel) {
    final practiceState = ref.read(practiceViewModelProvider);
    final currentQuestion = practiceState.currentQuestion;

    if (currentQuestion != null) {
      if (currentQuestion.isDragAndDrop && currentQuestion.hasDragDropData) {
        // For drag and drop, the answer is already submitted in _updateDragDropAnswer
        // Just move to next question
      } else if (selectedAnswer != null) {
        // For other question types, submit the selected answer
        viewModel.answerQuestion(selectedAnswer);
      }
    }

    viewModel.nextQuestion();
    _resetAnswerState();
  }

  void _showPauseDialog(PracticeViewModel viewModel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pause Practice'),
          content: const Text('Do you want to pause this practice session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue'),
            ),
            TextButton(
              onPressed: () {
                viewModel.pauseSession();
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to topic screen
              },
              child: const Text('Pause'),
            ),
          ],
        );
      },
    );
  }
}
