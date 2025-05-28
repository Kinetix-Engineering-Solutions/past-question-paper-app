import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/domain/factories/question_strategy_factory.dart';
import 'package:past_question_paper_stem/domain/providers/drag_and_drop_provider.dart';
import 'package:past_question_paper_stem/domain/strategies/question_strategy.dart';
import 'package:past_question_paper_stem/models/question.dart';

/// Screen to display and interact with a single question using the strategy pattern
class QuestionDetailScreen extends ConsumerStatefulWidget {
  final Question question;
  final Function(bool isCorrect) onSubmit;

  const QuestionDetailScreen({
    super.key,
    required this.question,
    required this.onSubmit,
  });

  @override
  ConsumerState<QuestionDetailScreen> createState() =>
      _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends ConsumerState<QuestionDetailScreen> {
  late QuestionStrategy _strategy;
  late dynamic _userAnswer;
  bool _hasSubmitted = false;
  bool _isCorrect = false;
  bool _showExplanation = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _initializeStrategy();
  }

  void _initializeStrategy() {
    // Get the appropriate strategy for this question type
    _strategy = QuestionStrategyFactory.getStrategy(widget.question);

    // Validate the question
    if (!_strategy.validate(widget.question)) {
      _validationError =
          'This ${widget.question.questionType} question has invalid data.';
    }

    // Initialize the user answer state
    _userAnswer = _strategy.createInitialState(widget.question);
  }

  void _checkAnswer() {
    if (_validationError != null) {
      setState(() {
        _hasSubmitted = true;
        _isCorrect = false;
      });
      widget.onSubmit(false);
      return;
    }

    // Special handling for drag-and-drop questions that use Riverpod
    if (widget.question.questionType.toLowerCase().contains('drag')) {
      // For drag-and-drop questions, the result will be checked by the provider
      // and we'll read the result in the build method
      final provider = ref.read(dragAndDropProvider(widget.question));
      if (provider.hasSubmitted) {
        setState(() {
          _hasSubmitted = true;
          _isCorrect = provider.isCorrect;
          _showExplanation = true;
        });
        widget.onSubmit(provider.isCorrect);
      } else {
        ref.read(dragAndDropProvider(widget.question).notifier).checkAnswer();
        final updatedProvider = ref.read(dragAndDropProvider(widget.question));
        setState(() {
          _hasSubmitted = true;
          _isCorrect = updatedProvider.isCorrect;
          _showExplanation = true;
        });
        widget.onSubmit(updatedProvider.isCorrect);
      }
      return;
    }

    // Standard check for other question types
    final isCorrect = _strategy.checkAnswer(widget.question, _userAnswer);

    setState(() {
      _hasSubmitted = true;
      _isCorrect = isCorrect;
      _showExplanation = true;
    });

    widget.onSubmit(isCorrect);
  }

  void _resetQuestion() {
    // Special handling for drag-and-drop questions that use Riverpod
    if (widget.question.questionType.toLowerCase().contains('drag')) {
      ref.read(dragAndDropProvider(widget.question).notifier).reset();
      setState(() {
        _hasSubmitted = false;
        _showExplanation = false;
      });
      return;
    }

    // Standard reset for other question types
    setState(() {
      _userAnswer = _strategy.createInitialState(widget.question);
      _hasSubmitted = false;
      _showExplanation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.question.questionType,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Question text
            Text(
              widget.question.questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            // Question image if available
            if (widget.question.hasQuestionImage) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.question.questionImage!,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 150,
                      color: Colors.grey[200],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 40, color: Colors.red),
                          SizedBox(height: 8),
                          Text("Failed to load image"),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Show error message if question data is invalid
            if (_validationError != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Question Data Error',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _validationError!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

            // Question content - rendered using the strategy
            if (_validationError == null)
              _strategy.buildQuestionContent(widget.question, context),

            const SizedBox(height: 24),

            // Show explanation if available and requested
            if (_showExplanation) _buildExplanationSection(),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!_hasSubmitted)
                  ElevatedButton(
                    onPressed: _checkAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Submit Answer'),
                  ),

                if (_hasSubmitted)
                  ElevatedButton(
                    onPressed: _resetQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Try Again'),
                  ),

                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showExplanation = !_showExplanation;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    _showExplanation ? 'Hide Explanation' : 'Show Explanation',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationSection() {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      color: _isCorrect ? Colors.green.shade50 : Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _isCorrect ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isCorrect ? Icons.check_circle : Icons.cancel,
                  color: _isCorrect ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  _isCorrect ? 'Correct!' : 'Incorrect',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isCorrect ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Correct Answer:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _strategy.getCorrectAnswerText(widget.question),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Explanation:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.question.explanation,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
