import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/utils/app_constants.dart';
import 'package:past_question_paper_v1/viewmodels/auth_viewmodel.dart';
import 'package:past_question_paper_v1/viewmodels/profile_viewmodel.dart';

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
        const SnackBar(
          content: Text('Preferences saved successfully!'),
          backgroundColor: AppColors.accent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving preferences: $e'),
          backgroundColor: Colors.redAccent,
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

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        backgroundColor: AppColors.paper,
        elevation: 0,
        foregroundColor: AppColors.ink,
      ),
      body: userState.when(
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
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
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- User Info Card ---
              Card(
                color: AppColors.neutralCard,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.accentSoft,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name ?? 'Student',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.neutralMid,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Grade Selection ---
              _buildSectionHeader('My Grade'),
              DropdownButtonFormField<int>(
                value: _selectedGrade,
                items:
                    AppConstants.grades.map((grade) {
                      return DropdownMenuItem(
                        value: grade,
                        child: Text('Grade $grade'),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedGrade = value);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.neutralCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.neutralBorder,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Subject Selection ---
              _buildSectionHeader('My Subjects'),
              ...AppConstants.allSubjects.map((subject) {
                return CheckboxListTile(
                  title: Text(subject),
                  value: _selectedSubjects.contains(subject),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedSubjects.add(subject);
                      } else {
                        _selectedSubjects.remove(subject);
                      }
                    });
                  },
                  activeColor: AppColors.accent,
                  controlAffinity: ListTileControlAffinity.leading,
                  tileColor: AppColors.neutralCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }).toList(),
              const SizedBox(height: 32),

              // --- Action Buttons ---
              ElevatedButton(
                onPressed: _isSaving ? null : _savePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isSaving
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : const Text(
                          'Save Preferences',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed:
                    () async =>
                        await authViewModel.signOutUserInUI(context: context),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.ink,
        ),
      ),
    );
  }
}


