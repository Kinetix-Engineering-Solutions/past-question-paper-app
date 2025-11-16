import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/admin/views/admin_root_view.dart';
import 'package:past_question_paper_v1/firebase_options.dart';
import 'package:past_question_paper_v1/utils/app_theme.dart';

/// Entry point for Admin Portal (Web)
/// This is a simplified version without authentication for quick data entry
/// Run with: flutter run -d chrome -t lib/main_admin.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: AdminApp()));
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PQP Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AdminRootView(),
    );
  }
}
