import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/providers/auth_providers.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/utils/app_constants.dart';
import 'package:past_question_paper_v1/views/main_navigation_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // --- Local state for user selections ---
  int? _selectedGrade;
  final List<String> _selectedSubjects = [];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  Future<void> _finishOnboarding() async {
    if (_selectedGrade == null || _selectedSubjects.isEmpty) {
      // Show a snackbar if selections are not made
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your grade and at least one subject.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Save preferences to Firestore using the UserRepository
    try {
      await ref
          .read(userRepositoryProvider)
          .updateUserPreferences(
            grade: _selectedGrade!,
            subjects: _selectedSubjects,
          );

      // Navigate to the main app screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save preferences: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildWelcomePage(),
      _buildGradeSelectionPage(),
      _buildSubjectSelectionPage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: pages,
              ),
            ),
            _buildBottomControls(pages.length),
          ],
        ),
      ),
    );
  }

  // --- Page 1: Welcome ---
  Widget _buildWelcomePage() {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 100, color: AppColors.accent),
          SizedBox(height: 24),
          Text(
            'Welcome to PQP Stem',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Your personal exam practice partner. Let\'s set you up for success.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.neutralMid),
          ),
        ],
      ),
    );
  }

  // --- Page 2: Grade Selection ---
  Widget _buildGradeSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Which grade are you in?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 32),
          ...AppConstants.grades.map((grade) {
            final isAvailable = AppConstants.availableGrades.contains(grade);
            return _buildSelectionChip(
              text: 'Grade $grade',
              isSelected: _selectedGrade == grade,
              isLocked: !isAvailable,
              onTap: isAvailable
                  ? () {
                      setState(() {
                        _selectedGrade = grade;
                      });
                      // Automatically move to the next page after selection
                      Future.delayed(
                        const Duration(milliseconds: 200),
                        () => _nextPage(),
                      );
                    }
                  : null,
            );
          }),
        ],
      ),
    );
  }

  // --- Page 3: Subject Selection ---
  Widget _buildSubjectSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Which subjects are you studying?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select all that apply.',
            style: TextStyle(fontSize: 16, color: AppColors.neutralMid),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: AppConstants.allSubjects.map((subject) {
                final isSelected = _selectedSubjects.contains(subject);
                final isAvailable = AppConstants.availableSubjects.contains(
                  subject.toLowerCase(),
                );
                return _buildSelectionChip(
                  text:
                      subject.substring(0, 1).toUpperCase() +
                      subject.substring(1),
                  isSelected: isSelected,
                  isLocked: !isAvailable,
                  onTap: isAvailable
                      ? () {
                          setState(() {
                            if (isSelected) {
                              _selectedSubjects.remove(subject);
                            } else {
                              _selectedSubjects.add(subject);
                            }
                          });
                        }
                      : null,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- Reusable Chip Widget for Selections ---
  Widget _buildSelectionChip({
    required String text,
    required bool isSelected,
    required VoidCallback? onTap,
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: isLocked
              ? AppColors.neutralBorder.withOpacity(0.3)
              : (isSelected ? AppColors.accentSoft : AppColors.neutralCard),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLocked
                ? AppColors.neutralBorder
                : (isSelected ? AppColors.accent : AppColors.neutralBorder),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: isLocked ? AppColors.neutralSoft : AppColors.ink,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                if (isLocked) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutralMid,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Coming Soon',
                      style: TextStyle(
                        color: AppColors.neutralCard,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (isLocked)
              Icon(Icons.lock_outline, color: AppColors.neutralSoft, size: 20)
            else if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.accent),
          ],
        ),
      ),
    );
  }

  // --- Bottom Controls: Dots and Buttons ---
  Widget _buildBottomControls(int pageCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- Page Indicator Dots ---
          Row(
            children: List.generate(
              pageCount,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? AppColors.accent
                      : AppColors.neutralBorder,
                ),
              ),
            ),
          ),

          // --- Next / Finish Button ---
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: _currentPage == pageCount - 1
                ? _finishOnboarding
                : _nextPage,
            child: Text(
              _currentPage == pageCount - 1 ? 'Get Started' : 'Next',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
