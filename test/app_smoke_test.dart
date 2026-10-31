import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:past_question_paper_v1/core/theme/theme_mode_provider.dart';
import 'package:past_question_paper_v1/features/discovery/presentation/widgets/learner_header.dart';
import 'package:past_question_paper_v1/app/app.dart';
import 'package:past_question_paper_v1/features/discovery/data/models/discovery_data.dart';
import 'package:past_question_paper_v1/features/discovery/data/models/subject.dart';
import 'package:past_question_paper_v1/features/discovery/data/models/topic.dart';
import 'package:past_question_paper_v1/features/discovery/providers/discovery_providers.dart';

void main() {
  testWidgets('shows Grade 12 discovery content', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themePreferencesProvider.overrideWithValue(preferences),
          discoveryControllerProvider.overrideWith(
            _FakeDiscoveryController.new,
          ),
        ],
        child: const PastPapersApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LearnerHeader), findsOneWidget);
    expect(find.text('Physical Sciences'), findsOneWidget);
    expect(find.text('Newtonian Mechanics'), findsNWidgets(2));
    expect(find.text('Ready to learn?'), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) => widget is FilledButton),
      findsOneWidget,
    );
    expect(find.text('2 questions'), findsOneWidget);
  });
}

class _FakeDiscoveryController extends DiscoveryController {
  @override
  Future<DiscoveryData> build() async {
    return DiscoveryData(
      subjects: const [
        Subject(
          id: 'subject-id',
          name: 'Physical Sciences',
          slug: 'physical-sciences',
        ),
      ],
      topics: const [
        Topic(
          id: 'topic-id',
          name: 'Newtonian Mechanics',
          slug: 'newtonian-mechanics',
          grade: 12,
          displayOrder: 1,
          subjectId: 'subject-id',
          subjectName: 'Physical Sciences',
          subjectSlug: 'physical-sciences',
          questionCount: 2,
        ),
      ],
    );
  }
}
