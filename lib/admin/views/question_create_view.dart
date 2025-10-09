import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/viewmodels/question_create_viewmodel.dart';
import 'package:past_question_paper_v1/admin/widgets/parent_selector_section.dart';
import 'package:past_question_paper_v1/admin/widgets/basic_info_section.dart';
import 'package:past_question_paper_v1/admin/widgets/question_content_section.dart';
import 'package:past_question_paper_v1/admin/widgets/mcq_answer_section.dart';
import 'package:past_question_paper_v1/admin/widgets/short_answer_section.dart';
import 'package:past_question_paper_v1/admin/widgets/drag_drop_section.dart';
import 'package:past_question_paper_v1/admin/widgets/metadata_section.dart';
import 'package:past_question_paper_v1/admin/widgets/availability_section.dart';
import 'package:past_question_paper_v1/admin/widgets/question_preview_panel.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';

/// Question Creation Form - Refactored with separate widget sections
class QuestionCreateView extends ConsumerStatefulWidget {
  final String? questionId;

  const QuestionCreateView({super.key, this.questionId});

  @override
  ConsumerState<QuestionCreateView> createState() => _QuestionCreateViewState();
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

  bool _hasAppliedEditState = false;
  ProviderSubscription<QuestionCreateState>? _stateSubscription;
  late final QuestionCreateViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = ref.read(questionCreateViewModelProvider.notifier);

    _stateSubscription = ref.listenManual<QuestionCreateState>(
      questionCreateViewModelProvider,
      (previous, next) {
        if (!mounted || next.isLoading) return;

        final enteredEditMode = next.isEditMode && !_hasAppliedEditState;
        if (enteredEditMode) {
          _applyStateToControllers(next);
          _hasAppliedEditState = true;
          return;
        }

        final exitedEditMode =
            (previous?.isEditMode == true && !next.isEditMode);
        if (exitedEditMode) {
          _hasAppliedEditState = false;
          _applyStateToControllers(next);
          return;
        }

        final resetAfterCreate =
            previous?.isSubmitting == true &&
            !next.isSubmitting &&
            next.successMessage != null &&
            !next.isEditMode;

        if (resetAfterCreate) {
          _applyStateToControllers(next);
        }
      },
    );

    _applyStateToControllers(
      ref.read(questionCreateViewModelProvider),
      repaint: false,
    );

    if (widget.questionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _viewModel.loadQuestionForEdit(widget.questionId!);
      });
    }
  }

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
    _stateSubscription?.close();
    _viewModel.resetForm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionCreateViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.isEditMode ? 'Edit Question' : 'Create Question'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: state.isSubmitting
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
                    onPressed: state.isLoading ? null : _submitForm,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: Text(
                      state.isEditMode ? 'Update Question' : 'Save Question',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: state.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                )
              : AbsorbPointer(
                  absorbing: state.isSubmitting,
                  child: Form(
                    key: _formKey,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (state.isEditMode)
                                  _buildEditModeBanner(state),
                                if (state.errorMessage != null)
                                  _buildErrorBanner(state.errorMessage!),
                                if (state.successMessage != null)
                                  _buildSuccessBanner(state.successMessage!),

                                const ParentSelectorSection(),

                                const SizedBox(height: 24),

                                _buildSectionHeader('Basic Information'),
                                const BasicInfoSection(),

                                const SizedBox(height: 32),

                                _buildSectionHeader('Question Content'),
                                QuestionContentSection(
                                  questionTextController:
                                      _questionTextController,
                                ),

                                const SizedBox(height: 32),

                                _buildSectionHeader('Answer Configuration'),
                                _buildAnswerSection(state),

                                const SizedBox(height: 32),

                                _buildSectionHeader('Metadata'),
                                MetadataSection(
                                  marksController: _marksController,
                                ),

                                const SizedBox(height: 32),

                                _buildSectionHeader('Availability'),
                                AvailabilitySection(
                                  pqpNumberController: _pqpNumberController,
                                ),

                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            color: AppColors.paper,
                            child: const SingleChildScrollView(
                              padding: EdgeInsets.all(24),
                              child: QuestionPreviewPanel(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  void _applyStateToControllers(
    QuestionCreateState state, {
    bool repaint = true,
  }) {
    void assignValues() {
      final options = List<String>.from(state.mcqOptions.take(4));
      while (options.length < 4) {
        options.add('');
      }

      _questionTextController.text = state.questionText;
      _marksController.text = state.marks.toString();
      _pqpNumberController.text = state.pqpNumber;
      _correctAnswerController.text = state.correctAnswer;
      _correctOrderController.text = state.correctOrder;
      _explanationController.text = state.explanation;
      _optionAController.text = options[0];
      _optionBController.text = options[1];
      _optionCController.text = options[2];
      _optionDController.text = options[3];

      _syncControllerList(_variationControllers, state.answerVariations);
      _syncControllerList(
        _dragItemControllers,
        state.dragItems.map((item) => item['text']?.toString() ?? '').toList(),
      );
    }

    if (!mounted) return;

    if (repaint) {
      setState(assignValues);
    } else {
      assignValues();
    }
  }

  void _syncControllerList(
    List<TextEditingController> controllers,
    List<String> values,
  ) {
    if (values.isEmpty) {
      for (final controller in controllers) {
        controller.dispose();
      }
      controllers.clear();
      return;
    }

    while (controllers.length > values.length) {
      controllers.removeLast().dispose();
    }

    while (controllers.length < values.length) {
      controllers.add(TextEditingController());
    }

    for (var i = 0; i < values.length; i++) {
      controllers[i].text = values[i];
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEditModeBanner(QuestionCreateState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.edit, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editing existing question',
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.questionId != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Question ID: ${state.questionId}',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSection(QuestionCreateState state) {
    if (state.format == 'MCQ') {
      return MCQAnswerSection(
        optionAController: _optionAController,
        optionBController: _optionBController,
        optionCController: _optionCController,
        optionDController: _optionDController,
        explanationController: _explanationController,
      );
    } else if (state.format == 'short_answer') {
      return ShortAnswerSection(
        correctAnswerController: _correctAnswerController,
        explanationController: _explanationController,
        variationControllers: _variationControllers,
        onAddVariation: _addAnswerVariation,
        onRemoveVariation: _removeAnswerVariation,
      );
    } else if (state.format == 'drag_drop') {
      return DragDropSection(
        dragItemControllers: _dragItemControllers,
        correctOrderController: _correctOrderController,
        explanationController: _explanationController,
        onAddDragItem: _addDragItem,
        onRemoveDragItem: _removeDragItem,
      );
    }
    return const Text('Select a format to configure answers');
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.green.shade700),
            ),
          ),
        ],
      ),
    );
  }

  // Answer variation methods
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

  // Drag item methods
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
          .map(
            (entry) => {
              'id': 'step_${entry.key + 1}',
              'text': entry.value.text,
            },
          )
          .where((item) => (item['text'] as String).isNotEmpty)
          .toList();

      // Update correct order in state before submitting
      if (_correctOrderController.text.isNotEmpty) {
        _viewModel.updateCorrectOrder(_correctOrderController.text);
      }

      _viewModel.submitQuestion(
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
