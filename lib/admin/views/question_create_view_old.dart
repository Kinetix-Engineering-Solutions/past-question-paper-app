import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/viewmodels/question_create_viewmodel.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/utils/app_constants.dart';

/// Question Creation Form - Core feature for quick data entry
class QuestionCreateView extends ConsumerStatefulWidget {
  const QuestionCreateView({super.key});

  @override
  ConsumerState<QuestionCreateView> createState() =>
      _QuestionCreateViewState();
}

class _QuestionCreateViewState extends ConsumerState<QuestionCreateView> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _questionTextController = TextEditingController();
  final _correctAnswerController = TextEditingController();
  final _explanationController = TextEditingController();
  final _marksController = TextEditingController(text: '1');
  final _pqpNumberController = TextEditingController();
  final _correctOrderController = TextEditingController();
  
  // MCQ options controllers
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionCController = TextEditingController();
  final _optionDController = TextEditingController();
  
  // Answer variations for short answer
  final List<TextEditingController> _variationControllers = [];
  
  // Drag items for drag-and-drop ordering
  final List<TextEditingController> _dragItemControllers = [];

  @override
  void dispose() {
    _questionTextController.dispose();
    _correctAnswerController.dispose();
    _explanationController.dispose();
    _marksController.dispose();
    _pqpNumberController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    _correctOrderController.dispose();
    for (var controller in _variationControllers) {
      controller.dispose();
    }
    for (var controller in _dragItemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(questionCreateViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Question'),
        actions: [
          // Save button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: viewModel.isSubmitting
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : TextButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'Save Question',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Form(
            key: _formKey,
            child: Row(
              children: [
                // Form (Left side)
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Basic Information'),
                    const SizedBox(height: 16),
                    _buildBasicInfoSection(viewModel),
                    const SizedBox(height: 32),
                    
                    _buildSectionTitle('Question Content'),
                    const SizedBox(height: 16),
                    _buildQuestionContentSection(viewModel),
                    const SizedBox(height: 32),
                    
                    _buildSectionTitle('Answer Configuration'),
                    const SizedBox(height: 16),
                    _buildAnswerSection(viewModel),
                    const SizedBox(height: 32),
                    
                    _buildSectionTitle('Metadata'),
                    const SizedBox(height: 16),
                    _buildMetadataSection(viewModel),
                    const SizedBox(height: 32),
                    
                    _buildSectionTitle('Availability'),
                    const SizedBox(height: 16),
                    _buildAvailabilitySection(viewModel),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            
            // Preview (Right side)
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.grey[100],
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.ink,
                      child: Row(
                        children: [
                          Icon(Icons.visibility, color: AppColors.paper),
                          const SizedBox(width: 8),
                          Text(
                            'Preview',
                            style: TextStyle(
                              color: AppColors.paper,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: _buildPreview(viewModel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  )); // Close Center and Scaffold
}

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBasicInfoSection(QuestionCreateState state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: state.subject,
                decoration: const InputDecoration(labelText: 'Subject *'),
                items: AppConstants.subjects
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(questionCreateViewModelProvider.notifier)
                        .updateSubject(value);
                  }
                },
                validator: (value) =>
                    value == null ? 'Subject is required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: state.grade,
                decoration: const InputDecoration(labelText: 'Grade *'),
                items: AppConstants.grades
                    .map((g) => DropdownMenuItem(value: g, child: Text('$g')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(questionCreateViewModelProvider.notifier)
                        .updateGrade(value);
                  }
                },
                validator: (value) => value == null ? 'Grade is required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: state.topic.isEmpty ? null : state.topic,
          decoration: const InputDecoration(labelText: 'Topic *'),
          items: (AppConstants.topicsBySubject[state.subject] ?? [])
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(questionCreateViewModelProvider.notifier)
                  .updateTopic(value);
            }
          },
          validator: (value) => value == null ? 'Topic is required' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: state.paper,
                decoration: const InputDecoration(labelText: 'Paper *'),
                items: const [
                  DropdownMenuItem(value: 'p1', child: Text('Paper 1')),
                  DropdownMenuItem(value: 'p2', child: Text('Paper 2')),
                  DropdownMenuItem(value: 'p3', child: Text('Paper 3')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(questionCreateViewModelProvider.notifier)
                        .updatePaper(value);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: state.year,
                decoration: const InputDecoration(labelText: 'Year *'),
                items: List.generate(
                  10,
                  (i) => DateTime.now().year - i,
                )
                    .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(questionCreateViewModelProvider.notifier)
                        .updateYear(value);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: state.season,
                decoration: const InputDecoration(labelText: 'Season *'),
                items: const [
                  DropdownMenuItem(value: 'November', child: Text('November')),
                  DropdownMenuItem(value: 'June', child: Text('June')),
                  DropdownMenuItem(value: 'March', child: Text('March')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(questionCreateViewModelProvider.notifier)
                        .updateSeason(value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionContentSection(QuestionCreateState state) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: state.format,
          decoration: const InputDecoration(labelText: 'Question Format *'),
          items: const [
            DropdownMenuItem(value: 'MCQ', child: Text('Multiple Choice (MCQ)')),
            DropdownMenuItem(value: 'short_answer', child: Text('Short Answer')),
            DropdownMenuItem(value: 'drag_drop', child: Text('Drag & Drop')),
            DropdownMenuItem(value: 'true_false', child: Text('True/False')),
            DropdownMenuItem(value: 'essay', child: Text('Essay')),
          ],
          onChanged: (value) {
            if (value != null) {
              ref.read(questionCreateViewModelProvider.notifier)
                  .updateFormat(value);
            }
          },
          validator: (value) => value == null ? 'Format is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _questionTextController,
          decoration: const InputDecoration(
            labelText: 'Question Text *',
            hintText: 'Enter the question text...',
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Question text is required' : null,
          onChanged: (value) {
            ref.read(questionCreateViewModelProvider.notifier)
                .updateQuestionText(value);
          },
        ),
      ],
    );
  }

  Widget _buildAnswerSection(QuestionCreateState state) {
    if (state.format == 'MCQ') {
      return _buildMCQAnswerSection(state);
    } else if (state.format == 'short_answer') {
      return _buildShortAnswerSection(state);
    } else if (state.format == 'drag_drop') {
      return _buildDragDropSection(state);
    }
    return const Text('Select a format to configure answers');
  }

  Widget _buildMCQAnswerSection(QuestionCreateState state) {
    return Column(
      children: [
        TextFormField(
          controller: _optionAController,
          decoration: const InputDecoration(labelText: 'Option A *'),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Option A is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _optionBController,
          decoration: const InputDecoration(labelText: 'Option B *'),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Option B is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _optionCController,
          decoration: const InputDecoration(labelText: 'Option C *'),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Option C is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _optionDController,
          decoration: const InputDecoration(labelText: 'Option D *'),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Option D is required' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: state.correctAnswer.isEmpty ? null : state.correctAnswer,
          decoration: const InputDecoration(labelText: 'Correct Answer *'),
          items: const [
            DropdownMenuItem(value: 'A', child: Text('A')),
            DropdownMenuItem(value: 'B', child: Text('B')),
            DropdownMenuItem(value: 'C', child: Text('C')),
            DropdownMenuItem(value: 'D', child: Text('D')),
          ],
          onChanged: (value) {
            if (value != null) {
              ref.read(questionCreateViewModelProvider.notifier)
                  .updateCorrectAnswer(value);
            }
          },
          validator: (value) =>
              value == null ? 'Correct answer is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _explanationController,
          decoration: const InputDecoration(
            labelText: 'Explanation (Optional)',
            hintText: 'Explain why this is the correct answer...',
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildShortAnswerSection(QuestionCreateState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _correctAnswerController,
          decoration: const InputDecoration(
            labelText: 'Correct Answer *',
            hintText: 'Enter the main correct answer',
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Correct answer is required' : null,
          onChanged: (value) {
            ref.read(questionCreateViewModelProvider.notifier)
                .updateCorrectAnswer(value);
          },
        ),
        const SizedBox(height: 16),
        const Text('Answer Variations (Optional)'),
        const SizedBox(height: 8),
        ..._buildAnswerVariations(),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _addAnswerVariation,
          icon: const Icon(Icons.add),
          label: const Text('Add Variation'),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Case Sensitive'),
          value: state.caseSensitive,
          onChanged: (value) {
            ref.read(questionCreateViewModelProvider.notifier)
                .updateCaseSensitive(value);
          },
        ),
      ],
    );
  }

  Widget _buildDragDropSection(QuestionCreateState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Students will arrange these items in the correct order',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Drag items list
        const Text('Drag Items (Steps to arrange):'),
        const SizedBox(height: 8),
        ..._buildDragItems(),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _addDragItem,
          icon: const Icon(Icons.add),
          label: const Text('Add Step'),
        ),
        
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        
        // Correct order
        const Text('Correct Order:'),
        const SizedBox(height: 8),
        Text(
          'Arrange the steps above in the correct order by entering step numbers (e.g., 1,2,3,4)',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.neutralMid,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _correctOrderController,
          decoration: const InputDecoration(
            labelText: 'Correct Order *',
            hintText: '1,2,3,4',
            helperText: 'Enter step numbers separated by commas',
          ),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Correct order is required' : null,
          onChanged: (value) {
            ref.read(questionCreateViewModelProvider.notifier)
                .updateCorrectOrder(value);
          },
        ),
      ],
    );
  }

  List<Widget> _buildAnswerVariations() {
    return _variationControllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Variation ${index + 1}',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeAnswerVariation(index),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _addAnswerVariation() {
    setState(() {
      _variationControllers.add(TextEditingController());
    });
  }

  void _removeAnswerVariation(int index) {
    setState(() {
      _variationControllers[index].dispose();
      _variationControllers.removeAt(index);
    });
  }

  List<Widget> _buildDragItems() {
    return _dragItemControllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Step ${index + 1}',
                  hintText: 'Enter step text or LaTeX',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeDragItem(index),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _addDragItem() {
    setState(() {
      _dragItemControllers.add(TextEditingController());
    });
  }

  void _removeDragItem(int index) {
    setState(() {
      _dragItemControllers[index].dispose();
      _dragItemControllers.removeAt(index);
    });
  }

  Widget _buildMetadataSection(QuestionCreateState state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _marksController,
                decoration: const InputDecoration(labelText: 'Marks *'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Marks is required';
                  if (int.tryParse(value!) == null) return 'Enter a valid number';
                  return null;
                },
                onChanged: (value) {
                  final marks = int.tryParse(value);
                  if (marks != null) {
                    ref.read(questionCreateViewModelProvider.notifier)
                        .updateMarks(marks);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: state.cognitiveLevel,
                decoration: const InputDecoration(labelText: 'Cognitive Level *'),
                items: const [
                  DropdownMenuItem(value: 'Level 1', child: Text('Level 1 - Knowledge')),
                  DropdownMenuItem(value: 'Level 2', child: Text('Level 2 - Routine')),
                  DropdownMenuItem(value: 'Level 3', child: Text('Level 3 - Application')),
                  DropdownMenuItem(value: 'Level 4', child: Text('Level 4 - Problem Solving')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(questionCreateViewModelProvider.notifier)
                        .updateCognitiveLevel(value);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: state.difficulty,
                decoration: const InputDecoration(labelText: 'Difficulty *'),
                items: const [
                  DropdownMenuItem(value: 'easy', child: Text('Easy')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'hard', child: Text('Hard')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(questionCreateViewModelProvider.notifier)
                        .updateDifficulty(value);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _pqpNumberController,
          decoration: const InputDecoration(
            labelText: 'PQP Question Number (e.g., 4.1.1)',
            hintText: 'Leave empty for auto-generation',
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection(QuestionCreateState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Available in modes:'),
        CheckboxListTile(
          title: const Text('Full Exam (PQP)'),
          value: state.availableInPQP,
          onChanged: (value) {
            ref.read(questionCreateViewModelProvider.notifier)
                .togglePQPMode();
          },
        ),
        CheckboxListTile(
          title: const Text('Quick Practice (Sprint)'),
          value: state.availableInSprint,
          onChanged: (value) {
            ref.read(questionCreateViewModelProvider.notifier)
                .toggleSprintMode();
          },
        ),
        CheckboxListTile(
          title: const Text('By Topic'),
          value: state.availableInByTopic,
          onChanged: (value) {
            ref.read(questionCreateViewModelProvider.notifier)
                .toggleByTopicMode();
          },
        ),
      ],
    );
  }

  Widget _buildPreview(QuestionCreateState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              children: [
                Chip(
                  label: Text(state.format),
                  backgroundColor: AppColors.accent.withOpacity(0.2),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('${state.marks} marks'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Question text
            if (_questionTextController.text.isNotEmpty) ...[
              const Text(
                'Question:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_questionTextController.text),
              const SizedBox(height: 16),
            ],
            
            // Options (for MCQ)
            if (state.format == 'MCQ') ...[
              if (_optionAController.text.isNotEmpty)
                _buildPreviewOption('A', _optionAController.text, state.correctAnswer == 'A'),
              if (_optionBController.text.isNotEmpty)
                _buildPreviewOption('B', _optionBController.text, state.correctAnswer == 'B'),
              if (_optionCController.text.isNotEmpty)
                _buildPreviewOption('C', _optionCController.text, state.correctAnswer == 'C'),
              if (_optionDController.text.isNotEmpty)
                _buildPreviewOption('D', _optionDController.text, state.correctAnswer == 'D'),
            ],
            
            // Metadata
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildPreviewMetadata('Subject', state.subject),
            _buildPreviewMetadata('Grade', '${state.grade}'),
            _buildPreviewMetadata('Topic', state.topic),
            _buildPreviewMetadata('Paper', state.paper.toUpperCase()),
            _buildPreviewMetadata('Year', '${state.year}'),
            _buildPreviewMetadata('Season', state.season),
            _buildPreviewMetadata('Cognitive Level', state.cognitiveLevel),
            _buildPreviewMetadata('Difficulty', state.difficulty),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewOption(String letter, String text, bool isCorrect) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isCorrect ? Colors.green : Colors.grey[300]!,
            width: isCorrect ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isCorrect ? Colors.green.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isCorrect ? Colors.green : Colors.grey[300],
              child: Text(
                letter,
                style: TextStyle(
                  color: isCorrect ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
            if (isCorrect)
              const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewMetadata(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppColors.neutralMid),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Collect MCQ options
      final options = [
        _optionAController.text,
        _optionBController.text,
        _optionCController.text,
        _optionDController.text,
      ];
      
      // Collect answer variations
      final variations = _variationControllers
          .map((c) => c.text)
          .where((t) => t.isNotEmpty)
          .toList();
      
      // Collect drag items
      final dragItems = _dragItemControllers
          .asMap()
          .entries
          .map((entry) => {
                'id': 'step_${entry.key + 1}',
                'text': entry.value.text,
              })
          .where((item) => (item['text'] as String).isNotEmpty)
          .toList();
      
      // Update correct order in state before submitting
      if (_correctOrderController.text.isNotEmpty) {
        ref.read(questionCreateViewModelProvider.notifier)
            .updateCorrectOrder(_correctOrderController.text);
      }
      
      ref.read(questionCreateViewModelProvider.notifier).submitQuestion(
            options: options,
            answerVariations: variations,
            dragItems: dragItems,
            explanation: _explanationController.text,
            pqpNumber: _pqpNumberController.text.isEmpty
                ? null
                : _pqpNumberController.text,
          );
    }
  }
}
