// features/dashboard/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/subject.dart';
import '../../core/widgets/dashboard/dashboard_app_bar.dart';
import '../../core/widgets/dashboard/progress_tab.dart';
import '../../core/widgets/dashboard/quiz_mode_dialog.dart';
import '../../core/widgets/dashboard/recent_favorites_tab.dart';
import '../../core/widgets/dashboard/subject_list.dart';
import '../../provider/subject_provider.dart';
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _handleClearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _showQuizDialog(BuildContext context, Subject subject) {
    // You should get the selected grade from your grade provider
    // For now, I'm using a default grade - replace this with actual selected grade
    const String selectedGradeId = 'grade_10'; // Replace with actual grade ID
    const String selectedGradeName = 'Grade 10'; // Replace with actual grade name
    
    showDialog(
      context: context,
      builder: (context) => QuizModeDialog(
        subject: subject,
        gradeId: selectedGradeId,
        gradeName: selectedGradeName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedSubjects = ref.watch(selectedSubjectsObjectsProvider);

    final filteredSubjects = _searchQuery.isEmpty
        ? selectedSubjects
        : selectedSubjects.where((subject) =>
            subject.name.toLowerCase().contains(_searchQuery.toLowerCase()));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            DashboardAppBar(
              searchController: _searchController,
              onSearchChanged: _handleSearchChanged,
              onClearSearch: _handleClearSearch,
            ),
            const ProgressTabs(),
            const RecentFavoritesTabs(),
            Expanded(
              child: SubjectList(
                subjects: filteredSubjects.toList(),
                onSubjectTap: (subject) => _showQuizDialog(context, subject),
              ),
            ),
          ],
        ),
      ),
    );
  }
}