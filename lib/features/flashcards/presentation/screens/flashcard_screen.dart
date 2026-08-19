import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:past_question_paper_v1/core/shared/models/flashcard_load_state.dart';
import 'package:past_question_paper_v1/core/shared/models/rest_question_query.dart';
import 'package:past_question_paper_v1/core/shared/repositories/rest_questions_repository.dart';
import 'package:past_question_paper_v1/core/shared/services/ads_service.dart';
import 'package:past_question_paper_v1/core/shared/services/rest_questions_api_service.dart';
import 'package:past_question_paper_v1/core/shared/widgets/ad_banner_slot.dart';
import 'package:past_question_paper_v1/core/theme/app_colors.dart';
import 'package:past_question_paper_v1/features/auth/presentation/screens/login.dart';
import 'package:past_question_paper_v1/features/auth/providers/auth_providers.dart';
import 'package:past_question_paper_v1/features/flashcards/presentation/widgets/flashcard_meta_chip.dart';
import 'package:past_question_paper_v1/features/flashcards/presentation/widgets/flashcard_question_image.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  final String subjectId;
  final String topicId;
  final String? topicTitle;
  final String? initialPaper;
  final RestQuestionsRepository? questionsRepository;

  const FlashcardScreen({
    super.key,
    required this.subjectId,
    required this.topicId,
    this.topicTitle,
    this.initialPaper,
    this.questionsRepository,
  });

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardFilters {
  final int? year;
  final String? season;
  final String? questionNumber;
  final String? questionPrefix;

  const _FlashcardFilters({
    required this.year,
    required this.season,
    required this.questionNumber,
    required this.questionPrefix,
  });
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  FlashcardLoadState _loadState = const FlashcardLoadState.initial();
  final PageController _pageController = PageController();
  late final RestQuestionsRepository _questionsRepository;
  int _latestRequestId = 0;

  static const int _interstitialSwipeInterval = 6;
  final AdsService _adsService = AdsService.instance;
  int _swipeCount = 0;
  int _lastPageIndex = 0;

  static const int _pageLimit = 50;
  int _pageOffset = 0;

  int? _selectedYear; // null = Any
  String? _selectedPaper; // null = Any
  String? _selectedSeason; // null = Any
  String? _selectedQuestionNumber; // null = Any
  String? _selectedQuestionPrefix; // null = Any

  final TextEditingController _commentController = TextEditingController();
  final List<_CommunityComment> _communityComments = [
    _CommunityComment(
      id: 'c1',
      questionId: 'sample-1',
      authorName: 'Thandi M.',
      textContent:
          'Quick tip: isolate the variable and check units before substituting.',
      upvotes: 14,
      createdAt: DateTime(2025, 10, 5, 10, 12),
    ),
    _CommunityComment(
      id: 'c2',
      questionId: 'sample-1',
      authorName: 'Neo P.',
      audioUrl: 'https://example.com/audio/voice-note.m4a',
      textContent: 'Short walkthrough of the memo logic.',
      upvotes: 9,
      createdAt: DateTime(2025, 10, 6, 9, 30),
    ),
    _CommunityComment(
      id: 'c3',
      questionId: 'sample-1',
      authorName: 'Aisha L.',
      externalVideoUrl: 'https://youtube.com/watch?v=dQw4w9WgXcQ',
      videoThumbnailUrl: 'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
      textContent: 'Video breakdown with step-by-step reasoning.',
      upvotes: 21,
      createdAt: DateTime(2025, 10, 6, 14, 5),
    ),
  ];

  static const List<String> _seasonOptions = <String>[
    'Any',
    'May/June',
    'Oct/Nov',
    'Feb/March',
  ];

  @override
  void initState() {
    super.initState();
    _questionsRepository =
        widget.questionsRepository ?? RestQuestionsRepository();
    _selectedPaper = widget.initialPaper;
    _adsService.preloadInterstitial(AppInterstitialPlacement.flashcard);
    fetchQuestions();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  bool _isLoggedIn(AsyncValue<dynamic> authState) {
    return authState.maybeWhen(
      data: (user) => user != null,
      orElse: () => false,
    );
  }

  Future<void> _showLoginPrompt() async {
    final colorScheme = Theme.of(context).colorScheme;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Login required'),
          content: const Text(
            'Sign in to access AI explanations, voice notes, and community discussions.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requireLoginOrPrompt(VoidCallback action) async {
    final authState = ref.read(authStateProvider);
    final loggedIn = _isLoggedIn(authState);
    if (!loggedIn) {
      await _showLoginPrompt();
      return;
    }
    action();
  }

  void _showInfoSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<_CommunityComment> _sortedCommentsForQuestion(String questionId) {
    final comments = _communityComments
        .where((comment) => comment.questionId == questionId)
        .toList();
    comments.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    return comments;
  }

  void _applyVote(_CommunityComment comment, int delta) {
    setState(() {
      final index = _communityComments.indexWhere((c) => c.id == comment.id);
      if (index == -1) return;
      final updated = _communityComments[index].copyWith(
        upvotes: (_communityComments[index].upvotes + delta).clamp(0, 9999),
      );
      _communityComments[index] = updated;
    });
  }

  Future<void> _openLinkModal({required String questionId}) async {
    final controller = TextEditingController();
    final url = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Share a video link',
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'YouTube or TikTok URL',
                  hintText: 'https://youtube.com/watch?v=...',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(
                        sheetContext,
                      ).pop(controller.text.trim()),
                      child: const Text('Add Link'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();

    final normalized = url?.trim();
    if (normalized == null || normalized.isEmpty) return;

    setState(() {
      _communityComments.add(
        _CommunityComment(
          id: 'c${DateTime.now().millisecondsSinceEpoch}',
          questionId: questionId,
          authorName: 'You',
          externalVideoUrl: normalized,
          videoThumbnailUrl: null,
          textContent: 'Shared a video explanation.',
          upvotes: 0,
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  String? _normalizeNullableText(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  String _buildUserFacingError(Object error) {
    if (error is RestApiException) {
      return error.toUserMessage();
    }

    if (error is ArgumentError) {
      return error.message?.toString() ?? 'Invalid filter values provided.';
    }

    return 'Something went wrong while loading questions. Please try again.';
  }

  String get _questionFilterSummary {
    if (_selectedQuestionNumber != null) {
      return _selectedQuestionNumber!;
    }

    if (_selectedQuestionPrefix != null) {
      return '${_selectedQuestionPrefix!}*';
    }

    return 'Any';
  }

  Widget _buildActiveFilterSummary() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        children: [
          FlashcardMetaChip(
            label: 'Year',
            value: _selectedYear?.toString() ?? 'Any',
          ),
          const SizedBox(width: 8),
          FlashcardMetaChip(label: 'Season', value: _selectedSeason ?? 'Any'),
          const SizedBox(width: 8),
          FlashcardMetaChip(label: 'Q', value: _questionFilterSummary),
          if (_selectedPaper != null) ...[
            const SizedBox(width: 8),
            FlashcardMetaChip(label: 'Paper', value: _selectedPaper!),
          ],
        ],
      ),
    );
  }

  Future<void> fetchQuestions() async {
    final requestId = ++_latestRequestId;
    _pageOffset = 0;
    _swipeCount = 0;
    _lastPageIndex = 0;

    setState(() {
      _loadState = _loadState.copyWith(isLoading: true, clearUserMessage: true);
    });

    try {
      final selectedYear = _selectedYear;
      final fetched = await _questionsRepository.fetchFlashcardQuestions(
        RestQuestionQuery(
          subject: widget.subjectId,
          grade: 12,
          topic: widget.topicId,
          startYear: selectedYear,
          endYear: selectedYear,
          paper: _selectedPaper,
          season: _selectedSeason,
          questionNumber: _selectedQuestionNumber,
          questionPrefix: _selectedQuestionPrefix,
        ),
        limit: _pageLimit,
        offset: _pageOffset,
      );

      if (!mounted || requestId != _latestRequestId) return;

      final shuffled = List.of(fetched)..shuffle();

      setState(() {
        _loadState = FlashcardLoadState.loaded(shuffled);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || requestId != _latestRequestId) return;
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      });
    } catch (e) {
      if (!mounted || requestId != _latestRequestId) return;
      setState(() {
        _loadState = FlashcardLoadState.error(_buildUserFacingError(e));
      });
    }
  }

  List<int> _buildYearOptions() {
    final currentYear = DateTime.now().year;
    return List.generate(
      10,
      (index) => currentYear - index - 1,
    ).where((year) => year > 2000).toList();
  }

  Future<void> _openFiltersSheet() async {
    final years = _buildYearOptions();

    final result = await showModalBottomSheet<_FlashcardFilters>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        int? tempYear = _selectedYear;
        String? tempSeason = _selectedSeason;
        String? tempQuestionNumber = _selectedQuestionNumber;
        String? tempQuestionPrefix = _selectedQuestionPrefix;

        Widget buildChoiceGroup({
          required String label,
          required List<String> options,
          required String? selected,
          required void Function(String?) onSelected,
        }) {
          final colorScheme = Theme.of(sheetContext).colorScheme;
          final textTheme = Theme.of(sheetContext).textTheme;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((value) {
                  final isAny = value == 'Any';
                  final valueKey = isAny ? null : value;
                  final isSelected = selected == valueKey;
                  return ChoiceChip(
                    label: Text(value),
                    selected: isSelected,
                    selectedColor: colorScheme.primaryContainer,
                    backgroundColor: colorScheme.surfaceContainerLow,
                    labelStyle: textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => onSelected(valueKey),
                  );
                }).toList(),
              ),
            ],
          );
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int?>(
                      initialValue: tempYear,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Any year'),
                        ),
                        ...years.map(
                          (y) => DropdownMenuItem<int?>(
                            value: y,
                            child: Text(y.toString()),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setModalState(() => tempYear = value),
                      decoration: const InputDecoration(labelText: 'Year'),
                    ),
                    const SizedBox(height: 16),
                    buildChoiceGroup(
                      label: 'Season',
                      options: _seasonOptions,
                      selected: tempSeason,
                      onSelected: (value) =>
                          setModalState(() => tempSeason = value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: tempQuestionNumber,
                      decoration: const InputDecoration(
                        labelText: 'Exact question number',
                        hintText: 'e.g. 1.1.1',
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: (value) => tempQuestionNumber = value,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: tempQuestionPrefix,
                      decoration: const InputDecoration(
                        labelText: 'Question prefix',
                        hintText: 'e.g. 1.1. or 2.',
                      ),
                      onChanged: (value) => tempQuestionPrefix = value,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              final normalizedQuestionNumber =
                                  _normalizeNullableText(tempQuestionNumber);
                              final normalizedQuestionPrefix =
                                  _normalizeNullableText(tempQuestionPrefix);

                              if (normalizedQuestionNumber != null &&
                                  normalizedQuestionPrefix != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Use either exact question number or question prefix, not both.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              Navigator.of(context).pop(
                                _FlashcardFilters(
                                  year: tempYear,
                                  season: tempSeason,
                                  questionNumber: normalizedQuestionNumber,
                                  questionPrefix: normalizedQuestionPrefix,
                                ),
                              );
                            },
                            child: const Text('Apply Filters'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || result == null) return;

    setState(() {
      _selectedYear = result.year;
      _selectedSeason = result.season;
      _selectedQuestionNumber = result.questionNumber;
      _selectedQuestionPrefix = result.questionPrefix;
    });

    await fetchQuestions();
  }

  Future<void> _maybeShowInterstitialForSwipe() async {
    if (_swipeCount == 0 || _swipeCount % _interstitialSwipeInterval != 0) {
      return;
    }

    await _adsService.showInterstitial(AppInterstitialPlacement.flashcard);
  }

  Future<bool> _handleExit() async {
    final wasShown = await _adsService.showInterstitial(
      AppInterstitialPlacement.flashcard,
      onDismissed: () {
        if (!mounted) return;
        Navigator.of(context).pop();
      },
      onFailedToShow: () {
        if (!mounted) return;
        Navigator.of(context).pop();
      },
    );

    return !wasShown;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = _isLoggedIn(authState);
    final loadState = _loadState;
    final questions = loadState.questions;
    final currentQuestion = questions.isNotEmpty
        ? questions[loadState.currentIndex.clamp(0, questions.length - 1)]
        : null;

    return WillPopScope(
      onWillPop: _handleExit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            (widget.topicTitle ?? widget.topicId).toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium,
          ),
          actions: [
            IconButton(
              tooltip: 'Filter',
              onPressed: loadState.isLoading ? null : _openFiltersSheet,
              icon: const Icon(Icons.tune),
            ),
            IconButton(
              tooltip: 'Community discussion',
              onPressed: currentQuestion == null
                  ? null
                  : () {
                      _openCommunityDiscussionSheet(
                        questionId: currentQuestion.id.isEmpty
                            ? 'sample-1'
                            : currentQuestion.id,
                        isLoggedIn: isLoggedIn,
                      );
                    },
              icon: const Icon(Icons.forum),
            ),
          ],
        ),
        body: loadState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : loadState.userMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 42),
                      const SizedBox(height: 12),
                      Text(loadState.userMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: fetchQuestions,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : questions.isEmpty
            ? const Center(
                child: Text('No questions mapped for this topic yet!'),
              )
            : SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Question ${loadState.currentIndex + 1} of ${questions.length}',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              loadState.isAnswerRevealed
                                  ? 'Answer'
                                  : 'Answer (blurred)',
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildActiveFilterSummary(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(
                        'For best outcomes, try solving the problem first before viewing the answer.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: questions.length,
                        onPageChanged: (index) {
                          if (index != _lastPageIndex) {
                            _swipeCount += 1;
                            _lastPageIndex = index;
                            _maybeShowInterstitialForSwipe();
                          }
                          setState(() {
                            _loadState = _loadState.copyWith(
                              currentIndex: index,
                              isAnswerRevealed: false,
                            );
                          });
                        },
                        itemBuilder: (context, index) {
                          final q = questions[index];
                          final year = q.year?.toString() ?? '-';
                          final season = q.season ?? '-';
                          final questionNumber = q.questionNumber ?? '-';
                          final questionImage = q.questionImageUrl;
                          final answerImage = q.answerImageUrl;

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color:
                                            colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        alignment: WrapAlignment.center,
                                        children: [
                                          FlashcardMetaChip(
                                            label: 'Year',
                                            value: year,
                                            emphasize: true,
                                          ),
                                          FlashcardMetaChip(
                                            label: 'Season',
                                            value: season,
                                          ),
                                          FlashcardMetaChip(
                                            label: 'Question',
                                            value: questionNumber,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildImagePanel(
                                      colorScheme: colorScheme,
                                      imageUrl: questionImage,
                                      label: 'Question',
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.accent,
                                              AppColors.ink,
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => _AiExplanationScreen(
                                                  questionImage: questionImage,
                                                  answerImage: answerImage,
                                                  onAskAi: () {
                                                    _requireLoginOrPrompt(() {
                                                      _showInfoSnack(
                                                        'AI explain will connect once the backend is ready.',
                                                      );
                                                    });
                                                  },
                                                  isLoggedIn: isLoggedIn,
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.auto_awesome),
                                          label: const Text('AI Explanation'),
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size.fromHeight(48),
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            foregroundColor: colorScheme.onPrimary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildAnswerPanel(
                                      colorScheme: colorScheme,
                                      textTheme: textTheme,
                                      imageUrl: answerImage,
                                      isBlurred: !loadState.isAnswerRevealed,
                                      onToggleBlur: () {
                                        setState(() {
                                          _loadState = _loadState.copyWith(
                                            isAnswerRevealed:
                                                !_loadState.isAnswerRevealed,
                                          );
                                        });
                                      },
                                    ),
                                    Text(
                                      'Swipe for next card.',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                      child: AdBannerSlot(placement: AppAdPlacement.flashcard),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _openCommunityDiscussionSheet({
    required String questionId,
    required bool isLoggedIn,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final sheetColorScheme = Theme.of(sheetContext).colorScheme;
            final sheetTextTheme = Theme.of(sheetContext).textTheme;
            final comments = _sortedCommentsForQuestion(questionId);
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: _buildCommunityDiscussionSection(
                  colorScheme: sheetColorScheme,
                  textTheme: sheetTextTheme,
                  isLoggedIn: isLoggedIn,
                  questionId: questionId,
                  comments: comments,
                  onDataChanged: () => setModalState(() {}),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImagePanel({
    required ColorScheme colorScheme,
    required String? imageUrl,
    required String label,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 230,
        color: colorScheme.surface,
        child: Stack(
          children: [
            FlashcardQuestionImage(imageUrl: imageUrl),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerPanel({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required String? imageUrl,
    required bool isBlurred,
    required VoidCallback onToggleBlur,
  }) {
    final hasImage = (imageUrl ?? '').trim().isNotEmpty;
    return GestureDetector(
      onTap: hasImage ? onToggleBlur : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: 230,
          color: colorScheme.surface,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FlashcardQuestionImage(imageUrl: imageUrl, blurred: isBlurred),
              if (hasImage)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      alignment: Alignment.center,
                      color: isBlurred
                          ? colorScheme.scrim.withValues(alpha: 0.18)
                          : Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.78),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Text(
                          isBlurred ? 'Tap to unblur' : 'Tap to blur',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityDiscussionSection({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required bool isLoggedIn,
    required String questionId,
    required List<_CommunityComment> comments,
    VoidCallback? onDataChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Discussion',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Share a tip or ask a question',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Record voice note',
                icon: const Icon(Icons.mic_none),
                onPressed: () {
                  _requireLoginOrPrompt(() {
                    _showInfoSnack('Voice note upload will be available soon.');
                  });
                },
              ),
              IconButton(
                tooltip: 'Add video link',
                icon: const Icon(Icons.link),
                onPressed: () {
                  _requireLoginOrPrompt(() async {
                    await _openLinkModal(questionId: questionId);
                  });
                },
              ),
              IconButton(
                tooltip: 'Post',
                icon: const Icon(Icons.send),
                onPressed: () {
                  _requireLoginOrPrompt(() {
                    final text = _commentController.text.trim();
                    if (text.isEmpty) return;
                    setState(() {
                      _communityComments.add(
                        _CommunityComment(
                          id: 'c${DateTime.now().millisecondsSinceEpoch}',
                          questionId: questionId,
                          authorName: 'You',
                          textContent: text,
                          upvotes: 0,
                          createdAt: DateTime.now(),
                        ),
                      );
                      _commentController.clear();
                    });
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (comments.isEmpty)
            Text(
              'No comments yet. Be the first to share an insight.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            Column(
              children: comments
                  .map(
                    (comment) => _CommunityCommentCard(
                      comment: comment,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      onUpvote: () {
                        _requireLoginOrPrompt(() {
                          _applyVote(comment, 1);
                          onDataChanged?.call();
                        });
                      },
                      onDownvote: () {
                        _requireLoginOrPrompt(() {
                          _applyVote(comment, -1);
                          onDataChanged?.call();
                        });
                      },
                      onReport: () {
                        _requireLoginOrPrompt(() {
                          _showInfoSnack(
                            'Thanks for reporting. Moderation review coming soon.',
                          );
                        });
                      },
                      onOpenVideo: () {
                        _showInfoSnack('Video opening coming soon.');
                      },
                      onPlayAudio: () {
                        _showInfoSnack('Audio playback coming soon.');
                      },
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _CommunityComment {
  final String id;
  final String questionId;
  final String authorName;
  final String? textContent;
  final String? audioUrl;
  final String? externalVideoUrl;
  final String? videoThumbnailUrl;
  final int upvotes;
  final DateTime createdAt;

  const _CommunityComment({
    required this.id,
    required this.questionId,
    required this.authorName,
    this.textContent,
    this.audioUrl,
    this.externalVideoUrl,
    this.videoThumbnailUrl,
    required this.upvotes,
    required this.createdAt,
  });

  _CommunityComment copyWith({int? upvotes}) {
    return _CommunityComment(
      id: id,
      questionId: questionId,
      authorName: authorName,
      textContent: textContent,
      audioUrl: audioUrl,
      externalVideoUrl: externalVideoUrl,
      videoThumbnailUrl: videoThumbnailUrl,
      upvotes: upvotes ?? this.upvotes,
      createdAt: createdAt,
    );
  }
}

class _CommunityCommentCard extends StatelessWidget {
  final _CommunityComment comment;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback onReport;
  final VoidCallback onOpenVideo;
  final VoidCallback onPlayAudio;

  const _CommunityCommentCard({
    required this.comment,
    required this.colorScheme,
    required this.textTheme,
    required this.onUpvote,
    required this.onDownvote,
    required this.onReport,
    required this.onOpenVideo,
    required this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    final hasAudio = (comment.audioUrl ?? '').trim().isNotEmpty;
    final hasVideo = (comment.externalVideoUrl ?? '').trim().isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.accent.withOpacity(0.2),
                child: Text(
                  comment.authorName.isNotEmpty
                      ? comment.authorName.characters.first
                      : '?',
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                comment.authorName,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.flag_outlined, size: 18),
                onPressed: onReport,
              ),
            ],
          ),
          if ((comment.textContent ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              comment.textContent!,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
          if (hasAudio) ...[
            const SizedBox(height: 10),
            _AudioPreviewRow(onPlay: onPlayAudio, colorScheme: colorScheme),
          ],
          if (hasVideo) ...[
            const SizedBox(height: 10),
            _VideoPreviewCard(
              thumbnailUrl: comment.videoThumbnailUrl,
              onOpen: onOpenVideo,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
                onPressed: onUpvote,
              ),
              Text(
                comment.upvotes.toString(),
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.thumb_down_alt_outlined, size: 18),
                onPressed: onDownvote,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiExplanationScreen extends StatelessWidget {
  final String? questionImage;
  final String? answerImage;
  final VoidCallback onAskAi;
  final bool isLoggedIn;

  const _AiExplanationScreen({
    required this.questionImage,
    required this.answerImage,
    required this.onAskAi,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('AI Explanation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Preview explanation',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Example explanation shown for preview. AI will highlight the memo logic once enabled.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '1) Identify the key formula. 2) Substitute known values carefully. 3) Compare with memo steps to confirm the final value.',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SourcePreviewCard(
                label: 'Question image',
                imageUrl: questionImage,
              ),
              _SourcePreviewCard(label: 'Memo image', imageUrl: answerImage),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAskAi,
              icon: const Icon(Icons.auto_awesome),
              label: Text(isLoggedIn ? 'Ask AI to Explain' : 'Login to Ask AI'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _SourcePreviewCard extends StatelessWidget {
  final String label;
  final String? imageUrl;

  const _SourcePreviewCard({required this.label, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasImage = (imageUrl ?? '').trim().isNotEmpty;
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: SizedBox(
              height: 84,
              width: double.infinity,
              child: hasImage
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imageFallback(colorScheme),
                    )
                  : _imageFallback(colorScheme),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _AudioPreviewRow extends StatelessWidget {
  final VoidCallback onPlay;
  final ColorScheme colorScheme;

  const _AudioPreviewRow({required this.onPlay, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.play_arrow), onPressed: onPlay),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '0:45',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPreviewCard extends StatelessWidget {
  final String? thumbnailUrl;
  final VoidCallback onOpen;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _VideoPreviewCard({
    required this.thumbnailUrl,
    required this.onOpen,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final hasThumbnail = (thumbnailUrl ?? '').trim().isNotEmpty;
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 88,
                height: 54,
                child: hasThumbnail
                    ? Image.network(
                        thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallback(),
                      )
                    : _buildFallback(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Watch student explanation',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const Icon(Icons.open_in_new, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.ondemand_video, color: colorScheme.onSurfaceVariant),
    );
  }
}
