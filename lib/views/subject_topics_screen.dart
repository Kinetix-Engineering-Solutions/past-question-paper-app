import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/subject.dart';
import 'package:past_question_paper_stem/utils/app_colors.dart';
import 'package:past_question_paper_stem/utils/app_theme.dart';
import 'package:past_question_paper_stem/viewmodels/topic_viewmodel.dart';
import 'package:past_question_paper_stem/viewmodels/home_viewmodel.dart';
import 'package:past_question_paper_stem/widgets/custom_tab_bar.dart';
import 'package:past_question_paper_stem/widgets/topics_list_widget.dart';
import 'package:past_question_paper_stem/widgets/materials_widget.dart';

class SubjectTopicsScreen extends ConsumerStatefulWidget {
  final Subject subject;

  const SubjectTopicsScreen({super.key, required this.subject});

  @override
  ConsumerState<SubjectTopicsScreen> createState() =>
      _SubjectTopicsScreenState();
}

class _SubjectTopicsScreenState extends ConsumerState<SubjectTopicsScreen> {
  String? expandedTopicId; // Track which topic is expanded
  int selectedTabIndex = 0; // Track selected tab (0: Topics, 1: Materials)

  @override
  void initState() {
    super.initState();
    // Load topics when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTopicsForSubject();
    });
  }

  void _loadTopicsForSubject() {
    final homeViewModel = ref.read(homeViewModelProvider.notifier);
    final topicViewModel = ref.read(topicViewModelProvider.notifier);

    // Load topics for the specific subject
    final userGrade = homeViewModel.userGrade?.id;
    topicViewModel.loadTopicsForSubject(widget.subject, gradeId: userGrade);
  }

  @override
  Widget build(BuildContext context) {
    final topicState = ref.watch(topicViewModelProvider);
    final topicViewModel = ref.read(topicViewModelProvider.notifier);

    // Listen for errors
    ref.listen(topicViewModelProvider, (previous, current) {
      if (current.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(current.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () => topicViewModel.clearError(),
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.name),
        centerTitle: true,
        actions: [
          // Season filter dropdown
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Filter by Season',
            onSelected: (String season) {
              final topicViewModel = ref.read(topicViewModelProvider.notifier);
              if (season == 'all') {
                topicViewModel.setSeasonFilter(null);
              } else {
                topicViewModel.setSeasonFilter(season);
              }
            },
            itemBuilder: (BuildContext context) {
              final topicViewModel = ref.read(topicViewModelProvider.notifier);
              final topicState = ref.read(topicViewModelProvider);
              final seasons = topicViewModel.getAvailableSeasons();

              return [
                PopupMenuItem<String>(
                  value: 'all',
                  child: Row(
                    children: [
                      Icon(
                        topicState.selectedSeason == null
                            ? Icons.check
                            : Icons.radio_button_unchecked,
                        color:
                            topicState.selectedSeason == null
                                ? Colors.orange
                                : AppColors.neutralCard,
                      ),
                      const SizedBox(width: 8),
                      const Text('All Seasons'),
                    ],
                  ),
                ),
                if (seasons.isNotEmpty) const PopupMenuDivider(),
                ...seasons
                    .map(
                      (season) => PopupMenuItem<String>(
                        value: season,
                        child: Row(
                          children: [
                            Icon(
                              topicState.selectedSeason == season
                                  ? Icons.check
                                  : Icons.radio_button_unchecked,
                              color:
                                  topicState.selectedSeason == season
                                      ? Colors.orange
                                      : AppColors.neutralMid,
                            ),
                            const SizedBox(width: 8),
                            Text(season),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ];
            },
          ),
        ],
      ),
      body: SafeArea(
        child:
            topicState.isLoading
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading topics...'),
                    ],
                  ),
                )
                : Column(
                  children: [
                    // Custom Tab Bar
                    CustomTabBar(
                      tabs: const ['Topics', 'Materials'],
                      selectedIndex: selectedTabIndex,
                      onTabSelected: (index) {
                        setState(() {
                          selectedTabIndex = index;
                          expandedTopicId =
                              null; // Collapse any expanded topic when switching tabs
                        });
                      },
                    ),

                    // Active filters (only show for topics tab)
                    if (selectedTabIndex == 0) _buildActiveFilters(),

                    // Tab content
                    Expanded(
                      child:
                          selectedTabIndex == 0
                              ? RefreshIndicator(
                                onRefresh: () async {
                                  _loadTopicsForSubject();
                                },
                                child: TopicsListWidget(
                                  topics: topicViewModel.getFilteredTopics(),
                                  subject: widget.subject,
                                  expandedTopicId: expandedTopicId,
                                  onTopicExpanded: (topicId) {
                                    setState(() {
                                      expandedTopicId = topicId;
                                    });
                                  },
                                ),
                              )
                              : MaterialsWidget(subject: widget.subject),
                    ),
                  ],
                ),
      ),
    );
  }

  // Show active filters
  Widget _buildActiveFilters() {
    final topicState = ref.watch(topicViewModelProvider);
    final topicViewModel = ref.read(topicViewModelProvider.notifier);

    if (topicState.selectedSeason == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Active Filters:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => topicViewModel.clearFilters(),
                child: Text(
                  'Clear All',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (topicState.selectedSeason != null)
                _buildFilterChip(
                  'Season: ${topicState.selectedSeason}',
                  () => topicViewModel.setSeasonFilter(null),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label, style: TextStyle(color: Colors.orange)),
      onDeleted: onRemove,
      deleteIcon: Icon(Icons.close, size: 16, color: Colors.orange),
      backgroundColor: Colors.orange.withOpacity(0.1),
      side: BorderSide(color: Colors.orange.withOpacity(0.3)),
    );
  }
}
