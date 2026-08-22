import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/app_user.dart';
import '../domain/learner_profile.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({required this.user, super.key});

  final AppUser user;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();

  bool _initialised = false;
  int _selectedGrade = 12;

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = profileControllerProvider(widget.user.id);
    final profile = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: FilledButton.icon(
            onPressed: () {
              ref.invalidate(provider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry profile'),
          ),
        ),
        data: (value) {
          _initialise(value);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    helperText:
                        'This name may be shown with '
                        'future community activity.',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textInputAction: TextInputAction.next,
                  maxLength: 40,
                  validator: (value) {
                    final name = value?.trim() ?? '';

                    if (name.length < 2) {
                      return 'Enter at least 2 characters.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _selectedGrade,
                  decoration: const InputDecoration(
                    labelText: 'Current grade',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 10, child: Text('Grade 10')),
                    DropdownMenuItem(value: 11, child: Text('Grade 11')),
                    DropdownMenuItem(value: 12, child: Text('Grade 12')),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _selectedGrade = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save profile'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _initialise(LearnerProfile profile) {
    if (_initialised) {
      return;
    }

    _displayNameController.text = profile.displayName ?? '';
    _selectedGrade = profile.grade ?? 12;
    _initialised = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = profileControllerProvider(widget.user.id);

    await ref
        .read(provider.notifier)
        .updateProfile(
          displayName: _displayNameController.text,
          grade: _selectedGrade,
        );

    if (!mounted) {
      return;
    }

    final result = ref.read(provider);

    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save your profile.')),
      );

      ref.invalidate(provider);
      return;
    }

    Navigator.of(context).pop();
  }
}
