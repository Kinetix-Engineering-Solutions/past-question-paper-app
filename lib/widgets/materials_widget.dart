import 'package:flutter/material.dart';
import 'package:past_question_paper_stem/model/subject.dart';
import 'package:past_question_paper_stem/utils/app_colors.dart';

class MaterialsWidget extends StatelessWidget {
  final Subject subject;

  const MaterialsWidget({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    // For now, we'll show common material types
    // This can be enhanced later with actual data from the backend
    final materialTypes = [
      {
        'title': 'Past Question Papers',
        'description': 'Download previous exam papers for ${subject.name}',
        'icon': Icons.quiz,
        'color': AppColors.accent,
      },
      {
        'title': 'Study Guides',
        'description': 'Comprehensive study materials and notes',
        'icon': Icons.book,
        'color': AppColors.ink,
      },
      {
        'title': 'Practice Tests',
        'description': 'Mock exams and practice assessments',
        'icon': Icons.assignment,
        'color': AppColors.ink,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      itemCount: materialTypes.length,
      itemBuilder: (context, index) {
        final material = materialTypes[index];
        return _buildMaterialItem(context, material);
      },
    );
  }

  Widget _buildMaterialItem(
    BuildContext context,
    Map<String, dynamic> material,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _downloadMaterial(context, material['title']),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutralBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.neutralMid.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(material['icon'], color: AppColors.ink, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      material['description'],
                      style: TextStyle(
                        color: AppColors.neutralMid,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.download, color: AppColors.ink, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _downloadMaterial(BuildContext context, String materialType) {
    // For now, show a placeholder message
    // This is where you would implement the actual download logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading $materialType for ${subject.name}...'),
        backgroundColor: AppColors.accent,
        action: SnackBarAction(
          label: 'View',
          textColor: AppColors.neutralCard,
          onPressed: () {
            // Navigate to a dedicated materials/downloads screen
            _showMaterialOptions(context, materialType);
          },
        ),
      ),
    );
  }

  void _showMaterialOptions(BuildContext context, String materialType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.3,
            expand: false,
            builder:
                (context, scrollController) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.neutralMid,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        '$materialType - ${subject.name}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Available downloads for this subject',
                        style: TextStyle(
                          color: AppColors.neutralMid,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Materials list
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            _buildDownloadItem(
                              context,
                              '2023 Past Paper',
                              '2.3 MB PDF',
                              Icons.picture_as_pdf,
                            ),
                            _buildDownloadItem(
                              context,
                              '2022 Past Paper',
                              '1.8 MB PDF',
                              Icons.picture_as_pdf,
                            ),
                            _buildDownloadItem(
                              context,
                              '2021 Past Paper',
                              '2.1 MB PDF',
                              Icons.picture_as_pdf,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildDownloadItem(
    BuildContext context,
    String title,
    String size,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Implement actual download here
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Downloading $title...'),
              backgroundColor: Colors.green,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutralBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.neutralMid.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.ink, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      size,
                      style: TextStyle(
                        color: AppColors.neutralMid,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.download, color: AppColors.ink, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
