// lib/utils/constants.dart

class PaperMeta {
  final int? marks;
  final int? totalQuestions;
  final int? durationMinutes;
  final String? notes;

  const PaperMeta({
    this.marks,
    this.totalQuestions,
    this.durationMinutes,
    this.notes,
  });

  String summary() {
    final parts = <String>[];

    if (marks != null) {
      parts.add('$marks marks');
    }

    if (totalQuestions != null) {
      final label = totalQuestions == 1 ? 'question' : 'questions';
      parts.add('$totalQuestions $label');
    }

    if (durationMinutes != null) {
      parts.add('±${_formatDuration(durationMinutes!)}');
    }

    if (notes != null && notes!.isNotEmpty) {
      parts.add(notes!);
    }

    return parts.join(' • ');
  }

  static String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0 && remainingMinutes > 0) {
      return '${hours}h ${remainingMinutes}m';
    }

    if (hours > 0) {
      return '${hours}h';
    }

    return '${remainingMinutes}m';
  }
}

class AppConstants {
  // ========================================
  // 🚀 MVP RELEASE CONFIGURATION
  // ========================================
  // Currently available: Mathematics Grade 12 only
  // Other subjects/grades coming soon!

  // Available subjects for MVP release
  static const List<String> availableSubjects = ['mathematics'];

  // Coming soon subjects (shown with badges)
  static const List<String> comingSoonSubjects = [
    'physical sciences',
    'life sciences',
  ];

  // All subjects combined (for reference)
  static const List<String> allSubjects = [
    ...availableSubjects,
    ...comingSoonSubjects,
  ];

  // Alias for subjects (for admin portal consistency)
  static const List<String> subjects = allSubjects;

  // Available grades for MVP release (Mathematics Grade 12 only)
  static const List<int> availableGrades = [12];

  // Coming soon grades
  static const List<int> comingSoonGrades = [10, 11];

  // All grades combined
  static const List<int> grades = [...availableGrades, ...comingSoonGrades];

  // MVP Beta message
  static const String betaMessage =
      'Beta v0.1 - Mathematics Grade 12 only. More subjects and grades coming soon!';

  // Check if subject is available
  static bool isSubjectAvailable(String subject) {
    return availableSubjects.contains(subject.toLowerCase());
  }

  // Check if grade is available
  static bool isGradeAvailable(int grade) {
    return availableGrades.contains(grade);
  }

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
      'Statistics',
      'Analytical Geometry',
      'Trigonometry',
      'Euclidean Geometry',
    ],
    'physical sciences': [
      'Mechanics',
      'Waves, Sound & Light',
      'Electricity & Magnetism',
      'Matter & Materials',
      'Chemical Change',
      'Chemical Systems',
    ],
    'life sciences': [
      'The Chemistry of Life',
      'Cells - The basic units of life',
      'Cell division: mitosis',
      'Plant and animal tissues',
      'Plant organs',
    ],
    // Add topic lists for other subjects here
  };

  static const Map<String, Map<int, Map<String, PaperMeta>>>
  fullExamPaperMetadata = {
    'mathematics': {
      12: {
        'p1': PaperMeta(marks: 150, durationMinutes: 180),
        'p2': PaperMeta(marks: 150, durationMinutes: 180),
      },
      11: {
        'p1': PaperMeta(marks: 150, durationMinutes: 180),
        'p2': PaperMeta(marks: 150, durationMinutes: 180),
      },
      10: {
        'p1': PaperMeta(marks: 150, durationMinutes: 150),
        'p2': PaperMeta(marks: 150, durationMinutes: 150),
      },
    },
    'physical sciences': {
      12: {
        'p1': PaperMeta(marks: 150, durationMinutes: 180),
        'p2': PaperMeta(marks: 150, durationMinutes: 180),
      },
      11: {
        'p1': PaperMeta(marks: 150, durationMinutes: 180),
        'p2': PaperMeta(marks: 150, durationMinutes: 180),
      },
      10: {
        'p1': PaperMeta(marks: 150, durationMinutes: 150),
        'p2': PaperMeta(marks: 150, durationMinutes: 150),
      },
    },
    'life sciences': {
      12: {
        'p1': PaperMeta(marks: 150, durationMinutes: 150),
        'p2': PaperMeta(marks: 150, durationMinutes: 150),
      },
      11: {
        'p1': PaperMeta(marks: 150, durationMinutes: 150),
        'p2': PaperMeta(marks: 150, durationMinutes: 150),
      },
      10: {
        'p1': PaperMeta(marks: 150, durationMinutes: 150),
        'p2': PaperMeta(marks: 150, durationMinutes: 150),
      },
    },
  };

  static PaperMeta? getFullExamPaperMeta(
    String subject,
    int grade,
    String paper,
  ) {
    final subjectKey = subject.toLowerCase().trim();
    final paperKey = _normalizePaperKey(paper);
    final subjectEntry = fullExamPaperMetadata[subjectKey];
    if (subjectEntry == null) {
      return null;
    }

    final gradeEntry = subjectEntry[grade];
    if (gradeEntry == null) {
      return null;
    }

    return gradeEntry[paperKey];
  }

  static String _normalizePaperKey(String paper) {
    final sanitized = paper.toLowerCase().replaceAll(' ', '');

    if (sanitized.contains('p2')) {
      return 'p2';
    }

    if (sanitized.contains('paper2')) {
      return 'p2';
    }

    if (sanitized.contains('p1') || sanitized.contains('paper1')) {
      return 'p1';
    }

    return sanitized;
  }
}
