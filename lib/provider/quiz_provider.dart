import 'package:flutter_riverpod/flutter_riverpod.dart';


enum QuizRoute {
  home,
  quizType,
  quiz,
}

final currentScreenProvider = StateProvider<QuizRoute>((ref) => QuizRoute.home);
