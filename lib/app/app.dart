import 'package:flutter/material.dart';
import 'package:past_question_paper_v1/core/theme/app_theme.dart';

import '../features/auth/presentation/account_declaration_gate.dart';

class PastPapersApp extends StatelessWidget {
  const PastPapersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Past Question Paper',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AccountDeclarationGate(),
    );
  }
}
