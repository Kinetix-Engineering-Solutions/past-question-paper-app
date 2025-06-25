// features/dashboard/widgets/subject_list.dart
import 'package:flutter/material.dart';
import '../../core/models/subject.dart';

class SubjectList extends StatelessWidget {
  final List<Subject> subjects;
  final Function(Subject) onSubjectTap;

  const SubjectList({
    super.key,
    required this.subjects,
    required this.onSubjectTap,
  });

  @override
  Widget build(BuildContext context) {
    return subjects.isEmpty
        ? const Center(
            child: Text(
              'No subjects found',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF636E72),
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return GestureDetector(
                onTap: () => onSubjectTap(subject),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: subject.color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                subject.icon,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            subject.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3436),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${subject.questionsCount} questions',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF636E72),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Login includes ${subject.loginCount} ${subject.loginType}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF636E72),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
