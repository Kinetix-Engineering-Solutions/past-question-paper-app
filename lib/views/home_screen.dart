import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/user.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/utils/app_constants.dart';
import 'package:past_question_paper_v1/utils/haptic_feedback.dart';
import 'package:past_question_paper_v1/viewmodels/home_viewmodel.dart';
import 'package:past_question_paper_v1/viewmodels/view_mode_viewmodel.dart';
import 'package:past_question_paper_v1/views/profile_screen.dart';
import 'package:past_question_paper_v1/views/test_configuration_screen.dart';
import 'package:past_question_paper_v1/widgets/subject_3d_carousel.dart';
import 'package:past_question_paper_v1/widgets/subject_list_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final user = homeState.user;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final viewMode = ref.watch(viewModeProvider);

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
          // View mode toggle button
          IconButton(
            tooltip: viewMode.homeViewMode == ViewMode.carousel3D
                ? 'Switch to list view'
                : 'Switch to 3D carousel',
            onPressed: () {
              AppHaptics.light();
              ref.read(viewModeProvider.notifier).toggleHomeViewMode();
            },
            icon: Icon(
              viewMode.homeViewMode == ViewMode.carousel3D
                  ? Icons.view_list
                  : Icons.view_carousel,
            ),
          ),
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: viewMode.homeViewMode == ViewMode.carousel3D
              ? _SubjectCarouselSection(
                  subjects: subjects,
                  selectedGrade: userGrade,
                )
              : _SubjectListSection(
                  subjects: subjects,
                  selectedGrade: userGrade,
                ),
        ),
      ),
    );
  }
}

// --- Subject Carousel Section ---
class _SubjectCarouselSection extends StatelessWidget {
  final List<String> subjects;
  final int selectedGrade;

  const _SubjectCarouselSection({
    required this.subjects,
    required this.selectedGrade,
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

    return Subject3DCarousel(
      subjects: subjectOptions,
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

// --- Subject List Section ---
class _SubjectListSection extends StatelessWidget {
  final List<String> subjects;
  final int selectedGrade;

  const _SubjectListSection({
    required this.subjects,
    required this.selectedGrade,
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

    return SubjectListView(
      subjects: subjectOptions,
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
