import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/drag_and_drop%20models/drag_and_drop_question.dart';
import 'package:past_question_paper_stem/providers/drag_drop_question_provider.dart';
import 'package:past_question_paper_stem/widgets/drag-and-drop%20widgets/drag_item_widget.dart';
import 'package:past_question_paper_stem/widgets/drag-and-drop%20widgets/drop_target_widget.dart';

class DragDropQuestionWidget extends ConsumerWidget {
  final DragDropQuestion question;
  final VoidCallback? onNextQuestion;
  final bool isLastQuestion;

  const DragDropQuestionWidget({
    super.key,
    required this.question,
    this.onNextQuestion,
    this.isLastQuestion = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(
      dragDropQuizViewModelProvider(question).notifier,
    );
    final state = ref.watch(dragDropQuizViewModelProvider(question));

    // Show error messages
    ref.listen(dragDropQuizViewModelProvider(question), (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.orange),
        );
        // Clear error after showing
        Future.microtask(() => viewModel.clearError());
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Drag & Drop Question'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question Text
            if (question.questionText != null) ...[
              _QuestionTextWidget(questionText: question.questionText!),
              SizedBox(height: 24),
            ],

            // Instructions
            _InstructionsWidget(),
            SizedBox(height: 24),

            // Drag items section
            _DragItemsSection(availableDragItems: viewModel.availableDragItems),
            SizedBox(height: 32),

            // Drop targets section
            Expanded(
              child: _DropTargetsSection(
                question: question,
                viewModel: viewModel,
                state: state,
              ),
            ),

            // Action buttons
            SizedBox(height: 16),
            _ActionButtonsSection(
              isSubmitted: state.isSubmitted,
              allTargetsFilled: viewModel.allTargetsFilled,
              isLastQuestion: isLastQuestion,
              onSubmit: () => _handleSubmit(context, viewModel),
              onReset: viewModel.resetQuiz,
              onNext: onNextQuestion,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit(BuildContext context, DragDropQuizViewModel viewModel) {
    final result = viewModel.submitAnswers();

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.isPerfectScore ? Colors.green : Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

// Question Text Widget
class _QuestionTextWidget extends StatelessWidget {
  final String questionText;

  const _QuestionTextWidget({required this.questionText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        questionText,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Instructions Widget
class _InstructionsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        'Drag the items below to their correct targets',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.blue.shade800,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Drag Items Section
class _DragItemsSection extends StatelessWidget {
  final List availableDragItems;

  const _DragItemsSection({required this.availableDragItems});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Drag Items:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child:
              availableDragItems.isEmpty
                  ? Container(
                    height: 60,
                    child: Center(
                      child: Text(
                        'All items have been placed!',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                  : Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children:
                        availableDragItems.map((item) {
                          return Draggable<String>(
                            data: item.id,
                            feedback: Material(
                              color: Colors.transparent,
                              child: Transform.scale(
                                scale: 1.1,
                                child: DragItemWidget(
                                  item: item,
                                  isBeingDragged: true,
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: DragItemWidget(item: item),
                            ),
                            child: DragItemWidget(item: item),
                          );
                        }).toList(),
                  ),
        ),
      ],
    );
  }
}

// Drop Targets Section
class _DropTargetsSection extends ConsumerWidget {
  final DragDropQuestion question;
  final DragDropQuizViewModel viewModel;
  final DragDropQuizState state;

  const _DropTargetsSection({
    required this.question,
    required this.viewModel,
    required this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Drop Targets:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 12),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children:
                  question.dropTargets.map((target) {
                    final placedItem = viewModel.getDragItemOnTarget(target.id);
                    final isCorrect = viewModel.isTargetCorrect(target.id);
                    final isIncorrect = viewModel.isTargetIncorrect(target.id);

                    return DragTarget<String>(
                      builder: (context, candidateData, rejectedData) {
                        final isHovering = candidateData.isNotEmpty;

                        return DropTargetWidget(
                          target: target,
                          placedItem: placedItem,
                          isCorrect: isCorrect,
                          isIncorrect: isIncorrect,
                          isHovering: isHovering,
                          onRemoveItem:
                              () => viewModel.removeDragItem(target.id),
                        );
                      },
                      onWillAccept: (data) => true,
                      onAccept: (dragId) {
                        viewModel.placeDragItem(target.id, dragId);
                      },
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// Action Buttons Section
class _ActionButtonsSection extends StatelessWidget {
  final bool isSubmitted;
  final bool allTargetsFilled;
  final bool isLastQuestion;
  final VoidCallback onSubmit;
  final VoidCallback onReset;
  final VoidCallback? onNext;

  const _ActionButtonsSection({
    required this.isSubmitted,
    required this.allTargetsFilled,
    required this.isLastQuestion,
    required this.onSubmit,
    required this.onReset,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSubmitted) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: allTargetsFilled ? onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Submit Answers',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(width: 12),
          ElevatedButton(
            onPressed: onReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
            child: Text('Reset'),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              isLastQuestion ? 'Finish Quiz' : 'Next Question',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(width: 12),
        ElevatedButton(
          onPressed: onReset,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade600,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          child: Text('Try Again'),
        ),
      ],
    );
  }
}
