import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/views/pdf_viewer_screen.dart';

/// Library Screen - PDF Viewer for Past Papers
///
/// This screen displays available past papers in PDF format.
/// Users can browse, search, filter, and view PDFs of exam papers.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _selectedSubject = 'All';
  String _selectedGrade = 'All';
  String _selectedYear = 'All';
  String _searchQuery = '';

  final List<String> _subjects = [
    'All',
    'mathematics',
    'science',
    'english',
    'history',
    'geography',
  ];

  final List<String> _grades = ['All', '10', '11', '12'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Library',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.ink),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.ink),
            onPressed: () => _showFilterDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          if (_selectedSubject != 'All' ||
              _selectedGrade != 'All' ||
              _selectedYear != 'All' ||
              _searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_selectedSubject != 'All')
                      _buildFilterChip(
                        'Subject: $_selectedSubject',
                        () => setState(() => _selectedSubject = 'All'),
                      ),
                    if (_selectedGrade != 'All')
                      _buildFilterChip(
                        'Grade: $_selectedGrade',
                        () => setState(() => _selectedGrade = 'All'),
                      ),
                    if (_selectedYear != 'All')
                      _buildFilterChip(
                        'Year: $_selectedYear',
                        () => setState(() => _selectedYear = 'All'),
                      ),
                    if (_searchQuery.isNotEmpty)
                      _buildFilterChip(
                        'Search: $_searchQuery',
                        () => setState(() => _searchQuery = ''),
                      ),
                  ],
                ),
              ),
            ),

          // Papers list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading papers',
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final papers = snapshot.data!.docs;

                // Apply client-side search filter if needed
                final filteredPapers = _searchQuery.isEmpty
                    ? papers
                    : papers.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final title = (data['title'] ?? '')
                            .toString()
                            .toLowerCase();
                        final subject = (data['subject'] ?? '')
                            .toString()
                            .toLowerCase();
                        return title.contains(_searchQuery.toLowerCase()) ||
                            subject.contains(_searchQuery.toLowerCase());
                      }).toList();

                if (filteredPapers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.library_books_rounded,
                          size: 120,
                          color: AppColors.brandLavender.withOpacity(0.3),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No papers found',
                          style: textTheme.headlineSmall?.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Try adjusting your filters or search query',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPapers.length,
                  itemBuilder: (context, index) {
                    final doc = filteredPapers[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildPaperCard(context, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _buildQuery() {
    Query query = FirebaseFirestore.instance.collection('papers');

    if (_selectedSubject != 'All') {
      query = query.where('subject', isEqualTo: _selectedSubject);
    }

    if (_selectedGrade != 'All') {
      query = query.where('grade', isEqualTo: int.parse(_selectedGrade));
    }

    if (_selectedYear != 'All') {
      query = query.where('year', isEqualTo: int.parse(_selectedYear));
    }

    return query.orderBy('year', descending: true).snapshots();
  }

  Widget _buildPaperCard(BuildContext context, Map<String, dynamic> data) {
    final subject = data['subject'] ?? 'Unknown';
    final grade = data['grade']?.toString() ?? 'Unknown';
    final year = data['year']?.toString() ?? 'Unknown';
    final season = data['season'] ?? 'Unknown';
    final paperNumber = data['paperNumber'] ?? 'Unknown';
    final title = data['title'] ?? 'Untitled';
    final pdfUrl = data['pdfUrl'] ?? '';
    final fileSize = data['fileSize'] ?? 0;

    final subjectColor = _getSubjectColor(subject);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openPDF(context, pdfUrl, title),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // PDF Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: subjectColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.picture_as_pdf,
                  color: subjectColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),

              // Paper details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${subject.toUpperCase()} • Grade $grade • $season $year • Paper ${paperNumber.toUpperCase()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.neutralMid,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatFileSize(fileSize),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.neutralSoft,
                      ),
                    ),
                  ],
                ),
              ),

              // View button
              IconButton(
                icon: Icon(Icons.open_in_new, color: AppColors.accent),
                onPressed: () => _openPDF(context, pdfUrl, title),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onDelete,
        backgroundColor: AppColors.accent.withOpacity(0.1),
        labelStyle: TextStyle(color: AppColors.accent, fontSize: 12),
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return AppColors.brandCyan;
      case 'science':
        return AppColors.brandTeal;
      case 'english':
        return AppColors.brandMagenta;
      case 'history':
        return AppColors.brandLavender;
      case 'geography':
        return Colors.green;
      default:
        return AppColors.accent;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _openPDF(BuildContext context, String url, String title) {
    if (url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PDF URL not available')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(pdfUrl: url, title: title),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Papers'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter title or subject...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            setState(() => _searchQuery = value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Papers'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subject',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _subjects.map((subject) {
                  return DropdownMenuItem(value: subject, child: Text(subject));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedSubject = value!);
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Grade',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedGrade,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _grades.map((grade) {
                  return DropdownMenuItem(value: grade, child: Text(grade));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedGrade = value!);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedSubject = 'All';
                _selectedGrade = 'All';
                _selectedYear = 'All';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
