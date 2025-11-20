import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/utils/app_constants.dart';
import 'package:past_question_paper_v1/utils/loading_state.dart';
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
  int? _selectedGrade;
  List<String> _selectedSubjects = [];
  bool _isSaving = false;
  PackageInfo? _packageInfo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userState = ref.watch(profileViewModelProvider);
    userState.whenData((user) {
      if (_selectedGrade == null && user != null) {
        setState(() {
          _selectedGrade = user.grade ?? AppConstants.grades.first;
          _selectedSubjects = List<String>.from(user.selectedSubjects ?? []);
        });
      }
    });

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Preferences saved successfully!'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        title: const Text('Settings'),
        backgroundColor: colorScheme.paperBackground,
        elevation: 0,
        foregroundColor: colorScheme.onBackground,
        centerTitle: false,
      ),
      body: userState.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found.'));
          }

          _selectedGrade ??= user.grade ?? AppConstants.grades.first;
          if (_selectedSubjects.isEmpty &&
              (user.selectedSubjects?.isNotEmpty ?? false)) {
            _selectedSubjects = List<String>.from(user.selectedSubjects!);
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // User Profile Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.borderColor, width: 1),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.accent.withOpacity(0.1),
                      child: Text(
                        (user.name ?? 'S').substring(0, 1).toUpperCase(),
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email ?? '',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // App Preferences Section
              _buildSectionTitle(context, 'App Preferences'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.borderColor, width: 1),
                ),
                child: Column(
                  children: [
                    _buildDropdownTile(
                      context,
                      icon: Icons.school_outlined,
                      title: 'Grade',
                      value:
                          'Grade ${_selectedGrade ?? user.grade ?? AppConstants.grades.first}',
                      onTap: () => _showGradeSelector(context),
                    ),
                    _buildDivider(colorScheme),
                    _buildDropdownTile(
                      context,
                      icon: Icons.subject_outlined,
                      title: 'Subjects',
                      value: _selectedSubjects.isEmpty
                          ? 'None selected'
                          : '${_selectedSubjects.length} ${_selectedSubjects.length == 1 ? 'subject' : 'subjects'}',
                      onTap: () => _showSubjectSelector(context),
                    ),
                    _buildDivider(colorScheme),
                    _buildThemeTile(context, themeState.mode),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Support & Legal Section
              _buildSectionTitle(context, 'Support & Legal'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.borderColor, width: 1),
                ),
                child: Column(
                  children: [
                    _buildNavTile(
                      context,
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      iconColor: Colors.orange,
                      onTap: () {
                        // TODO: Navigate to help screen
                      },
                    ),
                    _buildDivider(colorScheme),
                    _buildNavTile(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      iconColor: Colors.red,
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
                    _buildDivider(colorScheme),
                    _buildNavTile(
                      context,
                      icon: Icons.article_outlined,
                      title: 'Terms & Conditions',
                      iconColor: Colors.red,
                      onTap: () {
                        // TODO: Navigate to terms screen
                      },
                    ),
                    _buildDivider(colorScheme),
                    _buildNavTile(
                      context,
                      icon: Icons.info_outline,
                      title: 'About App',
                      iconColor: Colors.red,
                      onTap: () => _showAboutDialog(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Save button if there are unsaved changes
              if (_hasUnsavedChanges()) ...[
                ElevatedButton(
                  onPressed: _isSaving ? null : _savePreferences,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
              ],

              // Sign Out Button
              TextButton(
                onPressed: () async =>
                    await authViewModel.signOutUserInUI(context: context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.red,
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 8),

              // Delete Account Button
              TextButton(
                onPressed: () => _showDeleteAccountDialog(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.red.shade700,
                ),
                child: const Text(
                  'Delete Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 24),

              // App Version Footer
              if (_packageInfo != null)
                Center(
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
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: textTheme.labelLarge?.copyWith(
          color: colorScheme.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDropdownTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.textSecondary, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.textSecondary.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, ThemeMode mode) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    String getModeLabel(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.system:
          return 'System Default';
        case ThemeMode.light:
          return 'Light';
        case ThemeMode.dark:
          return 'Dark';
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showThemeSelector(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                mode == ThemeMode.dark
                    ? Icons.dark_mode_outlined
                    : mode == ThemeMode.light
                    ? Icons.light_mode_outlined
                    : Icons.brightness_auto_outlined,
                color: colorScheme.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      getModeLabel(mode),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.textSecondary.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 24,
                color: colorScheme.textSecondary.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(height: 1, thickness: 1, color: colorScheme.borderColor),
    );
  }

  void _showGradeSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Select Grade',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              ...AppConstants.grades.map((grade) {
                final isAvailable = AppConstants.isGradeAvailable(grade);
                final isSelected = grade == _selectedGrade;

                return ListTile(
                  enabled: isAvailable,
                  leading: Radio<int>(
                    value: grade,
                    groupValue: _selectedGrade,
                    onChanged: isAvailable
                        ? (value) {
                            setState(() => _selectedGrade = value);
                            Navigator.pop(context);
                          }
                        : null,
                    activeColor: AppColors.accent,
                  ),
                  title: Row(
                    children: [
                      Text(
                        'Grade $grade',
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isAvailable
                              ? null
                              : colorScheme.textSecondary.withOpacity(0.5),
                        ),
                      ),
                      if (!isAvailable) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.textSecondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Coming Soon',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: isAvailable
                      ? () {
                          setState(() => _selectedGrade = grade);
                          Navigator.pop(context);
                        }
                      : null,
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showSubjectSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tempSelected = List<String>.from(_selectedSubjects);

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.textSecondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Select Subjects',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose subjects for your personalized experience',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.allSubjects.map((subject) {
                        final isAvailable = AppConstants.isSubjectAvailable(
                          subject,
                        );
                        final isSelected = tempSelected.contains(subject);

                        return FilterChip(
                          label: Text(subject),
                          selected: isSelected && isAvailable,
                          onSelected: isAvailable
                              ? (selected) {
                                  setModalState(() {
                                    if (selected) {
                                      tempSelected.add(subject);
                                    } else {
                                      tempSelected.remove(subject);
                                    }
                                  });
                                }
                              : null,
                          selectedColor: AppColors.accent,
                          backgroundColor: colorScheme.cardBackground,
                          disabledColor: colorScheme.cardBackground,
                          side: BorderSide(
                            color: isSelected && isAvailable
                                ? AppColors.accent
                                : colorScheme.borderColor,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected && isAvailable
                                ? Colors.white
                                : isAvailable
                                ? colorScheme.onBackground
                                : colorScheme.textSecondary.withOpacity(0.5),
                            fontWeight: isSelected && isAvailable
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedSubjects = tempSelected;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showThemeSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentMode = ref.read(themeViewModelProvider).mode;

    final options = [
      (
        mode: ThemeMode.system,
        label: 'System Default',
        icon: Icons.brightness_auto_outlined,
      ),
      (mode: ThemeMode.light, label: 'Light', icon: Icons.light_mode_outlined),
      (mode: ThemeMode.dark, label: 'Dark', icon: Icons.dark_mode_outlined),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Select Theme',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              ...options.map((option) {
                final isSelected = option.mode == currentMode;

                return ListTile(
                  leading: Icon(
                    option.icon,
                    color: isSelected
                        ? AppColors.accent
                        : colorScheme.textSecondary,
                  ),
                  title: Text(
                    option.label,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: AppColors.accent)
                      : null,
                  onTap: () {
                    ref
                        .read(themeViewModelProvider.notifier)
                        .setThemeMode(option.mode);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'PQP App',
      applicationVersion: _packageInfo != null
          ? 'Version ${_packageInfo!.version} (${_packageInfo!.buildNumber})'
          : 'Unknown',
      applicationIcon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.school, size: 32, color: AppColors.accent),
      ),
      children: [
        const Text('Master your exams with Past Question Papers!'),
        const SizedBox(height: 8),
        const Text(
          'Practice with exam-authentic questions across multiple subjects.',
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final passwordController = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: colorScheme.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade700,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Delete Account',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to delete your account?',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This action cannot be undone. All your data including:',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...[
                        'Profile information',
                        'Test history',
                        'Progress data',
                        'Preferences',
                      ]
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(left: 8, top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  const SizedBox(height: 16),
                  Text(
                    'Confirm with your password:',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colorScheme.cardBackground,
                      hintText: 'Enter password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => obscure = !obscure),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.borderColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'will be permanently deleted. Type carefully.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onBackground,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Consumer(
                builder: (context, ref, _) {
                  final isLoading = ref.watch(loadingStateProvider);
                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final pwd = passwordController.text.trim();
                            if (pwd.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Password required to delete account',
                                  ),
                                ),
                              );
                              return;
                            }
                            // Close dialog immediately
                            Navigator.of(dialogContext).pop();

                            // Execute deletion
                            final authViewModel = ref.read(
                              authViewModelProvider.notifier,
                            );
                            await authViewModel.deleteAccountInUI(
                              context: context,
                              password: pwd,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Delete Account',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool _hasUnsavedChanges() {
    final userState = ref.read(profileViewModelProvider);
    return userState.whenOrNull(
          data: (user) {
            if (user == null) return false;
            if (_selectedGrade != user.grade) return true;
            final currentSubjects = user.selectedSubjects ?? [];
            if (_selectedSubjects.length != currentSubjects.length) return true;
            return !Set.from(currentSubjects).containsAll(_selectedSubjects);
          },
        ) ??
        false;
  }
}
