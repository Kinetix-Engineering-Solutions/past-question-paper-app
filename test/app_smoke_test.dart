import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:past_question_paper_v1/app/app.dart';

void main() {
  testWidgets('shows the content foundation', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PastPapersApp()));

    expect(find.text('Content foundation ready'), findsOneWidget);
  });
}
