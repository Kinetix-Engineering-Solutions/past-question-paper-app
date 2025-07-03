import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_stem/presentation/views/question_screen_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  // ignore: use_super_parameters
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize app data

    return MaterialApp(
      title: 'STEM Question Papers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      //initialRoute: '/',
      //onGenerateRoute: AppRouter.generateRoute,
      home: QuestionScreenTest(
        questionId: 'math_grade_12_algebra_june_q1',
        questionIds: [
          'math_grade_12_algebra_june_q1',
          'math_grade_12_algebra_june_q2',
          'math_grade_12_algebra_june_q3',
          // Add more question IDs as needed
        ],
      ),
    );
  }
}
