import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/model/topic.dart';
import 'package:past_question_paper_stem/model/subject.dart';
import 'package:past_question_paper_stem/viewmodels/topic_viewmodel.dart';
import 'package:past_question_paper_stem/viewmodels/home_viewmodel.dart';

class SubjectTopicsScreen extends ConsumerStatefulWidget {
  final Subject subject;

  const SubjectTopicsScreen({super.key, required this.subject});

  @override
  ConsumerState<SubjectTopicsScreen> createState() =>
      _SubjectTopicsScreenState();
}

class _SubjectTopicsScreenState extends ConsumerState<SubjectTopicsScreen> {
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
    final filteredTopics = topicViewModel.getFilteredTopics();

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
                                ? Colors.blue
                                : Colors.grey,
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
                                      ? Colors.purple
                                      : Colors.grey,
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
                : topicState.topics.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                  onRefresh: () async {
                    _loadTopicsForSubject();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filter indicators
                        _buildActiveFilters(),

                        // Topics list
                        _buildTopicsList(filteredTopics),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.topic_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Topics Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Topics for ${widget.subject.name} will appear here when they are added.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadTopicsForSubject(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsList(List<Topic> topics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Topics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...topics.map((topic) => _buildTopicCard(topic)).toList(),
      ],
    );
  }

  Widget _buildTopicCard(Topic topic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.topic, color: Colors.blue.shade600, size: 24),
          ),
          title: Text(
            topic.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                topic.description,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.withOpacity(0.3)),
                    ),
                    child: Text(
                      topic.season,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
          onTap: () {
            // TODO: Navigate to QuestionsScreen where users can filter by:
            // - Question Type (Multiple Choice, Essay, Problem Solving)
            // - Quiz Mode (Rapid Quiz, Exam Session, Practice Mode)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Selected topic: ${topic.name}\nNext: Questions screen with type filtering',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
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

    return Column(
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
              child: const Text('Clear All'),
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
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label),
      onDeleted: onRemove,
      deleteIcon: const Icon(Icons.close, size: 16),
      backgroundColor: Colors.blue.withOpacity(0.1),
      side: BorderSide(color: Colors.blue.withOpacity(0.3)),
    );
  }
}
