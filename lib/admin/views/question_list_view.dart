import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/viewmodels/question_list_viewmodel.dart';
import 'package:past_question_paper_v1/admin/widgets/question_preview_dialog.dart';
import 'package:past_question_paper_v1/admin/views/parent_question_create_view.dart';
import 'package:past_question_paper_v1/admin/views/question_create_view.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/utils/app_constants.dart';

/// Question Browser/List View - Search, filter, and manage questions
class QuestionListView extends ConsumerStatefulWidget {
  const QuestionListView({super.key});

  @override
  ConsumerState<QuestionListView> createState() => _QuestionListViewState();
}

class _QuestionListViewState extends ConsumerState<QuestionListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionListViewModelProvider);
    final notifier = ref.read(questionListViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Browser'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.refresh(),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
          // Create new question button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const QuestionCreateView(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Question'),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Filter Sidebar
          _buildFilterSidebar(context, state, notifier),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Search bar and stats
                _buildSearchBar(context, state, notifier),

                // Questions table
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.errorMessage != null
                      ? _buildErrorView(context, state.errorMessage!)
                      : state.questions.isEmpty
                      ? _buildEmptyView(context)
                      : _buildQuestionTable(context, state, notifier),
                ),

                // Pagination
                _buildPagination(context, state, notifier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSidebar(
    BuildContext context,
    QuestionListState state,
    QuestionListViewModel notifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = colorScheme.borderColor.withOpacity(
      colorScheme.brightness == Brightness.dark ? 0.6 : 0.3,
    );
    final headingStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    );

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(right: BorderSide(color: borderColor)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: headingStyle.copyWith(fontSize: 18)),
                TextButton(
                  onPressed: () => notifier.clearFilters(),
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const Divider(height: 24),

            // Subject filter
            Text('Subject', style: headingStyle),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: state.filterSubject,
              decoration: const InputDecoration(
                hintText: 'All Subjects',
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Subjects'),
                ),
                ...AppConstants.subjects.map(
                  (s) => DropdownMenuItem(value: s, child: Text(s)),
                ),
              ],
              onChanged: (value) => notifier.updateSubjectFilter(value),
            ),

            const SizedBox(height: 16),

            // Grade filter
            Text('Grade', style: headingStyle),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: state.filterGrade,
              decoration: const InputDecoration(
                hintText: 'All Grades',
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('All Grades'),
                ),
                ...AppConstants.grades.map(
                  (g) => DropdownMenuItem(value: g, child: Text('Grade $g')),
                ),
              ],
              onChanged: (value) => notifier.updateGradeFilter(value),
            ),

            const SizedBox(height: 16),

            // Format filter
            Text('Format', style: headingStyle),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: state.filterFormat,
              decoration: const InputDecoration(
                hintText: 'All Formats',
                isDense: true,
              ),
              items: const [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Formats'),
                ),
                DropdownMenuItem(value: 'MCQ', child: Text('MCQ')),
                DropdownMenuItem(
                  value: 'short_answer',
                  child: Text('Short Answer'),
                ),
                DropdownMenuItem(
                  value: 'drag_drop',
                  child: Text('Drag & Drop'),
                ),
                DropdownMenuItem(
                  value: 'true_false',
                  child: Text('True/False'),
                ),
                DropdownMenuItem(value: 'essay', child: Text('Essay')),
              ],
              onChanged: (value) => notifier.updateFormatFilter(value),
            ),

            const SizedBox(height: 16),

            // Topic filter (conditional)
            if (state.filterSubject != null) ...[
              Text('Topic', style: headingStyle),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: state.filterTopic,
                decoration: const InputDecoration(
                  hintText: 'All Topics',
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Topics'),
                  ),
                  ...(AppConstants.topicsBySubject[state.filterSubject!] ?? [])
                      .map((t) => DropdownMenuItem(value: t, child: Text(t))),
                ],
                onChanged: (value) => notifier.updateTopicFilter(value),
              ),
              const SizedBox(height: 16),
            ],

            // Year filter
            Text('Year', style: headingStyle),
            const SizedBox(height: 8),
            FutureBuilder<List<int>>(
              future: notifier.getAvailableYears(),
              builder: (context, snapshot) {
                final years = snapshot.data ?? [];
                return DropdownButtonFormField<int>(
                  value: state.filterYear,
                  decoration: const InputDecoration(
                    hintText: 'All Years',
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('All Years'),
                    ),
                    ...years.map(
                      (y) =>
                          DropdownMenuItem(value: y, child: Text(y.toString())),
                    ),
                  ],
                  onChanged: (value) => notifier.updateYearFilter(value),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    QuestionListState state,
    QuestionListViewModel notifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = colorScheme.borderColor.withOpacity(
      colorScheme.brightness == Brightness.dark ? 0.6 : 0.3,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by question text, topic, or ID...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          notifier.updateSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
              onChanged: (value) => notifier.updateSearchQuery(value),
            ),
          ),
          const SizedBox(width: 16),
          // Stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              '${state.totalItems} questions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionTable(
    BuildContext context,
    QuestionListState state,
    QuestionListViewModel notifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 24,
          headingRowColor: MaterialStateProperty.all(colorScheme.surface),
          columns: [
            DataColumn(label: Text('ID', style: headerStyle)),
            DataColumn(label: Text('Question', style: headerStyle)),
            DataColumn(label: Text('Subject', style: headerStyle)),
            DataColumn(label: Text('Grade', style: headerStyle)),
            DataColumn(label: Text('Topic', style: headerStyle)),
            DataColumn(label: Text('Format', style: headerStyle)),
            DataColumn(label: Text('Marks', style: headerStyle)),
            DataColumn(label: Text('PQP #', style: headerStyle)),
            DataColumn(label: Text('Actions', style: headerStyle)),
          ],
          rows: state.questions.map((question) {
            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 100,
                    child: Text(
                      question.id.length > 8
                          ? question.id.substring(0, 8)
                          : question.id,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 300,
                    child: Text(
                      question.truncatedText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(Text(question.subject)),
                DataCell(Text('${question.grade}')),
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Text(
                      question.topic,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(_buildFormatBadge(context, question.format)),
                DataCell(Text('${question.marks}')),
                DataCell(Text(question.pqpNumber ?? '—')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Preview button
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 20),
                        onPressed: () => _showPreviewDialog(question),
                        tooltip: 'Preview',
                      ),
                      // Edit button
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _editQuestion(question),
                        tooltip: 'Edit',
                      ),
                      // Delete button
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.red.shade700,
                        ),
                        onPressed: () => _confirmDelete(question, notifier),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFormatBadge(BuildContext context, String format) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final accent = colorScheme.accentOrange;
    final background = accent.withOpacity(isDark ? 0.18 : 0.1);
    final borderColor = accent.withOpacity(isDark ? 0.6 : 0.4);
    final textColor = isDark ? accent : colorScheme.onSurface;

    String label;
    switch (format.toLowerCase()) {
      case 'mcq':
        label = 'MCQ';
        break;
      case 'short_answer':
        label = 'Short Answer';
        break;
      case 'drag_drop':
        label = 'Drag & Drop';
        break;
      case 'true_false':
        label = 'True/False';
        break;
      case 'essay':
        label = 'Essay';
        break;
      default:
        label = format;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPagination(
    BuildContext context,
    QuestionListState state,
    QuestionListViewModel notifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = colorScheme.borderColor.withOpacity(
      colorScheme.brightness == Brightness.dark ? 0.6 : 0.3,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: state.currentPage > 1
                ? () => notifier.previousPage()
                : null,
          ),
          const SizedBox(width: 16),
          Text(
            'Page ${state.currentPage} of ${state.totalPages}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: state.currentPage < state.totalPages
                ? () => notifier.nextPage()
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryColor = colorScheme.textSecondary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: secondaryColor),
          const SizedBox(height: 16),
          Text(
            'No questions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or create a new question',
            style: TextStyle(color: secondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryColor = colorScheme.textSecondary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Error loading questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: secondaryColor)),
        ],
      ),
    );
  }

  void _showPreviewDialog(QuestionListItem question) {
    showDialog(
      context: context,
      builder: (context) => QuestionPreviewDialog(questionId: question.id),
    );
  }

  void _editQuestion(QuestionListItem question) {
    final route = question.isParent
        ? PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ParentQuestionCreateView(parentId: question.id),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          )
        : PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                QuestionCreateView(questionId: question.id),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          );

    Navigator.push(context, route);
  }

  void _confirmDelete(
    QuestionListItem question,
    QuestionListViewModel notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: Text(
          'Are you sure you want to delete this question?\n\n"${question.truncatedText}"\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await notifier.deleteQuestion(question.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Question deleted successfully'
                          : 'Failed to delete question',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }
}
