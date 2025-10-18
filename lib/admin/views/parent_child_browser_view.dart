import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/viewmodels/parent_child_browser_viewmodel.dart';
import 'package:past_question_paper_v1/admin/views/parent_question_create_view.dart';
import 'package:past_question_paper_v1/admin/views/question_create_view.dart';
import 'package:past_question_paper_v1/admin/widgets/question_tree_item.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';

/// Parent-Child Browser View - View and manage parent-child question sets
class ParentChildBrowserView extends ConsumerStatefulWidget {
  const ParentChildBrowserView({super.key});

  @override
  ConsumerState<ParentChildBrowserView> createState() =>
      _ParentChildBrowserViewState();
}

class _ParentChildBrowserViewState
    extends ConsumerState<ParentChildBrowserView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(parentChildBrowserViewModelProvider);
    final notifier = ref.read(parentChildBrowserViewModelProvider.notifier);
    final filteredQuestions = notifier.filteredQuestions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent-Child Question Browser'),
        actions: [
          // Expand/Collapse All
          if (state.filterMode != FilterMode.childrenOnly &&
              state.filterMode != FilterMode.standalone)
            IconButton(
              icon: const Icon(Icons.unfold_more),
              tooltip: 'Expand All',
              onPressed: notifier.expandAll,
            ),
          if (state.filterMode != FilterMode.childrenOnly &&
              state.filterMode != FilterMode.standalone)
            IconButton(
              icon: const Icon(Icons.unfold_less),
              tooltip: 'Collapse All',
              onPressed: notifier.collapseAll,
            ),
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: notifier.loadQuestions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.paper,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                        'Search by PQP number, subject, topic, or question text...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              notifier.setSearchQuery('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: notifier.setSearchQuery,
                ),
                const SizedBox(height: 12),
                // Filter Chips
                Row(
                  children: [
                    const Text(
                      'Show: ',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'All',
                      FilterMode.all,
                      state.filterMode,
                      notifier.setFilterMode,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Parents Only',
                      FilterMode.parentsOnly,
                      state.filterMode,
                      notifier.setFilterMode,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Children Only',
                      FilterMode.childrenOnly,
                      state.filterMode,
                      notifier.setFilterMode,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Standalone',
                      FilterMode.standalone,
                      state.filterMode,
                      notifier.setFilterMode,
                    ),
                    const Spacer(),
                    // Year Filter Dropdown
                    const Text(
                      'Year: ',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButton<int?>(
                        value: state.selectedYear,
                        underline: const SizedBox(),
                        hint: const Text('All Years'),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('All Years'),
                          ),
                          ...notifier.availableYears.map((year) {
                            return DropdownMenuItem<int?>(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }),
                        ],
                        onChanged: notifier.setSelectedYear,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  '${filteredQuestions.length} question(s) found',
                  style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                ),
                const Spacer(),
                if (state.filterMode == FilterMode.all) ...[
                  _buildStatChip(
                    Icons.folder,
                    state.questions.where((q) => q.hasChildren).length,
                    'Parents',
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    Icons.description,
                    state.questions.expand((q) => q.children).length,
                    'Children',
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    Icons.note,
                    state.questions.where((q) => !q.hasChildren).length,
                    'Standalone',
                  ),
                ],
              ],
            ),
          ),

          // Question List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: notifier.loadQuestions,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : filteredQuestions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No questions found',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filter',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredQuestions.length,
                    itemBuilder: (context, index) {
                      final question = filteredQuestions[index];
                      final isExpanded = state.expandedParentIds.contains(
                        question.id,
                      );

                      return QuestionTreeItem(
                        question: question,
                        isExpanded: isExpanded,
                        onToggleExpansion: () =>
                            notifier.toggleParentExpansion(question.id),
                        onDeleteParent: () =>
                            _confirmDeleteParent(question.id, notifier),
                        onDeleteChild: (childId) =>
                            _confirmDeleteChild(childId, question.id, notifier),
                        onEditParent: () =>
                            _navigateToParentOrStandalone(question),
                        onEditChild: (childId) =>
                            _navigateToChildQuestion(childId),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _navigateToParentOrStandalone(ParentQuestionNode question) {
    final route = question.hasChildren
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

  void _navigateToChildQuestion(String childId) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            QuestionCreateView(questionId: childId),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    FilterMode mode,
    FilterMode currentMode,
    Function(FilterMode) onSelected,
  ) {
    final isSelected = mode == currentMode;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(mode),
      selectedColor: AppColors.accent.withOpacity(0.2),
      checkmarkColor: AppColors.accent,
      side: BorderSide(
        color: isSelected ? AppColors.accent : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildStatChip(IconData icon, int count, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteParent(
    String parentId,
    ParentChildBrowserViewModel notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Parent Question'),
        content: const Text(
          'Are you sure you want to delete this parent question?\n\n'
          'This will also delete all its child questions. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await notifier.deleteParent(parentId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parent question deleted')),
        );
      }
    }
  }

  Future<void> _confirmDeleteChild(
    String childId,
    String parentId,
    ParentChildBrowserViewModel notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Child Question'),
        content: const Text(
          'Are you sure you want to delete this child question?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await notifier.deleteChild(childId, parentId);
      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Child question deleted')));
      }
    }
  }
}
