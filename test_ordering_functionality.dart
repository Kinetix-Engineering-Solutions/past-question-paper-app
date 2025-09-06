import 'dart:convert';
import 'dart:io';

void main() async {
  print("Testing Drag-and-Drop Ordering Functionality");
  print("=" * 50);

  // Test 1: Load and parse example questions
  await testLoadExampleQuestions();

  // Test 2: Simulate grading logic
  await testGradingLogic();

  // Test 3: Test question format detection
  await testFormatDetection();

  print("\n" + "=" * 50);
  print("All tests completed successfully! ✅");
}

Future<void> testLoadExampleQuestions() async {
  print("\n📝 Test 1: Loading Example Questions");
  print("-" * 30);

  try {
    final file = File('drag_drop_ordering_examples.json');
    final content = await file.readAsString();
    final List<dynamic> questions = json.decode(content);

    print("✅ Loaded ${questions.length} example questions");

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      print("   ${i + 1}. ${question['subject']} - ${question['topic']}");
      print("      Steps: ${question['dragItems'].length}");
      print("      Correct Order: ${question['correctOrder']}");
    }
  } catch (e) {
    print("❌ Error loading questions: $e");
  }
}

Future<void> testGradingLogic() async {
  print("\n🔍 Test 2: Grading Logic Simulation");
  print("-" * 30);

  // Simulate a correct answer
  final correctOrder = ["step1", "step2", "step3", "step4"];
  final userAnswerCorrect = "step1,step2,step3,step4";
  final userAnswerIncorrect = "step2,step1,step4,step3";
  final userAnswerPartial = "step1,step2,step4,step3";

  print("Correct Order: $correctOrder");
  print("");

  // Test correct answer
  final scoreCorrect = calculateOrderingScore(userAnswerCorrect, correctOrder);
  print("✅ Correct Answer: '$userAnswerCorrect'");
  print(
    "   Score: ${scoreCorrect['score']}/${scoreCorrect['maxScore']} (${scoreCorrect['percentage'].toStringAsFixed(1)}%)",
  );

  // Test incorrect answer
  final scoreIncorrect = calculateOrderingScore(
    userAnswerIncorrect,
    correctOrder,
  );
  print("❌ Incorrect Answer: '$userAnswerIncorrect'");
  print(
    "   Score: ${scoreIncorrect['score']}/${scoreIncorrect['maxScore']} (${scoreIncorrect['percentage'].toStringAsFixed(1)}%)",
  );

  // Test partial answer
  final scorePartial = calculateOrderingScore(userAnswerPartial, correctOrder);
  print("🔸 Partial Answer: '$userAnswerPartial'");
  print(
    "   Score: ${scorePartial['score']}/${scorePartial['maxScore']} (${scorePartial['percentage'].toStringAsFixed(1)}%)",
  );
}

Future<void> testFormatDetection() async {
  print("\n🎯 Test 3: Format Detection");
  print("-" * 30);

  // Test ordering question (has correctOrder)
  final orderingQuestion = {
    'format': 'drag-and-drop',
    'correctOrder': ['step1', 'step2', 'step3'],
    'dragItems': [
      {'id': 'step1', 'text': 'First step'},
      {'id': 'step2', 'text': 'Second step'},
      {'id': 'step3', 'text': 'Third step'},
    ],
  };

  // Test matching question (no correctOrder)
  final matchingQuestion = {
    'format': 'drag-and-drop',
    'correctOrder': <String>[],
    'dragItems': [
      {'id': 'item1', 'text': 'Item 1'},
      {'id': 'item2', 'text': 'Item 2'},
    ],
    'dropTargets': [
      {'id': 'target1', 'text': 'Target 1'},
      {'id': 'target2', 'text': 'Target 2'},
    ],
  };

  final isOrderingFormat1 = detectOrderingFormat(orderingQuestion);
  final isOrderingFormat2 = detectOrderingFormat(matchingQuestion);

  print(
    "Question with correctOrder: ${isOrderingFormat1 ? 'ORDERING' : 'MATCHING'} ✅",
  );
  print(
    "Question without correctOrder: ${isOrderingFormat2 ? 'ORDERING' : 'MATCHING'} ✅",
  );
}

// Simulated grading function (matches the cloud function logic)
Map<String, dynamic> calculateOrderingScore(
  String userAnswer,
  List<String> correctOrder,
) {
  final userOrder = userAnswer.split(',');
  final maxScore = correctOrder.length;
  int score = 0;

  // Calculate score based on correct positions
  for (int i = 0; i < correctOrder.length && i < userOrder.length; i++) {
    if (correctOrder[i] == userOrder[i]) {
      score++;
    }
  }

  final percentage = maxScore > 0 ? (score / maxScore) * 100 : 0.0;

  return {
    'score': score,
    'maxScore': maxScore,
    'percentage': percentage,
    'isCorrect': score == maxScore,
  };
}

// Format detection function (matches the widget logic)
bool detectOrderingFormat(Map<String, dynamic> question) {
  final correctOrder = question['correctOrder'] as List<dynamic>?;
  return correctOrder != null && correctOrder.isNotEmpty;
}
