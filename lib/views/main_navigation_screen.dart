import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/providers/navigation_providers.dart';
import 'package:past_question_paper_v1/views/home_screen.dart';
import 'package:past_question_paper_v1/views/learning_aids_screen.dart';
import 'package:past_question_paper_v1/views/profile_screen.dart';

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavigationProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          const HomeScreen(),
          const LearningAidsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(bottomNavigationProvider.notifier).setIndex(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.backpack),
            label: 'PQP Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'PQP Resources',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'PQP Profile',
          ),
        ],
      ),
    );
  }
}
