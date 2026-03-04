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
    'accounting',
    'geography',
    'history',
    'business studies',
    'economics',
    'english home language',
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
      'Animal tissues',
      'Support & transport systems in plants',
      'Support systems in animals',
      'Transport systems in mammals',
      'Biosphere to ecosystems',
      'Biodiversity & classification',
      'History of life on Earth',
      'Genetics & inheritance',
      'DNA: The code of life',
      'Meiosis',
      'Reproduction in vertebrates',
      'Human reproduction',
      'Responding to the environment (humans)',
      'Human endocrine system',
      'Homeostasis in humans',
      'Responding to the environment (plants)',
      'Human impact on the environment',
      'Evolution by natural selection',
      'Human evolution',
    ],
    'accounting': [
      'Accounting Equation',
      'Recording of Transactions',
      'Financial Statements',
      'Bank Reconciliation',
      'Year-end Adjustments',
      'Budgets & Projections',
      'Manufacturing',
      'Cost Accounting',
      'Inventory Valuation',
      'Fixed Assets & Depreciation',
      'Partnerships',
      'Companies - Financial Statements',
      'Companies - Analysis & Interpretation',
      'Ethics & Internal Control',
      'Value Added Tax (VAT)',
    ],
    'geography': [
      'Climate & Weather',
      'Geomorphology',
      'Mapwork & Map Calculations',
      'GIS (Geographical Information Systems)',
      'Development Geography',
      'Resources & Sustainability',
      'Settlement Geography',
      'Economic Geography of South Africa',
      'Rural & Urban Settlements',
      'Drainage Systems',
      'Fluvial Processes',
    ],
    'history': [
      'The Cold War',
      'Civil Resistance in South Africa (1970s-1980s)',
      'The end of the Cold War & a new world order',
      'How did South Africa emerge as a democracy?',
      'Ideology & the Cold War in Africa & Asia',
      'Independent Africa',
      'Civil society protests from the 1950s to 1970s',
      'The coming of democracy to South Africa',
      'The Truth & Reconciliation Commission',
      'Apartheid South Africa (1948-1970)',
      'Globalization',
    ],
    'business studies': [
      'Business Environments',
      'Business Operations',
      'Business Roles',
      'Business Ventures',
      'Ethics & Professionalism',
      'Creative Thinking & Problem Solving',
      'Human Resources',
      'Marketing',
      'Production',
      'Finances',
      'Legislation',
      'Insurance',
      'Forms of Ownership',
      'Presentation & Data Response',
    ],
    'economics': [
      'Micro-economics',
      'Macro-economics',
      'Economic Pursuits',
      'Contemporary Economic Issues',
      'Markets',
      'Perfect & Imperfect Markets',
      'Market Failures',
      'Public Sector',
      'The Business Cycle',
      'Economic Growth & Development',
      'Industrial Development & Policies',
      'South African Economy',
      'Globalisation',
      'Foreign Exchange Markets',
      'Balance of Payments',
      'Inflation',
      'Tourism',
      'Environmental Sustainability',
    ],
    'english home language': [
      'Comprehension',
      'Summary Writing',
      'Language Structures & Conventions',
      'Literature - Poetry',
      'Literature - Novel',
      'Literature - Drama',
      'Literature - Short Stories',
      'Essay Writing',
      'Transactional Writing',
      'Visual Literacy',
      'Advertising',
      'Cartoons & Comics',
    ],
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
    'accounting': {
      12: {
        'p1': PaperMeta(marks: 150, durationMinutes: 120),
        'p2': PaperMeta(marks: 150, durationMinutes: 120),
      },
      11: {
        'p1': PaperMeta(marks: 150, durationMinutes: 120),
        'p2': PaperMeta(marks: 150, durationMinutes: 120),
      },
      10: {'p1': PaperMeta(marks: 150, durationMinutes: 120)},
    },
    'geography': {
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
    'history': {
      12: {
        'p1': PaperMeta(marks: 150, durationMinutes: 180),
        'p2': PaperMeta(marks: 150, durationMinutes: 180),
      },
      11: {
        'p1': PaperMeta(marks: 150, durationMinutes: 180),
        'p2': PaperMeta(marks: 150, durationMinutes: 180),
      },
      10: {'p1': PaperMeta(marks: 150, durationMinutes: 150)},
    },
    'business studies': {
      12: {
        'p1': PaperMeta(marks: 150, durationMinutes: 120),
        'p2': PaperMeta(marks: 150, durationMinutes: 120),
      },
      11: {
        'p1': PaperMeta(marks: 150, durationMinutes: 120),
        'p2': PaperMeta(marks: 150, durationMinutes: 120),
      },
      10: {'p1': PaperMeta(marks: 150, durationMinutes: 120)},
    },
    'economics': {
      12: {
        'p1': PaperMeta(marks: 150, durationMinutes: 120),
        'p2': PaperMeta(marks: 150, durationMinutes: 120),
      },
      11: {
        'p1': PaperMeta(marks: 150, durationMinutes: 120),
        'p2': PaperMeta(marks: 150, durationMinutes: 120),
      },
      10: {'p1': PaperMeta(marks: 150, durationMinutes: 120)},
    },
    'english home language': {
      12: {
        'p1': PaperMeta(marks: 80, durationMinutes: 120),
        'p2': PaperMeta(marks: 80, durationMinutes: 150),
        'p3': PaperMeta(marks: 100, durationMinutes: 150),
      },
      11: {
        'p1': PaperMeta(marks: 80, durationMinutes: 120),
        'p2': PaperMeta(marks: 80, durationMinutes: 150),
        'p3': PaperMeta(marks: 100, durationMinutes: 150),
      },
      10: {
        'p1': PaperMeta(marks: 80, durationMinutes: 120),
        'p2': PaperMeta(marks: 70, durationMinutes: 120),
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
