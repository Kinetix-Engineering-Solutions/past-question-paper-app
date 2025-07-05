// features/dashboard/widgets/recent_favorites_tabs.dart
import 'package:flutter/material.dart';

class RecentFavoritesTabs extends StatelessWidget {
  const RecentFavoritesTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          const Text(
            'Recent',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6C5CE7),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Favorites',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
