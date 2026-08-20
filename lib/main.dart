import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:past_question_paper_v1/app/app.dart';

void main() {
  runApp(const ProviderScope(child: PastPapersApp()));
}
