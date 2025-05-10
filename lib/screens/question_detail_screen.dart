import 'package:flutter/material.dart';
import 'package:past_question_paper_stem/models/question.dart';
import 'dart:math';

class QuestionDetailScreen extends StatefulWidget {
  final Question question;

  const QuestionDetailScreen({super.key, required this.question});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  bool _showAnswer = false;
  List<String> _userOrder = [];
  bool _isCorrect = false;
  bool _hasSubmitted = false;
  String? _errorMessage;
  List<String?> _answerSlots = [];
  List<String> _optionBank = [];

  @override
  void initState() {
    super.initState();
    _validateAndInitializeQuestion();
    if (_isDragAndDropQuestion() && widget.question.options.isNotEmpty) {
      _optionBank = List<String>.from(widget.question.options);
      _optionBank.shuffle(Random());
      _answerSlots = List<String?>.filled(widget.question.options.length, null);
    }
  }

  void _validateAndInitializeQuestion() {
    // Debug information about the question
    print('Question Details:');
    print('- ID: ${widget.question.id}');
    print('- Type: ${widget.question.questionType}');
    print('- Text: ${widget.question.questionText}');
    print('- Has Image: ${widget.question.hasQuestionImage}');
    print('- Question Image URL: ${widget.question.questionImageUrl}');
    print('- Options: ${widget.question.options}');
    print('- Has Image Options: ${widget.question.hasImageOptions}');
    print('- Option Image URLs: ${widget.question.optionImageUrls}');
    print('- CorrectOrder: ${widget.question.correctOrder}');
    print('- CorrectAnswer: ${widget.question.correctAnswer}');

    // Validate the question data
    if (widget.question.options.isEmpty) {
      _errorMessage = 'This question has no options to arrange.';
      print('Error: Question options array is empty');
    } else if (widget.question.correctOrder.isEmpty) {
      _errorMessage = 'This question has no correct order defined.';
      print('Error: Question correctOrder array is empty');
    } else if (widget.question.correctOrder.any(
      (index) => index >= widget.question.options.length,
    )) {
      _errorMessage = 'This question has invalid correct order indices.';
      print('Error: Question has invalid correctOrder indices');
    } else {
      // Create a shuffled copy of the options list to avoid modifying the original
      _userOrder = List<String>.from(widget.question.options);
      _userOrder.shuffle(Random());
    }
  }

  void _checkAnswer() {
    if (_errorMessage != null) {
      setState(() {
        _isCorrect = false;
        _hasSubmitted = true;
        _showAnswer = true;
      });
      return;
    }
    bool correct = true;
    if (_isDragAndDropQuestion()) {
      for (int i = 0; i < widget.question.correctOrder.length; i++) {
        final correctOption = widget.question.options[widget.question.correctOrder[i]];
        if (_answerSlots[i] != correctOption) {
          correct = false;
          break;
        }
      }
    }
    setState(() {
      _isCorrect = correct;
      _hasSubmitted = true;
      _showAnswer = true;
    });
  }

  // Helper method to check if this is a drag-and-drop question
  bool _isDragAndDropQuestion() {
    return widget.question.questionType.toLowerCase() == 'drag-and-drop';
  }

  void _resetQuestion() {
    setState(() {
      _userOrder = List<String>.from(widget.question.options);
      _hasSubmitted = false;
      _showAnswer = false;
      if (_isDragAndDropQuestion() && widget.question.options.isNotEmpty) {
        _optionBank = List<String>.from(widget.question.options);
        _optionBank.shuffle(Random());
        _answerSlots = List<String?>.filled(widget.question.options.length, null);
      }
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
            // Question Type
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

            // Question Text
            Text(
              widget.question.questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            // Question Image if available
            if (widget.question.hasQuestionImage) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.question.questionImageUrl!,
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
                    print('Error loading question image: $error');
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

            // Error message if question data is invalid
            if (_errorMessage != null)
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
                    Text(_errorMessage!, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),

            // Question Content - Different for each question type
            if (_errorMessage == null) _buildQuestionContent(),

            const SizedBox(height: 24),

            // Answer section
            if (_showAnswer) _buildAnswerSection(),

            const SizedBox(height: 24),

            // Buttons
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
                      _showAnswer = !_showAnswer;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    _showAnswer ? 'Hide Explanation' : 'Show Explanation',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent() {
    // Based on the question type, build the appropriate content
    final questionType = widget.question.questionType.toLowerCase();
    print('Building question content for type: $questionType');

    // Make this comparison case insensitive
    if (questionType == 'drag-and-drop') {
      return _buildDragAndDropQuestion();
    } else {
      // Show more helpful error information
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Question type not fully supported yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type detected: "${widget.question.questionType}"',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Text(
            'Question options: ${widget.question.options.join(", ")}',
            style: const TextStyle(fontSize: 14),
          ),
          // Display options in a simpler format for now
          const SizedBox(height: 16),
          ...widget.question.options.asMap().entries.map(
            (entry) => _buildOptionItem(entry.key, entry.value),
          ),
        ],
      );
    }
  }

  Widget _buildOptionItem(int index, String option) {
    // If we have image options, show only the image option
    if (widget.question.hasImageOptions &&
        index < (widget.question.optionImageUrls?.length ?? 0)) {
      // Smaller image chip
      return Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border:
                _hasSubmitted
                    ? Border.all(
                      color: _isCorrectItem(index) ? Colors.green : Colors.red,
                      width: 1.5,
                    )
                    : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.question.optionImageUrls![index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.error, size: 20, color: Colors.red),
                  ),
                );
              },
            ),
          ),
        ),
      );
    } else {
      // Regular text option as a chip
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Leading circular indicator
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            // Option text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  option,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      );
    }
  }

  Widget _buildDragAndDropQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Drag the correct options to solve the question:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 12),
        // Answer slots (vertical, reorderable)
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (_answerSlots[oldIndex] == null) return;
              if (newIndex > oldIndex) newIndex -= 1;
              final item = _answerSlots.removeAt(oldIndex);
              _answerSlots.insert(newIndex, item);
            });
          },
          children: List.generate(_answerSlots.length, (slotIndex) {
            return DragTarget<String>(
              key: ValueKey('slot-$slotIndex-${_answerSlots[slotIndex]}'),
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: 130,
                  height: 50, // Match reduced height
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                  decoration: BoxDecoration(
                    color: _answerSlots[slotIndex] == null ? Colors.grey[200] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blueAccent, width: 1),
                  ),
                  child: _answerSlots[slotIndex] == null
                      ? const Center(child: Text(""))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(6), // Add slight padding
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  widget.question.optionImageUrls![widget.question.options.indexOf(_answerSlots[slotIndex]!)],
                                  width: 118,
                                  height: 38,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                );
              },
              onWillAccept: (data) => _answerSlots[slotIndex] == null,
              onAccept: (data) {
                setState(() {
                  _answerSlots[slotIndex] = data;
                  _optionBank.remove(data);
                });
              },
            );
          }),
        ),
        const SizedBox(height: 24),
        // Option bank
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: _optionBank.map((option) {
            return Draggable<String>(
              data: option,
              feedback: Material(
                color: Colors.transparent,
                child: _buildOptionChip(option, isDragging: true),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _buildOptionChip(option),
              ),
              child: _buildOptionChip(option),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOptionChip(String option, {bool isDragging = false}) {
    int optionIndex = widget.question.options.indexOf(option);
    String? imageUrl = (widget.question.optionImageUrls != null && optionIndex < widget.question.optionImageUrls!.length)
        ? widget.question.optionImageUrls![optionIndex]
        : null;
    return Container(
      constraints: const BoxConstraints(
        minWidth: 0,
        minHeight: 0,
        maxWidth: 130,
        maxHeight: 50, // Reduced height to better fit the image aspect ratio
      ),
      padding: const EdgeInsets.all(6), // Add slight padding around the image
      decoration: BoxDecoration(
        color: isDragging ? Colors.blue[200] : Colors.blue,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDragging
            ? [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
            : [],
      ),
      alignment: Alignment.center,
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 118, // 130 - 2*6 padding
                height: 38, // 50 - 2*6 padding
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildSlotImage(String option) {
    int optionIndex = widget.question.options.indexOf(option);
    String? imageUrl = (widget.question.optionImageUrls != null && optionIndex < widget.question.optionImageUrls!.length)
        ? widget.question.optionImageUrls![optionIndex]
        : null;
    return imageUrl != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 130, // Increased from 110
              height: 95, // Increased from 80
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildAnswerSection() {
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
            ...widget.question.correctAnswer.map(
              (answer) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $answer', style: const TextStyle(fontSize: 16)),
              ),
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

  // Helper method to get the color for each item in the list
  Color _getItemColor(int index) {
    if (_isCorrectItem(index)) {
      return Colors.green.withOpacity(0.1);
    }
    return Colors.red.withOpacity(0.1);
  }

  // Helper method to check if an item is in the correct position
  bool _isCorrectItem(int index) {
    // Add safety checks to prevent index out of bounds errors
    if (index < 0 ||
        index >= _userOrder.length ||
        widget.question.correctOrder.isEmpty ||
        index >= widget.question.correctOrder.length ||
        widget.question.correctOrder[index] >= widget.question.options.length) {
      return false;
    }

    return _userOrder[index] ==
        widget.question.options[widget.question.correctOrder[index]];
  }
}
