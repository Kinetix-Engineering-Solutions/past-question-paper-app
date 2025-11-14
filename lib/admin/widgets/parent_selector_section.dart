import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/viewmodels/question_create_viewmodel.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';

/// Parent Selector Section - Select parent question for child questions
class ParentSelectorSection extends ConsumerStatefulWidget {
  const ParentSelectorSection({super.key});

  @override
  ConsumerState<ParentSelectorSection> createState() =>
      _ParentSelectorSectionState();
}

class _ParentSelectorSectionState extends ConsumerState<ParentSelectorSection> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _parentQuestions = [];
  List<Map<String, dynamic>> _filteredParentQuestions = [];
  List<int> _availableYears = [];
  int? _selectedYear;
  String _searchTerm = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParentQuestions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadParentQuestions() async {
    if (!mounted) return;
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      // Query without orderBy to avoid composite index requirement
      final snapshot = await FirebaseFirestore.instance
          .collection('questions')
          .where('isParent', isEqualTo: true)
          .get();

      // Map and sort in memory
      final parentsList = snapshot.docs.map((doc) {
        final data = doc.data();
        String identifier = doc.id.substring(0, 8);

        if (data['pqpData'] != null && data['pqpData'] is Map) {
          final pqpData = data['pqpData'] as Map<String, dynamic>;
          final pqpNumber = pqpData['questionNumber'];
          if (pqpNumber != null) {
            identifier = pqpNumber.toString();
          }
        }

        final subject = (data['subject'] as String?)?.trim() ?? '';
        final topic = (data['topic'] as String?)?.trim() ?? '';
        final season = (data['season'] as String?)?.trim() ?? '';
        final year = _parseYear(data['year']);

        final labelSegments = <String>[];
        if (identifier.isNotEmpty) {
          labelSegments.add(identifier);
        }
        if (subject.isNotEmpty) {
          labelSegments.add(subject);
        }
        if (topic.isNotEmpty) {
          labelSegments.add(topic);
        }
        if (year != null || season.isNotEmpty) {
          final window = season.isNotEmpty
              ? year != null
                    ? '$year $season'
                    : season
              : year?.toString() ?? '';
          if (window.isNotEmpty) {
            labelSegments.add(window);
          }
        }

        final displayLabel = labelSegments.isEmpty
            ? identifier
            : labelSegments.join(' • ');

        final searchVector = [
          identifier,
          subject,
          topic,
          season,
          year?.toString() ?? '',
          doc.id,
        ].where((element) => element.trim().isNotEmpty).join(' ').toLowerCase();

        return {
          'id': doc.id,
          'displayText': displayLabel,
          'pqpNumber': identifier,
          'subject': subject,
          'topic': topic,
          'year': year,
          'season': season,
          'searchIndex': searchVector,
        };
      }).toList();

      parentsList.sort((a, b) {
        final aNumber = a['pqpNumber'] as String? ?? '';
        final bNumber = b['pqpNumber'] as String? ?? '';
        return aNumber.compareTo(bNumber);
      });

      final uniqueYears =
          parentsList
              .map((parent) => parent['year'])
              .whereType<int>()
              .toSet()
              .toList()
            ..sort((a, b) => b.compareTo(a));

      setState(() {
        _parentQuestions = parentsList;
        _availableYears = uniqueYears;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      debugPrint('❌ Error loading parent questions: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int? _parseYear(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  void _applyFilters() {
    if (!mounted) return;

    final selectedParentId = ref
        .read(questionCreateViewModelProvider)
        .parentQuestionId;

    final filtered = _parentQuestions.where((parent) {
      final yearMatch =
          _selectedYear == null || parent['year'] == _selectedYear;
      final searchIndex = parent['searchIndex'] as String? ?? '';
      final searchMatch =
          _searchTerm.isEmpty || searchIndex.contains(_searchTerm);
      return yearMatch && searchMatch;
    }).toList();

    if (selectedParentId != null &&
        filtered.every((parent) => parent['id'] != selectedParentId)) {
      final selectedParent = _findParentById(selectedParentId);
      if (selectedParent != null) {
        filtered.insert(0, selectedParent);
      }
    }

    filtered.sort((a, b) {
      final aNumber = a['pqpNumber'] as String? ?? '';
      final bNumber = b['pqpNumber'] as String? ?? '';
      return aNumber.compareTo(bNumber);
    });

    if (mounted) {
      setState(() {
        _filteredParentQuestions = filtered;
      });
    }
  }

  Map<String, dynamic>? _findParentById(String id) {
    for (final parent in _parentQuestions) {
      if (parent['id'] == id) {
        return parent;
      }
    }
    return null;
  }

  bool get _hasActiveFilters => _searchTerm.isNotEmpty || _selectedYear != null;

  void _clearFilters() {
    if (mounted) {
      setState(() {
        _searchTerm = '';
        _selectedYear = null;
        _searchController.clear();
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionCreateViewModelProvider);
    final notifier = ref.read(questionCreateViewModelProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle checkbox
        CheckboxListTile(
          title: const Text(
            'This is a child question (part of a parent question)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text(
            'Child questions share context (text, images) from a parent question',
            style: TextStyle(fontSize: 12),
          ),
          value: state.isChildQuestion,
          onChanged: (value) => notifier.toggleChildQuestionMode(),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),

        // Parent selection (shown when child mode is enabled)
        if (state.isChildQuestion) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Parent selector
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _parentQuestions.isEmpty
              ? _buildNoParentsMessage()
              : _buildParentDropdown(state, notifier),

          // Parent context preview (shown when parent is selected)
          if (state.parentQuestionId != null) ...[
            const SizedBox(height: 16),
            _buildParentPreview(state),

            const SizedBox(height: 16),

            // Use parent image checkbox
            if (state.parentImageUrl != null &&
                state.parentImageUrl!.isNotEmpty)
              CheckboxListTile(
                title: const Text('Use parent\'s image'),
                subtitle: const Text(
                  'Check this to display the parent\'s image with this child question',
                  style: TextStyle(fontSize: 12),
                ),
                value: state.usesParentImage,
                onChanged: (value) => notifier.toggleUsesParentImage(),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),

            // Suggested PQP number
            if (state.suggestedPQPNumber != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Suggested PQP Number: ${state.suggestedPQPNumber}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],

          const SizedBox(height: 16),
          const Divider(),
        ],
      ],
    );
  }

  Widget _buildParentDropdown(
    QuestionCreateState state,
    QuestionCreateViewModel notifier,
  ) {
    final dropdownParents = List<Map<String, dynamic>>.from(
      _filteredParentQuestions,
    );
    final selectedId = state.parentQuestionId;

    if (selectedId != null &&
        dropdownParents.every((parent) => parent['id'] != selectedId)) {
      final selectedParent = _findParentById(selectedId);
      if (selectedParent != null) {
        dropdownParents.insert(0, selectedParent);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Parent Question:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_parentQuestions.isNotEmpty) _buildFilterControls(),
        if (dropdownParents.isEmpty)
          _buildEmptyFilteredMessage()
        else
          DropdownButtonFormField<String>(
            value: state.parentQuestionId,
            decoration: InputDecoration(
              labelText: 'Parent Question',
              hintText: 'Choose a parent question...',
              suffixIcon: state.parentQuestionId != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => notifier.clearParent(),
                    )
                  : null,
            ),
            menuMaxHeight: 320,
            items: dropdownParents.map((parent) {
              return DropdownMenuItem<String>(
                value: parent['id'] as String,
                child: Text(
                  parent['displayText'] as String,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                notifier.selectParent(value);
              }
            },
          ),
      ],
    );
  }

  Widget _buildFilterControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search parent questions',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      _searchTerm = value.trim().toLowerCase();
                    });
                    _applyFilters();
                  }
                },
              ),
            ),
            if (_availableYears.isNotEmpty) ...[
              const SizedBox(width: 12),
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<int?>(
                  value: _selectedYear,
                  decoration: const InputDecoration(
                    labelText: 'Filter by year',
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All years'),
                    ),
                    ..._availableYears.map(
                      (year) => DropdownMenuItem<int?>(
                        value: year,
                        child: Text(year.toString()),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (mounted) {
                      setState(() {
                        _selectedYear = value;
                      });
                      _applyFilters();
                    }
                  },
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildEmptyFilteredMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No parent questions match your filters.',
            style: TextStyle(
              color: Colors.orange.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_hasActiveFilters)
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear filters'),
            )
          else
            const Text(
              'Adjust your filters or create a new parent question.',
              style: TextStyle(fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildNoParentsMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Parent Questions Found',
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create a parent question first before creating child questions.',
                  style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentPreview(QuestionCreateState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_tree, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Parent Context Preview',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Parent context text
          if (state.parentContextText != null &&
              state.parentContextText!.isNotEmpty) ...[
            Text(
              state.parentContextText!,
              style: TextStyle(color: AppColors.neutralMid, fontSize: 13),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],

          // Parent image
          if (state.parentImageUrl != null &&
              state.parentImageUrl!.isNotEmpty) ...[
            const Text(
              'Parent Image:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 180,
                width: double.infinity,
                color: AppColors.neutralSoft,
                alignment: Alignment.center,
                child: Image.network(
                  state.parentImageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160,
                    alignment: Alignment.center,
                    child: const Text('Failed to load image'),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
