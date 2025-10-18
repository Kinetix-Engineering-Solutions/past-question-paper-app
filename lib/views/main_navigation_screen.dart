import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/providers/navigation_providers.dart';
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
        onTap: (index) {
          ref.read(bottomNavigationProvider.notifier).setIndex(index);
          if (index == 1) {
            ref.read(sessionHistoryViewModelProvider.notifier).refresh();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.backpack),
            label: 'PQP Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_edu_outlined),
            label: 'PQP History',
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
