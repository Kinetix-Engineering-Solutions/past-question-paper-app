// lib/utils/constants.dart

class AppConstants {
  // This is the hardcoded list of all subjects your app will offer.
  static const List<String> allSubjects = [
    'mathematics',
    'physical sciences',
    'life sciences',
    // Add more subjects here as needed
  ];

  // This is the hardcoded list of grades.
  static const List<int> grades = [10, 11, 12];

  // --- NEW: Hardcoded map of topics for each subject ---
  // This provides the data needed for the "By Topic" practice mode.
  static const Map<String, List<String>> topicsBySubject = {
    'mathematics': [
      'Algebra, Equations & Inequalities',
      'Pattern & Sequences',
      'Functions & Graphs',
      'Finance, Growth & Decay',
      'Differential Calculus',
      'Probability',
      // Add Paper 2 topics if needed
      'Statistics',
      'Analytical Geometry',
      'Trigonometry',
      'Euclidean Geometry',
    ],
    'Physical Sciences': [
      'Mechanics',
      'Waves, Sound & Light',
      'Electricity & Magnetism',
      'Matter & Materials',
      'Chemical Change',
      'Chemical Systems',
    ],
    'Life Sciences': [
      'The Chemistry of Life',
      'Cells - The basic units of life',
      'Cell division: mitosis',
      'Plant and animal tissues',
      'Plant organs',
      // Add more topics as needed
    ],
    // Add topic lists for other subjects here
  };
}
