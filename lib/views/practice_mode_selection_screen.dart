import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/practice_mode.dart';
import 'package:past_question_paper_stem/model/topic.dart';
import 'package:past_question_paper_stem/utils/app_theme.dart';
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
  @override
  void initState() {
    super.initState();
    // Load questions for this topic when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(practiceViewModelProvider.notifier)
          .loadQuestionsForTopic(widget.topic);
    });
  }

  @override
  Widget build(BuildContext context) {
    final practiceState = ref.watch(practiceViewModelProvider);
    final practiceViewModel = ref.read(practiceViewModelProvider.notifier);

    // Listen for errors
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
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.name),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body:
          practiceState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildPracticeModes(), const SizedBox(height: 24)],
                ),
              ),
    );
  }

  Widget _buildPracticeModes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Practice Mode',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...PracticeMode.values.map((mode) => _buildPracticeModeCard(mode)),
      ],
    );
  }

  Widget _buildPracticeModeCard(PracticeMode mode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _startPractice(mode),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(mode.icon, color: AppColors.charcoal, size: 24),
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
                              color: AppColors.lightGray.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              mode.durationText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.charcoal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mode.description,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
    );
  }

  void _startPractice(PracticeMode mode) async {
    final practiceViewModel = ref.read(practiceViewModelProvider.notifier);

    // Start the practice session
    await practiceViewModel.startPracticeSession(widget.topic, mode);

    final practiceState = ref.read(practiceViewModelProvider);
    if (practiceState.error == null && practiceState.currentSession != null) {
      // Navigate to practice session screen
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const PracticeSessionScreen(),
          ),
        );
      }
    }
  }
}
