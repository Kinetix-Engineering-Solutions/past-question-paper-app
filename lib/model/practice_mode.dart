import 'package:flutter/material.dart';

enum PracticeMode {
  quick(
    duration: Duration(minutes: 5),
    name: 'Quick Practice',
    description: '5-minute focused session',
  ),
  standard(
    duration: Duration(minutes: 15),
    name: 'Standard Practice',
    description: '15-minute session',
  ),
  extended(
    duration: Duration(minutes: 30),
    name: 'Extended Practice',
    description: '30-minute session',
  ),
  unlimited(
    duration: Duration(hours: 24),
    name: 'Unlimited Practice',
    description: 'No time restrictions',
  );

  const PracticeMode({
    required this.duration,
    required this.name,
    required this.description,
  });

  final Duration duration;
  final String name;
  final String description;

  /// Check if this mode has a time limit
  bool get isTimeLimited => this != PracticeMode.unlimited;

  /// Get display text for duration
  String get durationText {
    if (this == PracticeMode.unlimited) {
      return 'Unlimited';
    }

    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }

    return '${duration.inMinutes}m';
  }

  /// Get icon for practice mode
  IconData get icon {
    switch (this) {
      case PracticeMode.quick:
        return Icons.flash_on; // Lightning bolt
      case PracticeMode.standard:
        return Icons.menu_book; // Book
      case PracticeMode.extended:
        return Icons.schedule; // Clock/Timer
      case PracticeMode.unlimited:
        return Icons.all_inclusive; // Infinity symbol
    }
  }

  /// Get emoji for practice mode (deprecated - use icon instead)
  @deprecated
  String get iconEmoji {
    switch (this) {
      case PracticeMode.quick:
        return '⚡';
      case PracticeMode.standard:
        return '📚';
      case PracticeMode.extended:
        return '🎯';
      case PracticeMode.unlimited:
        return '♾️';
    }
  }

  /// Get color scheme for practice mode (Paper & Ink theme)
  static const Map<PracticeMode, int> _colorValues = {
    PracticeMode.quick: 0xFF059669, // Green ink
    PracticeMode.standard: 0xFF1E3A8A, // Blue ink
    PracticeMode.extended: 0xFFEA580C, // Orange ink
    PracticeMode.unlimited: 0xFF7C2D12, // Brown ink
  };

  int get colorValue => _colorValues[this]!;
}


