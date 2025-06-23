// subject_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subject.dart';

final subjectsProvider = Provider<List<Subject>>((ref) {
  return [
    const Subject(
      id: '1',
      name: 'Mathematics',
      icon: '🔢',
      color: Colors.blue,
      questionsCount: 400,
      loginCount: 15,
      loginType: 'single app',
    ),
    const Subject(
      id: '2',
      name: 'Physics',
      icon: '⚛️',
      color: Colors.purple,
      questionsCount: 250,
      loginCount: 8,
      loginType: 'single app',
    ),
    const Subject(
      id: '3',
      name: 'Chemistry',
      icon: '🧪',
      color: Colors.green,
      questionsCount: 300,
      loginCount: 10,
      loginType: 'shared apps',
    ),
    const Subject(
      id: '4',
      name: 'Biology',
      icon: '🧬',
      color: Colors.orange,
      questionsCount: 365,
      loginCount: 6,
      loginType: 'shared apps',
    ),
    const Subject(
      id: '5',
      name: 'English',
      icon: '📚',
      color: Colors.red,
      questionsCount: 280,
      loginCount: 5,
      loginType: 'single app',
    ),
    const Subject(
      id: '6',
      name: 'History',
      icon: '🏛️',
      color: Colors.brown,
      questionsCount: 58,
      loginCount: 10,
      loginType: 'single app',
    ),
    const Subject(
      id: '7',
      name: 'Geography',
      icon: '🌍',
      color: Colors.teal,
      questionsCount: 205,
      loginCount: 1,
      loginType: 'single app',
    ),
    const Subject(
      id: '8',
      name: 'Computer Science',
      icon: '💻',
      color: Colors.indigo,
      questionsCount: 320,
      loginCount: 12,
      loginType: 'shared apps',
    ),
  ];
});

/// Tracks selected subject IDs
final selectedSubjectsProvider =
    StateNotifierProvider<SelectedSubjectsNotifier, Set<String>>((ref) {
  return SelectedSubjectsNotifier();
});

class SelectedSubjectsNotifier extends StateNotifier<Set<String>> {
  SelectedSubjectsNotifier() : super(<String>{});

  void toggleSubject(String subjectId) {
    if (state.contains(subjectId)) {
      state = Set.from(state)..remove(subjectId);
    } else {
      state = Set.from(state)..add(subjectId);
    }
  }

  void clearAll() {
    state = <String>{};
  }

  void selectAll(List<String> subjectIds) {
    state = Set.from(subjectIds);
  }
}

/// Provides full subject objects for selected IDs (used in DashboardPage)
final selectedSubjectsObjectsProvider = Provider<List<Subject>>((ref) {
  final allSubjects = ref.watch(subjectsProvider);
  final selectedIds = ref.watch(selectedSubjectsProvider);
  return allSubjects
      .where((subject) => selectedIds.contains(subject.id))
      .toList();
});
