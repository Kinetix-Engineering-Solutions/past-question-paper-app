// providers/grade_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/grade.dart';

final gradesProvider = Provider<List<Grade>>((ref) {
  return [
    const Grade(id: '10', name: 'Grade 10'),
    const Grade(id: '11', name: 'Grade 11'),
    const Grade(id: '12', name: 'Grade 12'),
  ];
});

final selectedGradeProvider = StateProvider<String?>((ref) => null);
