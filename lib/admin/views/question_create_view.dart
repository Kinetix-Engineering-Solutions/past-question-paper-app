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
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error/Success Messages
                        if (viewModel.errorMessage != null)
                          _buildErrorBanner(viewModel.errorMessage!),
                        if (viewModel.successMessage != null)
                          _buildSuccessBanner(viewModel.successMessage!),
                        
                        // Parent Selector (for child questions)
                        const ParentSelectorSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Basic Information
                        _buildSectionHeader('Basic Information'),
                        const BasicInfoSection(),
                        
                        const SizedBox(height: 32),
                        
                        // Question Content
                        _buildSectionHeader('Question Content'),
                        QuestionContentSection(
                          questionTextController: _questionTextController,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Answer Configuration
                        _buildSectionHeader('Answer Configuration'),
                        _buildAnswerSection(viewModel),
                        
                        const SizedBox(height: 32),
                        
                        // Metadata
                        _buildSectionHeader('Metadata'),
                        MetadataSection(marksController: _marksController),
                        
                        const SizedBox(height: 32),
                        
                        // Availability
                        _buildSectionHeader('Availability'),
                        AvailabilitySection(
                          pqpNumberController: _pqpNumberController,
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                
                // Preview (Right side)
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
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
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700),
            ),
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
