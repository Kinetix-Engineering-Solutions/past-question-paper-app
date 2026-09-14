import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/theme_mode_provider.dart';
import 'package:past_question_paper_v1/core/theme/app_theme.dart';

import '../features/auth/presentation/account_declaration_gate.dart';

class PastPapersApp extends ConsumerWidget {
  const PastPapersApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Past Question Paper',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      home: const AccountDeclarationGate(),
    );
  }
}
