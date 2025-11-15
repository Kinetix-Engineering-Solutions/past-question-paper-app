import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/model/user.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/utils/app_constants.dart';
import 'package:past_question_paper_v1/utils/haptic_feedback.dart';
import 'package:past_question_paper_v1/viewmodels/home_viewmodel.dart';
import 'package:past_question_paper_v1/views/profile_screen.dart';
import 'package:past_question_paper_v1/views/test_configuration_screen.dart';

const String _heroImageAsset = 'assets/images/3.png';

const List<double> _grayscaleColorMatrix = <double>[
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0.2126,
  0.7152,
  0.0722,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🚀 MVP Beta Banner
              _BetaBanner(),
              const SizedBox(height: 8),
              _PracticeHero(
                user: user,
                grade: userGrade,
                subjects: subjects,
                onManageTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Your Subjects for Grade $userGrade',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _SubjectList(
                  subjects: subjects,
                  selectedGrade: userGrade,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeHero extends StatelessWidget {
  final AppUser? user;
  final int grade;
  final List<String> subjects;
  final VoidCallback onManageTap;

  const _PracticeHero({
    required this.user,
    required this.grade,
    required this.subjects,
    required this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasSubjects = subjects.isNotEmpty;
    final firstName = resolvePreferredFirstName(user);
    final initials = resolveInitials(user);
    final palette = _HeroPalette.resolve(
      hasSubjects: hasSubjects,
      colorScheme: colorScheme,
    );

    final headline = hasSubjects
        ? 'Consistency builds confidence, $firstName.'
        : 'Set up your study plan, $firstName.';

    final subtitle = hasSubjects
        ? 'Aim for one focused session today—pick any subject below and keep Grade $grade goals in sight.'
        : 'Tell us which subjects you care about so every practice session works harder for you.';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: palette.backgroundColor)),
          if (palette.showHeroImage)
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix(_grayscaleColorMatrix),
                child: Image.asset(
                  _heroImageAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          Positioned.fill(
            child: Container(
              color: palette.showHeroImage
                  ? palette.backgroundColor.withValues(
                      alpha: palette.overlayOpacity,
                    )
                  : Colors.transparent,
            ),
          ),
          if (palette.overlayGradient != null)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: palette.overlayGradient),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: palette.avatarBackground,
                        border: Border.all(
                          color: palette.avatarBorder,
                          width: 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: textTheme.titleMedium?.copyWith(
                          color: palette.headlineColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            headline,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: palette.headlineColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: textTheme.bodyMedium?.copyWith(
                              color: palette.subtitleColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: onManageTap,
                              style: TextButton.styleFrom(
                                foregroundColor: palette.actionColor,
                              ),
                              icon: Icon(
                                Icons.edit_note_outlined,
                                color: palette.actionColor,
                              ),
                              label: Text(
                                hasSubjects
                                    ? 'Manage subjects'
                                    : 'Review profile',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPalette {
  final Color backgroundColor;
  final Color headlineColor;
  final Color subtitleColor;
  final Color actionColor;
  final Color avatarBackground;
  final Color avatarBorder;
  final bool showHeroImage;
  final double overlayOpacity;
  final LinearGradient? overlayGradient;

  const _HeroPalette({
    required this.backgroundColor,
    required this.headlineColor,
    required this.subtitleColor,
    required this.actionColor,
    required this.avatarBackground,
    required this.avatarBorder,
    required this.showHeroImage,
    required this.overlayOpacity,
    required this.overlayGradient,
  });

  factory _HeroPalette.resolve({
    required bool hasSubjects,
    required ColorScheme colorScheme,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;

    if (hasSubjects) {
      if (isDark) {
        final surfaceTone = Color.lerp(
          colorScheme.surface,
          Colors.black,
          0.25,
        )!;
        return _HeroPalette(
          backgroundColor: Color.lerp(AppColors.accent, surfaceTone, 0.75)!,
          headlineColor: AppColorsDark.ink,
          subtitleColor: AppColorsDark.neutralMid,
          actionColor: AppColors.accent,
          avatarBackground: colorScheme.surface.withValues(alpha: 0.35),
          avatarBorder: AppColors.accent.withValues(alpha: 0.3),
          showHeroImage: true,
          overlayOpacity: 0.5,
          overlayGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.55),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        );
      }

      return _HeroPalette(
        backgroundColor: Color.lerp(AppColors.accent, Colors.white, 0.85)!,
        headlineColor: Colors.white,
        subtitleColor: Colors.white.withValues(alpha: 0.92),
        actionColor: AppColors.accent,
        avatarBackground: Colors.white.withValues(alpha: 0.15),
        avatarBorder: AppColors.accent.withValues(alpha: 0.35),
        showHeroImage: true,
        overlayOpacity: 0.65,
        overlayGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.brandCharcoal.withValues(alpha: 0.65),
            AppColors.brandCharcoal.withValues(alpha: 0.45),
            AppColors.brandCharcoal.withValues(alpha: 0.75),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      );
    }

    final baseBackground = isDark
        ? Color.lerp(AppColors.brandCharcoal, colorScheme.surface, 0.35)!
        : AppColors.brandCharcoal;

    return _HeroPalette(
      backgroundColor: baseBackground,
      headlineColor: isDark ? AppColorsDark.ink : AppColors.chalkWhite,
      subtitleColor: (isDark ? AppColorsDark.neutralSoft : AppColors.chalkWhite)
          .withValues(alpha: 0.78),
      actionColor: AppColors.brandTeal,
      avatarBackground: isDark
          ? colorScheme.surface.withValues(alpha: 0.28)
          : AppColors.brandTeal.withValues(alpha: 0.22),
      avatarBorder: AppColors.brandTeal.withValues(alpha: isDark ? 0.4 : 0.55),
      showHeroImage: false,
      overlayOpacity: 0,
      overlayGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          baseBackground,
          Color.lerp(baseBackground, AppColors.brandCharcoal, 0.25)!,
        ],
      ),
    );
  }
}

// --- Helper Widget for Displaying Subjects ---
class _SubjectList extends StatelessWidget {
  final List<String> subjects;
  final int selectedGrade;

  const _SubjectList({required this.subjects, required this.selectedGrade});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (subjects.isEmpty) {
      return Center(
        child: Text(
          'No subjects selected for this grade.\nGo to your profile to add subjects.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        // 🚀 MVP: Check if subject is available
        final isAvailable = AppConstants.isSubjectAvailable(subject);

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide.none,
          ),
          child: Opacity(
            opacity: isAvailable ? 1.0 : 0.6,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      subject,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isAvailable
                            ? null
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (!isAvailable)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accent.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'COMING SOON',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                isAvailable
                    ? 'Paper 1 & 2 Available'
                    : 'Questions being prepared',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Icon(
                isAvailable ? Icons.arrow_forward_ios : Icons.lock_outline,
                color: isAvailable
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 16,
              ),
              onTap: isAvailable
                  ? () {
                      AppHaptics.light();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TestConfigurationScreen(
                            subject: subject,
                            grade: selectedGrade,
                          ),
                        ),
                      );
                    }
                  : null,
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

// 🚀 MVP Beta Banner Widget
class _BetaBanner extends StatelessWidget {
  const _BetaBanner();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Beta Version 0.1',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppConstants.betaMessage,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
