import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:past_question_paper_v1/core/shared/models/flashcard_load_state.dart';
import 'package:past_question_paper_v1/core/shared/models/rest_question_query.dart';
import 'package:past_question_paper_v1/core/shared/repositories/rest_questions_repository.dart';
import 'package:past_question_paper_v1/core/shared/services/ads_service.dart';
import 'package:past_question_paper_v1/core/shared/services/rest_questions_api_service.dart';
import 'package:past_question_paper_v1/core/shared/widgets/ad_banner_slot.dart';
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
    super.dispose();
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
    final loadState = _loadState;
    final questions = loadState.questions;
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

}
