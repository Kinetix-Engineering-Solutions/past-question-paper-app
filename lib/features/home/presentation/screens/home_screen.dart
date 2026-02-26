import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/features/profile/domain/entities/user.dart';
import 'package:past_question_paper_v1/core/theme/app_colors.dart';
import 'package:past_question_paper_v1/core/shared/utils/app_constants.dart';
import 'package:past_question_paper_v1/core/shared/utils/haptic_feedback.dart';
import 'package:past_question_paper_v1/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:past_question_paper_v1/features/history/presentation/viewmodels/session_history_viewmodel.dart';
import 'package:past_question_paper_v1/features/profile/presentation/screens/profile_screen.dart';
import 'package:past_question_paper_v1/features/practice/presentation/screens/test_configuration_screen.dart';
import 'package:past_question_paper_v1/features/practice/presentation/widgets/subject_list_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final asyncHistory = ref.watch(sessionHistoryViewModelProvider);
    final user = homeState.user;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 🚀 MVP: Lock to Grade 12 only
    final userGrade = 12; // Force Grade 12 for MVP release

    // 🚀 MVP: Show all subjects but mark unavailable ones as "Coming Soon"
    final subjects = AppConstants.allSubjects;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          'Hello, ${resolvePreferredFirstName(user)}!',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: _SubjectListSection(
          subjects: subjects,
          selectedGrade: userGrade,
          historyEntries: asyncHistory.maybeWhen(
            data: (entries) => entries,
            orElse: () => const <SessionHistoryEntry>[],
          ),
        ),
      ),
    );
  }
}

String? _paceLabelForLastPqp(SessionHistoryEntry entry) {
  final durationMinutes = entry.durationMinutes;
  final sessionSeconds = entry.sessionDurationSeconds;
  final totalQuestions = entry.totalQuestions;

  if (durationMinutes == null || durationMinutes <= 0) return null;
  if (sessionSeconds == null || sessionSeconds <= 0) return null;
  if (totalQuestions <= 0) return null;

  final targetSecondsPerQuestion = (durationMinutes * 60) / totalQuestions;
  final actualSecondsPerQuestion = sessionSeconds / totalQuestions;
  if (targetSecondsPerQuestion <= 0) return null;

  final ratio = actualSecondsPerQuestion / targetSecondsPerQuestion;
  if (ratio > 1.15) return 'Slow';
  if (ratio < 0.85) return 'Fast';
  return 'On pace';
}

// --- Subject List Section ---
class _SubjectListSection extends StatelessWidget {
  final List<String> subjects;
  final int selectedGrade;
  final List<SessionHistoryEntry> historyEntries;

  const _SubjectListSection({
    required this.subjects,
    required this.selectedGrade,
    required this.historyEntries,
  });

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return Center(
        child: Text(
          'No subjects selected for this grade.\nGo to your profile to add subjects.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // Subject color palette - PQP brand colors
    final subjectColors = [
      AppColors.brandCyan, // Cyan - question mark highlight
      AppColors.brandMagenta, // Magenta - playful accent
      AppColors.brandLavender, // Lavender - supportive accent
      AppColors.brandTeal, // Teal - geometric accent
      AppColors.accent, // Orange - primary action
      AppColors.brandCyan, // Repeat for more subjects
      AppColors.brandMagenta,
      AppColors.brandLavender,
    ];

    final subjectOptions = subjects.asMap().entries.map((entry) {
      final index = entry.key;
      final subject = entry.value;
      final isAvailable = AppConstants.isSubjectAvailable(subject);

      return SubjectOption(
        name: subject,
        color: subjectColors[index % subjectColors.length],
        isAvailable: isAvailable,
        subtitle: isAvailable
            ? 'Paper 1 & 2 Available'
            : 'Questions being prepared',
      );
    }).toList();

    final Map<String, SubjectPqpMetrics> pqpMetricsBySubject = {
      for (final subject in subjectOptions)
        subject.name: () {
          final lastPqp = historyEntries
              .where((e) => e.isPastPaper && e.subject == subject.name)
              .cast<SessionHistoryEntry?>()
              .firstWhere((e) => e != null, orElse: () => null);

          if (lastPqp == null) {
            return const SubjectPqpMetrics();
          }

          final unansweredCount = lastPqp.results
              .where((r) => r['wasUnanswered'] == true)
              .length;

          return SubjectPqpMetrics(
            lastScorePercent: lastPqp.percentage.round(),
            paceLabel: _paceLabelForLastPqp(lastPqp),
            unansweredCount: unansweredCount,
          );
        }(),
    };

    return SubjectListView(
      subjects: subjectOptions,
      pqpMetricsBySubject: pqpMetricsBySubject,
      onSubjectSelected: (subject, index) {
        AppHaptics.light();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestConfigurationScreen(
              subject: subject.name,
              grade: selectedGrade,
              subjectColor: subject.color,
            ),
          ),
        );
      },
    );
  }
}

String resolvePreferredFirstName(AppUser? user) {
  final full = _resolveFullName(user);
  final sanitized = full.trim();
  if (sanitized.isEmpty) {
    return 'Student';
  }

  if (sanitized == 'Student') {
    return sanitized;
  }

  if (sanitized.contains(' ')) {
    final first = sanitized.split(RegExp(r'\s+')).first;
    return first.isNotEmpty ? first : 'Student';
  }

  if (sanitized.contains('@')) {
    final first = sanitized.split('@').first;
    return first.isNotEmpty ? first : 'Student';
  }

  return sanitized;
}

String resolveInitials(AppUser? user) {
  final full = _resolveFullName(user);
  final sanitized = full.trim();
  if (sanitized.isEmpty) {
    return 'S';
  }

  if (sanitized.contains('@')) {
    return sanitized.substring(0, 1).toUpperCase();
  }

  final parts = sanitized
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return sanitized.substring(0, 1).toUpperCase();
  }

  if (parts.length == 1) {
    return _initialFromWord(parts.first);
  }

  final firstInitial = _initialFromWord(parts[0]);
  final secondInitial = _initialFromWord(parts[1]);
  final combined = '$firstInitial$secondInitial'.trim();
  return combined.isNotEmpty ? combined : firstInitial;
}

String _resolveFullName(AppUser? user) {
  final name = user?.name?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }

  final email = user?.email?.trim();
  if (email != null && email.isNotEmpty) {
    return email;
  }

  return 'Student';
}

String _initialFromWord(String word) {
  if (word.isEmpty) {
    return '';
  }
  return word.substring(0, 1).toUpperCase();
}
