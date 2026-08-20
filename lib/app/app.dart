import 'package:flutter/material.dart';

import '../features/discovery/presentation/discovery_screen.dart';

class PastPapersApp extends StatelessWidget {
  const PastPapersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Past Question Paper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3157D5)),
        useMaterial3: true,
      ),
      home: const DiscoveryScreen(),
    );
  }
}
