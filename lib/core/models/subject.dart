import 'dart:ui';

class Subject {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final int questionsCount;
  final int loginCount; // Add this
  final String loginType; // Add this ('single app' or 'shared apps')

  const Subject({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.questionsCount,
    required this.loginCount, // Add this
    required this.loginType, // Add this
  });
}
