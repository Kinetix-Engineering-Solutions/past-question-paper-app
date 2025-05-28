import 'package:flutter/material.dart';
import 'package:past_question_paper_stem/domain/strategies/question_strategy.dart';
import 'package:past_question_paper_stem/models/question.dart';

/// Strategy for handling multiple choice questions
class MultipleChoiceStrategy implements QuestionStrategy {
  @override
  bool validate(Question question) {
    return question.options.isNotEmpty && question.correctAnswer.isNotEmpty;
  }

  @override
  Widget buildQuestionContent(Question question, BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        // Get user answer from context or create new if not available
        List<String> selectedOptions = List<String>.from(
          (ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?)?['userAnswer'] ??
              [],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select the correct option(s):',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            ...question.options.map((option) {
              final isSelected = selectedOptions.contains(option);
              final optionIndex = question.options.indexOf(option);
              final hasImageOption =
                  question.hasImageOptions &&
                  optionIndex < (question.optionImages?.length ?? 0);

              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedOptions.remove(option);
                    } else {
                      selectedOptions.add(option);
                    }

                    // Update user answer in route arguments
                    final arguments =
                        ModalRoute.of(context)?.settings.arguments
                            as Map<String, dynamic>? ??
                        {};
                    arguments['userAnswer'] = selectedOptions;
                    Navigator.of(context).replace(
                      oldRoute: MaterialPageRoute(
                        settings: RouteSettings(
                          name: ModalRoute.of(context)?.settings.name,
                          arguments: arguments,
                        ),
                        builder:
                            (context) => Scaffold(
                              body: Center(child: Text('Loading...')),
                            ),
                      ),
                      newRoute: MaterialPageRoute(
                        settings: RouteSettings(
                          name: ModalRoute.of(context)?.settings.name,
                          arguments: arguments,
                        ),
                        builder:
                            (context) => Scaffold(
                              body: Center(child: Text('Loading...')),
                            ),
                      ),
                    );
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(option),
                              if (hasImageOption) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    question.optionImages![optionIndex],
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  @override
  bool checkAnswer(Question question, userAnswer) {
    if (userAnswer is List<String>) {
      // Compare selected answers with correct answers
      if (userAnswer.length != question.correctAnswer.length) return false;

      for (final answer in question.correctAnswer) {
        if (!userAnswer.contains(answer)) return false;
      }
      return true;
    }
    return false;
  }

  @override
  String getCorrectAnswerText(Question question) {
    return question.correctAnswer.join(", ");
  }

  @override
  dynamic createInitialState(Question question) {
    // For multiple choice, we'll track selected options
    return <String>[];
  }
}
