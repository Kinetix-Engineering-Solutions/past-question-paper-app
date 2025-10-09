import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/viewmodels/parent_question_create_viewmodel.dart';
import 'package:past_question_paper_v1/admin/widgets/image_upload_widget.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/utils/app_constants.dart';

/// Parent Question Creator - For creating context documents that multiple child questions reference
class ParentQuestionCreateView extends ConsumerStatefulWidget {
  final String? parentId;

  const ParentQuestionCreateView({super.key, this.parentId});

  @override
  ConsumerState<ParentQuestionCreateView> createState() =>
      _ParentQuestionCreateViewState();
}

class _ParentQuestionCreateViewState
    extends ConsumerState<ParentQuestionCreateView> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _contextTextController = TextEditingController();
  final _pqpNumberController = TextEditingController();
  final _yearController = TextEditingController(text: '2024');

  bool _hasAppliedEditState = false;
  late final ParentQuestionCreateViewModel _viewModel;
  ProviderSubscription<ParentQuestionCreateState>? _stateSubscription;

  @override
  void dispose() {
    _contextTextController.dispose();
    _pqpNumberController.dispose();
    _yearController.dispose();
    _stateSubscription?.close();
    _viewModel.exitEditMode();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _viewModel = ref.read(parentQuestionCreateViewModelProvider.notifier);

    _stateSubscription = ref.listenManual<ParentQuestionCreateState>(
      parentQuestionCreateViewModelProvider,
      (previous, next) {
        if (!mounted || next.isLoading) return;

        // Apply loaded data once when entering edit mode
        if (next.isEditMode && !_hasAppliedEditState) {
          _applyStateToControllers(next);
          _hasAppliedEditState = true;
        }

        // Reset controllers when leaving edit mode or after create reset
        final bool transitionedOutOfEdit =
            (previous?.isEditMode == true && !next.isEditMode);
        final bool finishedCreateSuccess =
            previous?.isSubmitting == true &&
            !next.isSubmitting &&
            next.successMessage != null &&
            !next.isEditMode;

        if (transitionedOutOfEdit || finishedCreateSuccess) {
          _hasAppliedEditState = false;
          _applyStateToControllers(next);
        }
      },
    );

    // Apply defaults immediately
    _applyStateToControllers(ref.read(parentQuestionCreateViewModelProvider));

    // Load parent data if editing
    if (widget.parentId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _viewModel.loadParentForEdit(widget.parentId!);
      });
    }
  }

  void _applyStateToControllers(ParentQuestionCreateState state) {
    _contextTextController.text = state.contextText;
    _pqpNumberController.text = state.pqpNumber;
    _yearController.text = state.year.toString();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _viewModel.saveParentQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(parentQuestionCreateViewModelProvider);

    if (viewModel.isEditMode && !viewModel.isLoading && !_hasAppliedEditState) {
      _applyStateToControllers(viewModel);
      _hasAppliedEditState = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          viewModel.isEditMode
              ? 'Edit Parent Question'
              : 'Create Parent Question (Context)',
        ),
        actions: [
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
                    icon: const Icon(Icons.save, color: AppColors.ink),
                    label: Text(
                      viewModel.isEditMode ? 'Update Parent' : 'Save Parent',
                      style: const TextStyle(color: AppColors.ink),
                    ),
                  ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: viewModel.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                )
              : AbsorbPointer(
                  absorbing: viewModel.isSubmitting,
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Info Banner
                          _buildInfoBanner(),
                          const SizedBox(height: 24),

                          if (viewModel.isEditMode)
                            _buildEditSummary(viewModel),

                          if (viewModel.isEditMode) const SizedBox(height: 16),

                          // Error/Success Messages
                          if (viewModel.errorMessage != null)
                            _buildErrorBanner(viewModel.errorMessage!),
                          if (viewModel.successMessage != null)
                            _buildSuccessBanner(viewModel.successMessage!),

                          // Basic Information
                          _buildSectionHeader('Basic Information'),
                          _buildBasicInfoSection(viewModel),

                          const SizedBox(height: 32),

                          // Context Content
                          _buildSectionHeader('Shared Context'),
                          _buildContextSection(viewModel),

                          const SizedBox(height: 32),

                          // PQP Metadata
                          _buildSectionHeader('PQP Metadata'),
                          _buildPQPMetadataSection(viewModel),

                          const SizedBox(height: 32),

                          // Availability
                          _buildSectionHeader('Availability'),
                          _buildAvailabilitySection(viewModel),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildEditSummary(ParentQuestionCreateState state) {
    final childCount = state.childQuestionIds.length;
    return Container(
      padding: const EdgeInsets.all(16),
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
                  'Editing existing parent question',
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  childCount == 0
                      ? 'No child questions are currently linked to this parent.'
                      : '$childCount child question${childCount == 1 ? ' is' : 's are'} linked. Updates to the context will apply to all of them.',
                  style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What is a Parent Question?',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'A parent question provides shared context (text, diagrams, scenarios) for multiple child questions. '
                  'It\'s NOT an answerable question itself - just context that children reference.',
                  style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget _buildBasicInfoSection(ParentQuestionCreateState state) {
    final notifier = ref.read(parentQuestionCreateViewModelProvider.notifier);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: state.subject.isEmpty ? null : state.subject,
                decoration: const InputDecoration(labelText: 'Subject *'),
                items: AppConstants.subjects
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) notifier.updateSubject(value);
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
                  if (value != null) notifier.updateGrade(value);
                },
                validator: (value) =>
                    value == null ? 'Grade is required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: state.topic.isEmpty ? null : state.topic,
          decoration: const InputDecoration(
            labelText: 'Topic *',
            helperText: 'Children will inherit this topic',
          ),
          items: state.subject.isNotEmpty
              ? (AppConstants.topicsBySubject[state.subject] ?? [])
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList()
              : [],
          onChanged: (value) {
            if (value != null) notifier.updateTopic(value);
          },
          validator: (value) => value == null ? 'Topic is required' : null,
        ),
      ],
    );
  }

  Widget _buildContextSection(ParentQuestionCreateState state) {
    final notifier = ref.read(parentQuestionCreateViewModelProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _contextTextController,
          decoration: const InputDecoration(
            labelText: 'Context/Scenario Text *',
            hintText: 'The sketch below shows the graphs of...',
            helperText:
                'Shared context that all child questions will reference',
            alignLabelWithHint: true,
          ),
          maxLines: 6,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Context text is required' : null,
          onChanged: (value) => notifier.updateContextText(value),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        Text(
          'Shared Image/Diagram',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.neutralMid,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add a diagram or image that all child questions will share',
          style: TextStyle(fontSize: 12, color: AppColors.neutralMid),
        ),
        const SizedBox(height: 12),
        ImageUploadWidget(
          initialImageUrl: state.imageUrl,
          onImageUploaded: (url) => notifier.updateImageUrl(url),
          onImageRemoved: () => notifier.updateImageUrl(''),
          folder: 'parent_question_images',
        ),
      ],
    );
  }

  Widget _buildPQPMetadataSection(ParentQuestionCreateState state) {
    final notifier = ref.read(parentQuestionCreateViewModelProvider.notifier);

    return Column(
      children: [
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
                  if (value != null) notifier.updatePaper(value);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year *'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Year is required';
                  if (int.tryParse(value!) == null) return 'Must be a number';
                  return null;
                },
                onChanged: (value) {
                  final year = int.tryParse(value);
                  if (year != null) notifier.updateYear(year);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: state.season,
                decoration: const InputDecoration(labelText: 'Season *'),
                items: const [
                  DropdownMenuItem(value: 'November', child: Text('November')),
                  DropdownMenuItem(value: 'June', child: Text('May/June')),
                  DropdownMenuItem(value: 'March', child: Text('March')),
                ],
                onChanged: (value) {
                  if (value != null) notifier.updateSeason(value);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _pqpNumberController,
                decoration: const InputDecoration(
                  labelText: 'PQP Number *',
                  hintText: 'e.g., 4.1',
                  helperText:
                      'Parent number (children will be 4.1.1, 4.1.2, etc.)',
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'PQP number is required' : null,
                onChanged: (value) => notifier.updatePQPNumber(value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection(ParentQuestionCreateState state) {
    final notifier = ref.read(parentQuestionCreateViewModelProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Child questions will be available in:',
          style: TextStyle(color: AppColors.neutralMid),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('PQP (Past Question Paper) Mode'),
          value: state.availableInPQP,
          onChanged: (value) => notifier.togglePQPMode(),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('Sprint (Quick Practice) Mode'),
          value: state.availableInSprint,
          onChanged: (value) => notifier.toggleSprintMode(),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
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
}
