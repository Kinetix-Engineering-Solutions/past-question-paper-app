import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/utils/app_constants.dart';
import 'package:past_question_paper_v1/viewmodels/auth_viewmodel.dart';
import 'package:past_question_paper_v1/viewmodels/profile_viewmodel.dart';
import 'package:past_question_paper_v1/viewmodels/theme_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Local state to manage form changes before saving
  int? _selectedGrade;
  List<String> _selectedSubjects = [];
  bool _isSaving = false;
  PackageInfo? _packageInfo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize local state when user data is first loaded
    final userState = ref.watch(profileViewModelProvider);
    userState.whenData((user) {
      if (_selectedGrade == null && user != null) {
        setState(() {
          _selectedGrade = user.grade ?? AppConstants.grades.first;
          _selectedSubjects = List<String>.from(user.selectedSubjects ?? []);
        });
      }
    });
    
    // Load package info
    if (_packageInfo == null) {
      _loadPackageInfo();
    }
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  Future<void> _savePreferences() async {
    if (_selectedGrade == null) return;

    setState(() => _isSaving = true);
    try {
      await ref
          .read(profileViewModelProvider.notifier)
          .updateUserPreferences(
            grade: _selectedGrade!,
            subjects: _selectedSubjects,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Preferences saved successfully!',
            style: TextStyle(color: AppColors.neutralCard),
          ),
          backgroundColor: AppColors.accent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving preferences: $e',
            style: const TextStyle(color: AppColors.neutralCard),
          ),
          backgroundColor: AppColors.ink,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(profileViewModelProvider);
    final authViewModel = ref.watch(authViewModelProvider.notifier);
    final themeState = ref.watch(themeViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.paperBackground,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        backgroundColor: colorScheme.paperBackground,
        elevation: 0,
        foregroundColor: colorScheme.onBackground,
      ),
      body: userState.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: colorScheme.accentOrange),
        ),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found.'));
          }
          // Initialize state if it hasn't been set yet
          _selectedGrade ??= user.grade ?? AppConstants.grades.first;
          if (_selectedSubjects.isEmpty &&
              (user.selectedSubjects?.isNotEmpty ?? false)) {
            _selectedSubjects = List<String>.from(user.selectedSubjects!);
          }

          return ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              _ProfileSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: colorScheme.cardBackground,
                          child: Icon(
                            Icons.person,
                            size: 36,
                            color: colorScheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name ?? 'Student',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email ?? '',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildInfoChip(
                          context,
                          label:
                              'Grade ${_selectedGrade ?? user.grade ?? AppConstants.grades.first}',
                          icon: Icons.school_outlined,
                        ),
                        if (_selectedSubjects.isEmpty)
                          _buildInfoChip(
                            context,
                            label: 'No subjects selected',
                            icon: Icons.library_add_outlined,
                          )
                        else
                          _buildInfoChip(
                            context,
                            label:
                                '${_selectedSubjects.length} ${_selectedSubjects.length == 1 ? 'subject' : 'subjects'} selected',
                            icon: Icons.bookmark_added_outlined,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _ProfileSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, 'Grade level'),
                    // 🚀 MVP: Show beta message for grade selection
                    if (AppConstants.comingSoonGrades.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.brightness == Brightness.dark
                                ? AppColorsDark.accentSoft
                                : AppColors.accentSoft,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.accent.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Currently: Grade 12 only. Other grades coming soon!',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onBackground,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _selectedGrade,
                      items: AppConstants.grades.map((grade) {
                        // 🚀 MVP: Check if grade is available
                        final isAvailable = AppConstants.isGradeAvailable(
                          grade,
                        );
                        return DropdownMenuItem(
                          value: grade,
                          enabled: isAvailable,
                          child: Row(
                            children: [
                              Text(
                                'Grade $grade',
                                style: TextStyle(
                                  color: isAvailable
                                      ? null
                                      : colorScheme.textSecondary.withOpacity(
                                          0.5,
                                        ),
                                ),
                              ),
                              if (!isAvailable) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.cardBackground,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: colorScheme.borderColor,
                                    ),
                                  ),
                                  child: Text(
                                    'Soon',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        // 🚀 MVP: Only allow changing to available grades
                        if (value != null &&
                            AppConstants.isGradeAvailable(value)) {
                          setState(() => _selectedGrade = value);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.textSecondary,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colorScheme.cardBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      dropdownColor: colorScheme.cardBackground,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _ProfileSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.library_books_outlined,
                          size: 20,
                          color: colorScheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSectionHeader(
                            context,
                            'Subjects I care about',
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Select subjects to personalize your home screen',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.textSecondary,
                      ),
                    ),
                    // 🚀 MVP: Show beta message for subjects
                    if (AppConstants.comingSoonSubjects.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.brightness == Brightness.dark
                                ? AppColorsDark.accentSoft
                                : AppColors.accentSoft,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.accent.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Currently: Mathematics only. Other subjects coming soon!',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onBackground,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildSubjectSelection(context),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _ThemeToggle(mode: themeState.mode),
              const SizedBox(height: 20),

              _ProfileSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, 'Account actions'),
                    if (_hasUnsavedChanges())
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.brightness == Brightness.dark
                              ? AppColorsDark.accentSoft
                              : AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Don\'t forget to save your preferences',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onBackground,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _savePreferences,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.neutralCard,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.neutralCard,
                                ),
                              ),
                            )
                          : const Text(
                              'Save preferences',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () async => await authViewModel
                            .signOutUserInUI(context: context),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.textSecondary,
                        ),
                        child: const Text('Sign out'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Privacy Policy & Terms
              _ProfileSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, 'Legal'),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.privacy_tip_outlined,
                        color: colorScheme.textSecondary,
                      ),
                      title: Text(
                        'Privacy Policy',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Icon(
                        Icons.open_in_new,
                        size: 20,
                        color: colorScheme.textSecondary,
                      ),
                      onTap: () async {
                        try {
                          final uri = Uri.parse(
                            'https://pqp.kinetixes.com/privacy-policy/',
                          );
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not open Privacy Policy'),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // App Version Footer
              if (_packageInfo != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Text(
                          'PQP App',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version ${_packageInfo!.version} (${_packageInfo!.buildNumber})',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.textSecondary.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style:
            Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600) ??
            const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatSubjectLabel(String subject) {
    return subject
        .split(RegExp(r'[ _]+'))
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _normalizeSubject(String subject) => subject.trim().toLowerCase();

  bool _hasUnsavedChanges() {
    final userState = ref.read(profileViewModelProvider);
    return userState.whenOrNull(
          data: (user) {
            if (user == null) return false;

            // Check if grade changed
            if (_selectedGrade != user.grade) return true;

            // Check if subjects changed
            final currentSubjects = user.selectedSubjects ?? [];
            if (_selectedSubjects.length != currentSubjects.length) return true;

            final normalizedCurrent = currentSubjects
                .map(_normalizeSubject)
                .toSet();
            final normalizedSelected = _selectedSubjects
                .map(_normalizeSubject)
                .toSet();

            return !normalizedCurrent.containsAll(normalizedSelected) ||
                !normalizedSelected.containsAll(normalizedCurrent);
          },
        ) ??
        false;
  }

  Widget _buildSubjectSelection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (AppConstants.allSubjects.isEmpty) {
      return Text(
        'No subjects available yet.',
        style: textTheme.bodyMedium?.copyWith(color: colorScheme.textSecondary),
      );
    }

    final normalizedSelected = _selectedSubjects.map(_normalizeSubject).toSet();
    final accentSoft = colorScheme.brightness == Brightness.dark
        ? AppColorsDark.accentSoft
        : AppColors.accentSoft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show selected count
        if (_selectedSubjects.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accentSoft,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_selectedSubjects.length} selected',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Subject chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.allSubjects.map((subject) {
            final normalizedSubject = _normalizeSubject(subject);
            final isSelected = normalizedSelected.contains(normalizedSubject);
            // 🚀 MVP: Check if subject is available
            final isAvailable = AppConstants.isSubjectAvailable(subject);
            final canSelect = isSelected && isAvailable;

            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canSelect)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.neutralCard,
                      ),
                    ),
                  Text(_formatSubjectLabel(subject)),
                  // 🚀 MVP: Show "Coming Soon" badge
                  if (!isAvailable) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.cardBackground,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: colorScheme.borderColor),
                      ),
                      child: Text(
                        'Soon',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selected: canSelect,
              onSelected: isAvailable
                  ? (selected) {
                      setState(() {
                        if (selected) {
                          if (!normalizedSelected.contains(normalizedSubject)) {
                            _selectedSubjects.add(subject);
                          }
                        } else {
                          _selectedSubjects.removeWhere(
                            (item) =>
                                _normalizeSubject(item) == normalizedSubject,
                          );
                        }
                      });
                    }
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              visualDensity: VisualDensity.comfortable,
              showCheckmark: false,
              labelStyle: textTheme.bodyMedium?.copyWith(
                color: !isAvailable
                    ? colorScheme.textSecondary.withOpacity(0.5)
                    : canSelect
                    ? AppColors.neutralCard
                    : colorScheme.onBackground,
                fontWeight: canSelect ? FontWeight.w600 : FontWeight.w500,
              ),
              backgroundColor: colorScheme.cardBackground,
              selectedColor: AppColors.accent,
              disabledColor: colorScheme.cardBackground,
              side: BorderSide(
                color: canSelect ? AppColors.accent : colorScheme.borderColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.borderColor, width: 1),
      ),
      child: child,
    );
  }
}

class _ThemeToggle extends ConsumerWidget {
  const _ThemeToggle({required this.mode});

  final ThemeMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final options = [
      (
        mode: ThemeMode.system,
        label: 'Match device',
        icon: Icons.brightness_auto,
      ),
      (
        mode: ThemeMode.light,
        label: 'Light mode',
        icon: Icons.wb_sunny_outlined,
      ),
      (mode: ThemeMode.dark, label: 'Dark mode', icon: Icons.nightlight_round),
    ];

    return _ProfileSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                mode == ThemeMode.dark
                    ? Icons.nightlight_round
                    : mode == ThemeMode.light
                    ? Icons.wb_sunny
                    : Icons.brightness_auto,
                color: colorScheme.textSecondary,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _labelForMode(mode),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = option.mode == mode;
              return ChoiceChip(
                label: Text(option.label),
                avatar: Icon(
                  option.icon,
                  size: 16,
                  color: isSelected
                      ? AppColors.neutralCard
                      : colorScheme.textSecondary,
                ),
                selected: isSelected,
                onSelected: (_) {
                  ref
                      .read(themeViewModelProvider.notifier)
                      .setThemeMode(option.mode);
                },
                showCheckmark: false,
                labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? AppColors.neutralCard
                      : colorScheme.onBackground,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                backgroundColor: colorScheme.cardBackground,
                selectedColor: AppColors.accent,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.accent
                      : colorScheme.borderColor,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static String _labelForMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Dark mode';
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.system:
        return 'Match device settings';
    }
  }
}
