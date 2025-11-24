import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/viewmodels/paper_upload_viewmodel.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';

/// Paper Upload View - Upload past question paper PDFs
class PaperUploadView extends ConsumerWidget {
  const PaperUploadView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paperUploadViewModelProvider);
    final viewModel = ref.read(paperUploadViewModelProvider.notifier);

    // Show snackbar for success/error messages
    if (state.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        viewModel.clearMessages();
      });
    }

    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        viewModel.clearMessages();
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Past Paper'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Icon
                Icon(Icons.upload_file, size: 64, color: AppColors.accent),
                const SizedBox(height: 16),
                Text(
                  'Upload Past Question Paper',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill in the details below and upload a PDF file',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.neutralMid),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Subject Dropdown
                _buildDropdownField(
                  context: context,
                  label: 'Subject',
                  value: state.subject,
                  items: const [
                    'mathematics',
                    'science',
                    'english',
                    'history',
                    'geography',
                  ],
                  onChanged: state.isUploading
                      ? null
                      : (value) => viewModel.updateSubject(value!),
                ),
                const SizedBox(height: 16),

                // Grade Input
                _buildNumberField(
                  context: context,
                  label: 'Grade',
                  value: state.grade,
                  min: 1,
                  max: 12,
                  enabled: !state.isUploading,
                  onChanged: (value) => viewModel.updateGrade(value),
                ),
                const SizedBox(height: 16),

                // Year Input
                _buildNumberField(
                  context: context,
                  label: 'Year',
                  value: state.year,
                  min: 2000,
                  max: 2100,
                  enabled: !state.isUploading,
                  onChanged: (value) => viewModel.updateYear(value),
                ),
                const SizedBox(height: 16),

                // Season Dropdown
                _buildDropdownField(
                  context: context,
                  label: 'Season',
                  value: state.season,
                  items: const ['November', 'June', 'March'],
                  onChanged: state.isUploading
                      ? null
                      : (value) => viewModel.updateSeason(value!),
                ),
                const SizedBox(height: 16),

                // Paper Number Dropdown
                _buildDropdownField(
                  context: context,
                  label: 'Paper Number',
                  value: state.paperNumber,
                  items: const ['p1', 'p2', 'p3'],
                  onChanged: state.isUploading
                      ? null
                      : (value) => viewModel.updatePaperNumber(value!),
                ),
                const SizedBox(height: 16),

                // Title Text Field
                TextField(
                  enabled: !state.isUploading,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText:
                        'e.g., Mathematics Grade 10 November 2024 Paper 1',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: viewModel.updateTitle,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // PDF File Picker
                _buildFilePicker(context, ref, state, viewModel),
                const SizedBox(height: 32),

                // Upload Progress
                if (state.isUploading) ...[
                  LinearProgressIndicator(
                    value: state.uploadProgress,
                    backgroundColor: AppColors.neutralBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(state.uploadProgress * 100).toInt()}% uploaded',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.neutralMid,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],

                // Upload Button
                ElevatedButton.icon(
                  onPressed: state.isUploading || state.selectedPdfFile == null
                      ? null
                      : () => viewModel.uploadPaper(),
                  icon: state.isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: Text(
                    state.isUploading ? 'Uploading...' : 'Upload Paper',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildNumberField({
    required BuildContext context,
    required String label,
    required int value,
    required int min,
    required int max,
    required bool enabled,
    required void Function(int) onChanged,
  }) {
    return TextField(
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      controller: TextEditingController(text: value.toString())
        ..selection = TextSelection.collapsed(offset: value.toString().length),
      onChanged: (text) {
        final parsed = int.tryParse(text);
        if (parsed != null && parsed >= min && parsed <= max) {
          onChanged(parsed);
        }
      },
    );
  }

  Widget _buildFilePicker(
    BuildContext context,
    WidgetRef ref,
    PaperUploadState state,
    PaperUploadViewModel viewModel,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: state.isUploading
            ? null
            : () async {
                try {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                    withData: true,
                  );

                  if (result != null && result.files.isNotEmpty) {
                    final file = result.files.first;
                    if (file.bytes != null) {
                      viewModel.setSelectedPdf(
                        file.bytes!,
                        file.name,
                        file.size,
                      );
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to pick file: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                state.selectedPdfFile != null
                    ? Icons.picture_as_pdf
                    : Icons.upload_file,
                size: 48,
                color: state.selectedPdfFile != null
                    ? AppColors.accent
                    : AppColors.neutralMid,
              ),
              const SizedBox(height: 16),
              Text(
                state.selectedPdfFile != null
                    ? state.selectedFileName
                    : 'Click to select PDF file',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: state.selectedPdfFile != null
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: state.selectedPdfFile != null
                      ? AppColors.ink
                      : AppColors.neutralMid,
                ),
                textAlign: TextAlign.center,
              ),
              if (state.selectedPdfFile != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${(state.selectedFileSize / 1024).toStringAsFixed(2)} KB',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.neutralMid),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: state.isUploading
                      ? null
                      : () => viewModel.clearSelectedPdf(),
                  icon: const Icon(Icons.close),
                  label: const Text('Remove'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
