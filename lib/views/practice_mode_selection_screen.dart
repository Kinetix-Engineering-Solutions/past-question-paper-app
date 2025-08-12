import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/practice_mode.dart';
import 'package:past_question_paper_stem/model/topic.dart';
import 'package:past_question_paper_stem/utils/app_colors.dart';
import 'package:past_question_paper_stem/viewmodels/practice_viewmodel.dart';
import 'package:past_question_paper_stem/views/practice_session_screen.dart';

class PracticeModeSelectionScreen extends ConsumerStatefulWidget {
  final Topic topic;

  const PracticeModeSelectionScreen({super.key, required this.topic});

  @override
  ConsumerState<PracticeModeSelectionScreen> createState() =>
      _PracticeModeSelectionScreenState();
}

class _PracticeModeSelectionScreenState
    extends ConsumerState<PracticeModeSelectionScreen> {
  // We'll track the selected mode to know which session to load
  PracticeMode? _selectedMode;

  @override
  Widget build(BuildContext context) {
    final practiceState = ref.watch(practiceViewModelProvider);
    final practiceViewModel = ref.read(practiceViewModelProvider.notifier);

    // Listen for errors and provide feedback
    ref.listen(practiceViewModelProvider, (previous, current) {
      if (current.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(current.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () => practiceViewModel.clearError(),
              textColor: Colors.white,
            ),
          ),
        );
      }
      // Listen for a loaded session and navigate to it
      if (current.currentSession != null && previous?.currentSession == null) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const PracticeSessionScreen(),
            ),
          );
        }
      }
    });

    // Check if a practice session is currently being created
    final isCreatingSession = practiceState.isLoading && _selectedMode != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.name),
        centerTitle: true,
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.neutralCard,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Practice Mode',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...PracticeMode.values.map(
              (mode) => _buildPracticeModeCard(mode, isCreatingSession),
            ),
            const SizedBox(height: 24),
            // Display a loading indicator below the cards when a session is being created.
            if (isCreatingSession)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeModeCard(PracticeMode mode, bool isCreatingSession) {
    final bool isDisabled = isCreatingSession && _selectedMode != mode;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: isDisabled ? null : () => _startPractice(mode),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.neutralMid.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(mode.icon, color: AppColors.ink, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              mode.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.neutralMid.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                mode.durationText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mode.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isCreatingSession && _selectedMode == mode)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startPractice(PracticeMode mode) {
    setState(() {
      _selectedMode = mode;
    });
    ref
        .read(practiceViewModelProvider.notifier)
        .startPracticeSession(widget.topic, mode);
  }
}
