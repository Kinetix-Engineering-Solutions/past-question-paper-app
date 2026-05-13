import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:past_question_paper_v1/core/shared/services/rest_questions_api_service.dart';

class FlashcardScreen extends StatefulWidget {
  final String subjectId;
  final String topicId;
  final String? topicTitle;
  final String? initialPaper;

  const FlashcardScreen({
    super.key,
    required this.subjectId,
    required this.topicId,
    this.topicTitle,
    this.initialPaper,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
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

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<dynamic> questions = <dynamic>[];
  bool isLoading = true;
  bool _isAnswerRevealed = false;
  String? errorMessage;
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  int? _selectedYear; // null = Any
  String? _selectedPaper; // null = Any
  String? _selectedSeason; // null = Any
  String? _selectedQuestionNumber; // null = Any
  String? _selectedQuestionPrefix; // null = Any

  final RestQuestionsApiService _restApi = RestQuestionsApiService();
  static const List<String> _seasonOptions = <String>[
    'Any',
    'May/June',
    'Oct/Nov',
    'Feb/March',
  ];

  String? _readString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value == null) {
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _selectedPaper = widget.initialPaper;
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

  Widget _buildQuestionImage(
    BuildContext context,
    String? imageUrl, {
    bool blurred = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return Center(
        child: Icon(
          Icons.broken_image,
          size: 52,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth;

        Image buildImage(ImageProvider provider) {
          return Image(
            image: provider,
            width: contentWidth,
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          );
        }

        Widget wrapScrollable(Widget child) {
          return SingleChildScrollView(
            primary: false,
            physics: const ClampingScrollPhysics(),
            child: child,
          );
        }

        return CachedNetworkImage(
          imageUrl: imageUrl,
          imageBuilder: (context, provider) {
            if (!blurred) {
              return wrapScrollable(buildImage(provider));
            }

            // Gradient blur (light -> strong):
            // - No unblurred image is shown underneath (prevents readability)
            // - Strong blur fades in toward the bottom via a vertical alpha mask
            const lightSigma = 4.0;
            const strongSigma = 16.0;

            final lightBlurLayer = ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: lightSigma,
                sigmaY: lightSigma,
              ),
              child: buildImage(provider),
            );

            final strongBlurLayer = ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.35, 1.0],
                  colors: [
                    Color(0x00FFFFFF),
                    Color(0x88FFFFFF),
                    Color(0xFFFFFFFF),
                  ],
                ).createShader(rect);
              },
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: strongSigma,
                  sigmaY: strongSigma,
                ),
                child: buildImage(provider),
              ),
            );

            final blurredWidget = ClipRect(
              child: Stack(
                children: [
                  lightBlurLayer,
                  strongBlurLayer,
                  // Slight scrim so fine details don't remain readable.
                  Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.scrim.withValues(alpha: 0.06),
                  ),
                ],
              ),
            );

            return wrapScrollable(blurredWidget);
          },
          placeholder: (context, url) => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Center(
            child: Icon(
              Icons.broken_image,
              size: 52,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetaChip(
    BuildContext context, {
    required String label,
    required String value,
    bool emphasize = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: emphasize
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: RichText(
        text: TextSpan(
          style: textTheme.labelMedium?.copyWith(
            color: emphasize
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchQuestions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final selectedYear = _selectedYear;
      final fetched = await _restApi.fetchQuestions(
        subject: widget.subjectId,
        grade: 12,
        topic: widget.topicId,
        startYear: selectedYear,
        endYear: selectedYear,
        paper: _selectedPaper,
        season: _selectedSeason,
        questionNumber: _selectedQuestionNumber,
        questionPrefix: _selectedQuestionPrefix,
      );

      if (!mounted) return;

      final mapped = fetched
          .map(
            (q) => {
              'id': q.id,
              'subjectId': q.subjectId,
              'grade': q.grade,
              'topic': q.topic,
              'year': q.year,
              'season': q.season,
              'paper': q.paper,
              'questionNumber': q.questionNumber,
              'imageUrl': q.imageUrl,
              'answerImageUrl': q.answerImageUrl,
            },
          )
          .toList();

      mapped.shuffle();

      setState(() {
        questions = mapped;
        isLoading = false;
        _currentIndex = 0;
        _isAnswerRevealed = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
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
            onPressed: isLoading ? null : _openFiltersSheet,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 42),
                    const SizedBox(height: 12),
                    Text(errorMessage!, textAlign: TextAlign.center),
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
          ? const Center(child: Text('No questions mapped for this topic yet!'))
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Question ${_currentIndex + 1} of ${questions.length}',
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
                            _isAnswerRevealed ? 'Answer' : 'Answer (blurred)',
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: questions.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                          _isAnswerRevealed = false;
                        });
                      },
                      itemBuilder: (context, index) {
                        final q = questions[index] as Map<String, dynamic>;
                        final year =
                            _readString(q, ['year', 'examYear', 'exam_year']) ??
                            '-';
                        final season =
                            _readString(q, [
                              'season',
                              'examSeason',
                              'exam_season',
                            ]) ??
                            '-';
                        final questionNumber =
                            _readString(q, [
                              'questionNumber',
                              'question_number',
                            ]) ??
                            '-';
                        final questionImage = _readString(q, [
                          'imageUrl',
                          'image_url',
                        ]);
                        final answerImage = _readString(q, [
                          'answerImageUrl',
                          'answer_image_url',
                        ]);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    _buildMetaChip(
                                      context,
                                      label: 'Year',
                                      value: year,
                                      emphasize: true,
                                    ),
                                    _buildMetaChip(
                                      context,
                                      label: 'Season',
                                      value: season,
                                    ),
                                    _buildMetaChip(
                                      context,
                                      label: 'Question',
                                      value: questionNumber,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          width: double.infinity,
                                          color: colorScheme.surface,
                                          child: _buildQuestionImage(
                                            context,
                                            questionImage,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          width: double.infinity,
                                          color: colorScheme.surface,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              _buildQuestionImage(
                                                context,
                                                answerImage,
                                                blurred: !_isAnswerRevealed,
                                              ),
                                              if (!_isAnswerRevealed &&
                                                  (answerImage ?? '')
                                                      .trim()
                                                      .isNotEmpty)
                                                Positioned.fill(
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    color: colorScheme.scrim
                                                        .withValues(
                                                          alpha: 0.18,
                                                        ),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: colorScheme
                                                            .surface
                                                            .withValues(
                                                              alpha: 0.78,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              999,
                                                            ),
                                                        border: Border.all(
                                                          color: colorScheme
                                                              .outlineVariant,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Answer blurred',
                                                        style: textTheme
                                                            .labelLarge
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: colorScheme
                                                                  .onSurface,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
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
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isAnswerRevealed = !_isAnswerRevealed;
                        });
                      },
                      icon: Icon(
                        _isAnswerRevealed
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      label: Text(
                        _isAnswerRevealed ? 'Blur Answer' : 'Show Answer',
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
