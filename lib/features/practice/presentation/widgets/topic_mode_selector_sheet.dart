import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/core/shared/utils/app_constants.dart';
import 'package:past_question_paper_v1/core/theme/app_colors.dart';

enum TopicPracticeMode { pdfView, interactiveQuiz }

class TopicModeSelectionResult {
  final String subject;
  final int grade;
  final TopicPracticeMode mode;

  const TopicModeSelectionResult({
    required this.subject,
    required this.grade,
    required this.mode,
  });
}

class TopicModeSelectorSheet extends StatefulWidget {
  final String topic;
  final String initialSubject;
  final int initialGrade;

  const TopicModeSelectorSheet({
    super.key,
    required this.topic,
    required this.initialSubject,
    required this.initialGrade,
  });

  @override
  State<TopicModeSelectorSheet> createState() => _TopicModeSelectorSheetState();
}

class _TopicModeSelectorSheetState extends State<TopicModeSelectorSheet> {
  late String _selectedSubject;
  late int _selectedGrade;
  TopicPracticeMode? _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.initialSubject;
    _selectedGrade = widget.initialGrade;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subjects = [...AppConstants.allSubjects]..sort();
    final grades = [...AppConstants.grades]..sort();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.topic,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose filters and how you want to practice this topic.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.neutralMid,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(labelText: 'Subject'),
                    items: subjects
                        .map(
                          (subject) => DropdownMenuItem<String>(
                            value: subject,
                            child: Text(_toTitle(subject)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedSubject = value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedGrade,
                    decoration: const InputDecoration(labelText: 'Grade'),
                    items: grades
                        .map(
                          (grade) => DropdownMenuItem<int>(
                            value: grade,
                            child: Text('Grade $grade'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedGrade = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ModeCard(
              title: 'PDF View Mode',
              subtitle: 'View topic paper packet in a read-only exam format.',
              icon: Icons.picture_as_pdf_outlined,
              selected: _selectedMode == TopicPracticeMode.pdfView,
              onTap: () =>
                  setState(() => _selectedMode = TopicPracticeMode.pdfView),
            ),
            const SizedBox(height: 10),
            _ModeCard(
              title: 'Interactive Quiz',
              subtitle:
                  'Answer in-app with instant feedback and progress tracking.',
              icon: Icons.quiz_outlined,
              selected: _selectedMode == TopicPracticeMode.interactiveQuiz,
              onTap: () => setState(
                () => _selectedMode = TopicPracticeMode.interactiveQuiz,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedMode == null
                    ? null
                    : () {
                        Navigator.pop(
                          context,
                          TopicModeSelectionResult(
                            subject: _selectedSubject,
                            grade: _selectedGrade,
                            mode: _selectedMode!,
                          ),
                        );
                      },
                child: Text(
                  _selectedMode == TopicPracticeMode.pdfView
                      ? 'Start PDF View'
                      : 'Start Interactive Quiz',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _toTitle(String value) {
    return value
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return '${word[0].toUpperCase()}${word.substring(1)}';
        })
        .join(' ');
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.accent : colorScheme.outlineVariant,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.accent : colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (selected)
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.check_circle, color: AppColors.accent),
              ),
          ],
        ),
      ),
    );
  }
}
