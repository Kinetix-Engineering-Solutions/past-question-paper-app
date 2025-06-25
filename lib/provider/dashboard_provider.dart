// providers/dashboard_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final showPopupProvider = StateProvider<bool>((ref) => false);

final userStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return {
    'totalQuizzes': 15,
    'averageScore': 85.5,
    'bestSubject': 'Mathematics',
    'weeklyProgress': 12,
    'streak': 7,
  };
});
