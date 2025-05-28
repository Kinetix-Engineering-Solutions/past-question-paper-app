import 'package:flutter/material.dart';
import 'package:past_question_paper_stem/domain/strategies/question_strategy.dart';
import 'package:past_question_paper_stem/models/question.dart';

/// Strategy for handling true/false questions
class TrueFalseStrategy implements QuestionStrategy {
  @override
  bool validate(Question question) {
    // Check that options contain "True" and "False"
    final options = question.options.map((o) => o.toLowerCase()).toList();
    return options.contains('true') &&
        options.contains('false') &&
        question.correctAnswer.isNotEmpty;
  }

  @override
  Widget buildQuestionContent(Question question, BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        // Get user answer from context or create new if not available
        String? selectedOption =
            (ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?)?['userAnswer'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select True or False:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),

            // True option button
            _buildTrueFalseButton(
              context,
              'True',
              selectedOption == 'True',
              () {
                setState(() {
                  selectedOption = 'True';

                  // Update user answer in route arguments
                  final arguments =
                      ModalRoute.of(context)?.settings.arguments
                          as Map<String, dynamic>? ??
                      {};
                  arguments['userAnswer'] = selectedOption;
                  Navigator.of(context).replace(
                    oldRoute: MaterialPageRoute(
                      settings: RouteSettings(
                        name: ModalRoute.of(context)?.settings.name,
                        arguments: arguments,
                      ),
                      builder:
                          (context) =>
                              Scaffold(body: Center(child: Text('Loading...'))),
                    ),
                    newRoute: MaterialPageRoute(
                      settings: RouteSettings(
                        name: ModalRoute.of(context)?.settings.name,
                        arguments: arguments,
                      ),
                      builder:
                          (context) =>
                              Scaffold(body: Center(child: Text('Loading...'))),
                    ),
                  );
                });
              },
            ),

            const SizedBox(height: 12),

            // False option button
            _buildTrueFalseButton(
              context,
              'False',
              selectedOption == 'False',
              () {
                setState(() {
                  selectedOption = 'False';

                  // Update user answer in route arguments
                  final arguments =
                      ModalRoute.of(context)?.settings.arguments
                          as Map<String, dynamic>? ??
                      {};
                  arguments['userAnswer'] = selectedOption;
                  Navigator.of(context).replace(
                    oldRoute: MaterialPageRoute(
                      settings: RouteSettings(
                        name: ModalRoute.of(context)?.settings.name,
                        arguments: arguments,
                      ),
                      builder:
                          (context) =>
                              Scaffold(body: Center(child: Text('Loading...'))),
                    ),
                    newRoute: MaterialPageRoute(
                      settings: RouteSettings(
                        name: ModalRoute.of(context)?.settings.name,
                        arguments: arguments,
                      ),
                      builder:
                          (context) =>
                              Scaffold(body: Center(child: Text('Loading...'))),
                    ),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrueFalseButton(
    BuildContext context,
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? (text == 'True'
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2))
                  : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isSelected
                    ? (text == 'True' ? Colors.green : Colors.red)
                    : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  isSelected
                      ? (text == 'True'
                          ? Colors.green.shade800
                          : Colors.red.shade800)
                      : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool checkAnswer(Question question, userAnswer) {
    if (userAnswer is String) {
      // Case insensitive comparison of the selected answer with correct answer
      return question.correctAnswer.first.toLowerCase() ==
          userAnswer.toLowerCase();
    }
    return false;
  }

  @override
  String getCorrectAnswerText(Question question) {
    return question.correctAnswer.first;
  }

  @override
  dynamic createInitialState(Question question) {
    // For true/false, we'll just track the selected option (if any)
    return null;
  }
}
