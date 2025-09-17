// Debug script to check what's being sent to and received from Firebase Functions
// Add this to your practice_viewmodel.dart temporarily for debugging

/*
Add this to the submitTest() method in practice_viewmodel.dart:

  Future<Map<String, dynamic>?> submitTest() async {
    if (!isActive || state.isSubmitting) return null;

    state = state.copyWith(isSubmitting: true);

    try {
      // Get the subject and paper from the first question to pass to the cloud function
      final subject = state.questions.first.subject;
      final paper = state.questions.first.paper;

      // === DEBUG: Log what we're sending ===
      print('=== SUBMITTING TEST DATA ===');
      print('Subject: $subject');
      print('Paper: $paper');
      print('User Answers:');
      state.userAnswers.forEach((questionId, answer) {
        print('  $questionId: "$answer" (${answer.runtimeType})');
      });
      print('Questions with correctOrder:');
      for (final q in state.questions) {
        if (q.format == 'drag-and-drop' && q.correctOrder.isNotEmpty) {
          print('  ${q.id}: correctOrder = ${q.correctOrder}');
        }
      }
      print('=== END SUBMIT DATA ===\n');

      // Call the repository to trigger the 'gradeTest' Cloud Function
      final gradingResults = await _questionRepository.gradeTest(
        userAnswers: state.userAnswers,
        subject: subject,
        paper: paper,
      );

      // === DEBUG: Log what we received ===
      print('=== RECEIVED GRADING RESULTS ===');
      print('Raw response: $gradingResults');
      if (gradingResults['results'] != null) {
        print('Individual question results:');
        for (final result in gradingResults['results']) {
          if (result['format'] == 'dragAndDrop' && result['subFormat'] == 'ordering') {
            print('  Question ${result['questionId']}:');
            print('    User answers: ${result['userAnswers']}');
            print('    Correct order: ${result['correctOrder']}');
            print('    Correct count: ${result['correctCount']}/${result['totalSteps']}');
            print('    Is correct: ${result['isCorrect']}');
            print('    Marks: ${result['marksAwarded']}/${result['maxMarks']}');
          }
        }
      }
      print('=== END GRADING RESULTS ===\n');

      if (!isActive) return null; // Check if still active after async operation

      state = state.copyWith(isSubmitting: false);

      // Return both grading results and questions for detailed results screen
      return {
        'gradingResults': gradingResults,
        'questions': state.questions.map((q) => q.toMap()).toList(),
      };
    } catch (e) {
      print('Error submitting test: $e');
      if (isActive) {
        state = state.copyWith(isSubmitting: false);
      }
      return null; // Return null to indicate failure
    }
  }
*/

console.log('Add the debug code above to your practice_viewmodel.dart submitTest() method');
console.log('Then test the drag-and-drop ordering and check the console output');
console.log('This will help us see exactly what data is being sent and received');
