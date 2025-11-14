import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/providers/navigation_providers.dart';
import 'package:past_question_paper_v1/utils/app_colors.dart';
import 'package:past_question_paper_v1/views/home_screen.dart';
import 'package:past_question_paper_v1/viewmodels/session_history_viewmodel.dart';
import 'package:past_question_paper_v1/views/history/pqp_history_screen.dart';
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
          const PqpHistoryScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: AppColors.neutralCard,
        unselectedItemColor: AppColors.neutralCard.withOpacity(0.7),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        onTap: (index) {
          ref.read(bottomNavigationProvider.notifier).setIndex(index);
          if (index == 1) {
            ref.read(sessionHistoryViewModelProvider.notifier).refresh();
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: AnimatedScale(
              scale: currentIndex == 0 ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: const Icon(Icons.home, size: 32),
            ),
            label: 'PQP Home',
          ),
          BottomNavigationBarItem(
            icon: AnimatedScale(
              scale: currentIndex == 1 ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: const Icon(Icons.history_edu_outlined, size: 32),
            ),
            label: 'PQP History',
          ),
          BottomNavigationBarItem(
            icon: AnimatedScale(
              scale: currentIndex == 2 ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: const Icon(Icons.person, size: 32),
            ),
            label: 'PQP Profile',
          ),
        ],
      ),
    );
  }
}
