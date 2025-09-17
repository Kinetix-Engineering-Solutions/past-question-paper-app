// Quick test to debug the ordering validation issue
// Run with: dart debug_ordering_issue.dart

void main() {
  // Simulate the validation logic from practice_session.dart

  print('=== Debugging Drag-and-Drop Ordering Validation ===\n');

  // Test Case 1: Correct order
  List<String> correctOrder = ['step1', 'step2', 'step3', 'step4'];
  String userAnswer1 = 'step1,step2,step3,step4';
  print('Test 1 - Perfect match:');
  print('  Correct: $correctOrder');
  print('  User: ${userAnswer1.split(',')}');
  print('  Result: ${validateOrder(userAnswer1, correctOrder)}');

  // Test Case 2: Wrong order
  String userAnswer2 = 'step1,step3,step2,step4';
  print('\nTest 2 - Wrong order:');
  print('  Correct: $correctOrder');
  print('  User: ${userAnswer2.split(',')}');
  print('  Result: ${validateOrder(userAnswer2, correctOrder)}');

  // Test Case 3: Missing steps
  String userAnswer3 = 'step1,step2';
  print('\nTest 3 - Missing steps:');
  print('  Correct: $correctOrder');
  print('  User: ${userAnswer3.split(',')}');
  print('  Result: ${validateOrder(userAnswer3, correctOrder)}');

  // Test Case 4: Extra spaces
  String userAnswer4 = 'step1, step2, step3, step4';
  print('\nTest 4 - With spaces:');
  print('  Correct: $correctOrder');
  print('  User: ${userAnswer4.split(',')}');
  print('  Result: ${validateOrder(userAnswer4, correctOrder)}');

  // Test Case 5: Trimmed spaces
  String userAnswer5 = 'step1, step2, step3, step4';
  List<String> userOrderList5 = userAnswer5
      .split(',')
      .map((s) => s.trim())
      .toList();
  print('\nTest 5 - With spaces (trimmed):');
  print('  Correct: $correctOrder');
  print('  User: $userOrderList5');
  print('  Result: ${_listsEqual(userOrderList5, correctOrder)}');
}

bool validateOrder(String userAnswer, List<String> correctOrder) {
  final userOrderList = userAnswer.split(',');
  return _listsEqual(userOrderList, correctOrder);
}

bool _listsEqual<T>(List<T> list1, List<T> list2) {
  if (list1.length != list2.length) return false;
  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) return false;
  }
  return true;
}
