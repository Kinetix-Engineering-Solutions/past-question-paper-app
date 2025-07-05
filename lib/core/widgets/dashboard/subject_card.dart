// widgets/subject_card.dart
import 'package:flutter/material.dart';
import '../../models/subject.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final bool isSelected;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? subject.color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? subject.color.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: subject.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  subject.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${subject.questionsCount} questions available',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF636E72),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? subject.color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? subject.color : const Color(0xFFDDD6FE),
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
