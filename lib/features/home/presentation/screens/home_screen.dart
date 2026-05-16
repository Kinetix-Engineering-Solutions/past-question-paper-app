import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:past_question_paper_v1/core/shared/models/app_metadata.dart';
import 'package:past_question_paper_v1/features/profile/domain/entities/user.dart';
import 'package:past_question_paper_v1/core/theme/app_colors.dart';
import 'package:past_question_paper_v1/core/shared/utils/haptic_feedback.dart';
import 'package:past_question_paper_v1/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:past_question_paper_v1/features/home/presentation/viewmodels/app_metadata_viewmodel.dart';
import 'package:past_question_paper_v1/features/history/presentation/viewmodels/session_history_viewmodel.dart';
import 'package:past_question_paper_v1/features/flashcards/presentation/screens/flashcard_screen.dart';
import 'package:past_question_paper_v1/core/shared/widgets/ad_banner_slot.dart';
import 'package:past_question_paper_v1/core/shared/services/ads_service.dart';

final _homeSelectedSubjectProvider = StateProvider<String>(
  (ref) => '', // Will be set to first subject on metadata load
);
final _homeSearchQueryProvider = StateProvider<String>((ref) => '');
final _homeSortByProvider = StateProvider<String>((ref) => 'A-Z');

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appMetadataViewModelProvider.notifier).refresh();
      _showFirstLaunchDialogIfNeeded();
    });
  }

  Future<void> _showFirstLaunchDialogIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenFirstLaunchDialog = prefs.getBool('hasSeenFirstLaunchDialog') ?? false;

      if (!hasSeenFirstLaunchDialog && mounted) {
        await prefs.setBool('hasSeenFirstLaunchDialog', true);
        _showFirstLaunchDialog();
      }
    } catch (e) {
      // Silently fail if SharedPreferences has issues
    }
  }

  void _showFirstLaunchDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.info_outline,
          color: AppColors.accent,
          size: 28,
        ),
        title: Text(
          'Welcome',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Topics are organized according to the structure of NSC South African exam papers. '
          'You\'ll find the exact topics as they appear in official examination papers to help you prepare effectively.',
          style: textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final ref = this.ref; // keep API compatible with previous build signature
    final homeState = ref.watch(homeViewModelProvider);
    final metadataState = ref.watch(appMetadataViewModelProvider);
    final asyncHistory = ref.watch(sessionHistoryViewModelProvider);
    final user = homeState.user;
    final selectedSubject = ref.watch(_homeSelectedSubjectProvider);
    final searchQuery = ref.watch(_homeSearchQueryProvider);
    final sortBy = ref.watch(_homeSortByProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (metadataState.isLoading && metadataState.metadata == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (metadataState.metadata == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  metadataState.errorMessage ??
                      'Please connect to the internet to download your subjects for the first time.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.read(appMetadataViewModelProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final preferredSubjects = _resolvePreferredSubjects(
      user,
      metadataState.metadata!,
    );
    
    // Auto-select first subject if not yet selected
    if (selectedSubject.isEmpty && preferredSubjects.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(_homeSelectedSubjectProvider.notifier).state = preferredSubjects.first;
      });
    }
    
    final allTopics = _buildTopicItems(
      metadataState.metadata!,
      preferredSubjects,
    );
    final visibleTopics = _applyFilters(
      topics: allTopics,
      selectedSubject: selectedSubject.isEmpty ? (preferredSubjects.isNotEmpty ? preferredSubjects.first : '') : selectedSubject,
      searchQuery: searchQuery,
      sortBy: sortBy,
    );

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        automaticallyImplyLeading: false,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Past Question Papers',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Browse past paper topics',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh topics',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(appMetadataViewModelProvider.notifier).refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            asyncHistory.when(
              loading: () => const LinearProgressIndicator(minHeight: 2),
              error: (error, stackTrace) => _HistoryStatusBanner(
                message: 'Could not load recent progress.',
                actionLabel: 'Retry',
                onAction: () => ref
                    .read(sessionHistoryViewModelProvider.notifier)
                    .refresh(),
              ),
              data: (_) => const SizedBox.shrink(),
            ),
            Expanded(
              child: _TopicDiscoverySection(
                subjects: preferredSubjects,
                selectedSubject: selectedSubject,
                searchQuery: searchQuery,
                sortBy: sortBy,
                topics: visibleTopics,
                totalTopicCount: allTopics.length,
                onSubjectChanged: (subject) {
                  ref.read(_homeSelectedSubjectProvider.notifier).state =
                      subject;
                },
                onSearchChanged: (query) {
                  ref.read(_homeSearchQueryProvider.notifier).state = query;
                },
                onSortChanged: (sort) {
                  ref.read(_homeSortByProvider.notifier).state = sort;
                },
                onTopicTap: (topic) {
                  AppHaptics.light();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FlashcardScreen(
                        subjectId: topic.subject,
                        topicId: _toTopicId(topic.topic),
                        topicTitle: topic.topic,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _resolvePreferredSubjects(AppUser? user, AppMetadata metadata) {
    // For now, always use the subjects defined in remote metadata so
    // the UI shows all available subjects (e.g., Mathematics, Physical Sciences).
    final all = metadata.subjects.map((s) => s.id).toList()..sort();
    return all;
  }

  List<_TopicHomeItem> _buildTopicItems(
    AppMetadata metadata,
    List<String> subjects,
  ) {
    final items = <_TopicHomeItem>[];

    final byId = {for (final subject in metadata.subjects) subject.id: subject};

    for (final subject in subjects) {
      final topics = byId[subject]?.topics ?? const <String>[];
      for (final topic in topics) {
        final hashSeed = '$subject::$topic';
        final estimatedQuestions = 8 + (hashSeed.hashCode.abs() % 28);
        items.add(
          _TopicHomeItem(
            subject: subject,
            topic: topic,
            estimatedQuestions: estimatedQuestions,
            isSubjectAvailable: true,
          ),
        );
      }
    }

    return items;
  }

  List<_TopicHomeItem> _applyFilters({
    required List<_TopicHomeItem> topics,
    required String selectedSubject,
    required String searchQuery,
    required String sortBy,
  }) {
    var filtered = topics;

    // Always filter by selected subject (no "All" option anymore)
    if (selectedSubject.isNotEmpty) {
      filtered = filtered
          .where((topic) => topic.subject == selectedSubject)
          .toList();
    }

    final query = searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where(
            (topic) =>
                topic.topic.toLowerCase().contains(query) ||
                topic.subject.toLowerCase().contains(query),
          )
          .toList();
    }

    filtered.sort((a, b) {
      switch (sortBy) {
        case 'Most questions':
          return b.estimatedQuestions.compareTo(a.estimatedQuestions);
        case 'Available first':
          if (a.isSubjectAvailable == b.isSubjectAvailable) {
            return a.topic.compareTo(b.topic);
          }
          return a.isSubjectAvailable ? -1 : 1;
        case 'A-Z':
        default:
          return a.topic.compareTo(b.topic);
      }
    });

    return filtered;
  }
}

class _TopicHomeItem {
  final String subject;
  final String topic;
  final int estimatedQuestions;
  final bool isSubjectAvailable;

  const _TopicHomeItem({
    required this.subject,
    required this.topic,
    required this.estimatedQuestions,
    required this.isSubjectAvailable,
  });
}

class _TopicDiscoverySection extends StatelessWidget {
  final List<String> subjects;
  final String selectedSubject;
  final String searchQuery;
  final String sortBy;
  final List<_TopicHomeItem> topics;
  final int totalTopicCount;
  final ValueChanged<String> onSubjectChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<_TopicHomeItem> onTopicTap;

  const _TopicDiscoverySection({
    required this.subjects,
    required this.selectedSubject,
    required this.searchQuery,
    required this.sortBy,
    required this.topics,
    required this.totalTopicCount,
    required this.onSubjectChanged,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onTopicTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (subjects.isEmpty || totalTopicCount == 0) {
      return Center(
        child: Text(
          'No preferred subjects found yet.\nSet your subjects in profile to personalize topics.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showFiltersBottomSheet(
              context: context,
              subjects: subjects,
              selectedSubject: selectedSubject,
              searchQuery: searchQuery,
              sortBy: sortBy,
              onSubjectChanged: onSubjectChanged,
              onSearchChanged: onSearchChanged,
              onSortChanged: onSortChanged,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filters',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _filterSummaryText(
                          selectedSubject: selectedSubject,
                          searchQuery: searchQuery,
                          sortBy: sortBy,
                        ),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.tune,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Showing ${topics.length} of $totalTopicCount topics',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(
          child: topics.isEmpty
              ? Center(
                  child: Text(
                    'No topics match these filters.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: topics.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = topics[index];
                    final leadingColor = item.isSubjectAvailable
                        ? AppColors.accent
                        : colorScheme.outline;

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => onTopicTap(item),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: leadingColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.topic,
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        _TopicMetaTag(
                                          label: _toDisplayCase(item.subject),
                                          background:
                                              colorScheme.surfaceVariant,
                                          foreground:
                                              colorScheme.onSurfaceVariant,
                                        ),
                                        _TopicMetaTag(
                                          label: 'Past paper questions',
                                          background: colorScheme.primary
                                              .withOpacity(0.10),
                                          foreground: colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: AdBannerSlot(placement: AppAdPlacement.home),
        ),
      ],
    );
  }

  String _filterSummaryText({
    required String selectedSubject,
    required String searchQuery,
    required String sortBy,
  }) {
    final subjectLabel = _toDisplayCase(selectedSubject).isNotEmpty
        ? _toDisplayCase(selectedSubject)
        : 'Select subject';
    final parts = <String>[subjectLabel];
    parts.add(sortBy);
    final trimmedSearch = searchQuery.trim();
    if (trimmedSearch.isNotEmpty) {
      parts.add('Search: $trimmedSearch');
    }

    return parts.join(' • ');
  }

  void _showFiltersBottomSheet({
    required BuildContext context,
    required List<String> subjects,
    required String selectedSubject,
    required String searchQuery,
    required String sortBy,
    required ValueChanged<String> onSubjectChanged,
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<String> onSortChanged,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      builder: (bottomSheetContext) => _FiltersBottomSheet(
        subjects: subjects,
        selectedSubject: selectedSubject,
        searchQuery: searchQuery,
        sortBy: sortBy,
        onSubjectChanged: onSubjectChanged,
        onSearchChanged: onSearchChanged,
        onSortChanged: onSortChanged,
      ),
    );
  }
}

class _TopicMetaTag extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _TopicMetaTag({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FiltersBottomSheet extends StatefulWidget {
  final List<String> subjects;
  final String selectedSubject;
  final String searchQuery;
  final String sortBy;
  final ValueChanged<String> onSubjectChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSortChanged;

  const _FiltersBottomSheet({
    required this.subjects,
    required this.selectedSubject,
    required this.searchQuery,
    required this.sortBy,
    required this.onSubjectChanged,
    required this.onSearchChanged,
    required this.onSortChanged,
  });

  @override
  State<_FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<_FiltersBottomSheet> {
  late final TextEditingController _searchController;
  late String _tempSubject;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _tempSubject = widget.selectedSubject;
  }

  @override
  void didUpdateWidget(covariant _FiltersBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSubject != widget.selectedSubject &&
        _tempSubject == oldWidget.selectedSubject) {
      _tempSubject = widget.selectedSubject;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Filters',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Search',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _searchController,
              onChanged: widget.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search topics...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.trim().isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearchChanged('');
                          setState(() {});
                        },
                      )
                    : null,
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sort',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: widget.sortBy,
              decoration: const InputDecoration(isDense: true),
              items: const [
                DropdownMenuItem(value: 'A-Z', child: Text('A-Z')),
                DropdownMenuItem(
                  value: 'Most questions',
                  child: Text('Most questions'),
                ),
                DropdownMenuItem(
                  value: 'Available first',
                  child: Text('Available first'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  widget.onSortChanged(value);
                }
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Subject',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ...widget.subjects.map(
                    (subject) => _buildSubjectSheetTile(
                      context: context,
                      label: _toDisplayCase(subject),
                      selected: _tempSubject == subject,
                      onTap: () {
                        setState(() => _tempSubject = subject);
                        widget.onSubjectChanged(subject);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectSheetTile({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_circle, color: AppColors.accent)
          : Icon(Icons.circle_outlined, color: colorScheme.outline),
      onTap: onTap,
    );
  }
}

String _toDisplayCase(String text) {
  return text
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

String _toTopicId(String topicTitle) {
  return topicTitle
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

class _HistoryStatusBanner extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _HistoryStatusBanner({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: colorScheme.onErrorContainer,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String resolvePreferredFirstName(AppUser? user) {
  final full = _resolveFullName(user);
  final sanitized = full.trim();
  if (sanitized.isEmpty) {
    return 'Student';
  }

  if (sanitized == 'Student') {
    return sanitized;
  }

  if (sanitized.contains(' ')) {
    final first = sanitized.split(RegExp(r'\s+')).first;
    return first.isNotEmpty ? first : 'Student';
  }

  if (sanitized.contains('@')) {
    final first = sanitized.split('@').first;
    return first.isNotEmpty ? first : 'Student';
  }

  return sanitized;
}

String resolveInitials(AppUser? user) {
  final full = _resolveFullName(user);
  final sanitized = full.trim();
  if (sanitized.isEmpty) {
    return 'S';
  }

  if (sanitized.contains('@')) {
    return sanitized.substring(0, 1).toUpperCase();
  }

  final parts = sanitized
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return sanitized.substring(0, 1).toUpperCase();
  }

  if (parts.length == 1) {
    return _initialFromWord(parts.first);
  }

  final firstInitial = _initialFromWord(parts[0]);
  final secondInitial = _initialFromWord(parts[1]);
  final combined = '$firstInitial$secondInitial'.trim();
  return combined.isNotEmpty ? combined : firstInitial;
}

String _resolveFullName(AppUser? user) {
  final name = user?.name?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }

  final email = user?.email?.trim();
  if (email != null && email.isNotEmpty) {
    return email;
  }

  return 'Student';
}

String _initialFromWord(String word) {
  if (word.isEmpty) {
    return '';
  }
  return word.substring(0, 1).toUpperCase();
}
