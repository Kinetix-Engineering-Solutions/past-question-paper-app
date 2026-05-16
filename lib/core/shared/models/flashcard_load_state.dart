import 'package:past_question_paper_v1/core/shared/models/flashcard_question.dart';

class FlashcardLoadState {
  final bool isLoading;
  final String? userMessage;
  final List<FlashcardQuestion> questions;
  final int currentIndex;
  final bool isAnswerRevealed;

  const FlashcardLoadState({
    required this.isLoading,
    required this.userMessage,
    required this.questions,
    required this.currentIndex,
    required this.isAnswerRevealed,
  });

  const FlashcardLoadState.loading({
    List<FlashcardQuestion> questions = const <FlashcardQuestion>[],
    int currentIndex = 0,
    bool isAnswerRevealed = false,
  }) : this(
         isLoading: true,
         userMessage: null,
         questions: questions,
         currentIndex: currentIndex,
         isAnswerRevealed: isAnswerRevealed,
       );

  const FlashcardLoadState.initial() : this.loading();

  const FlashcardLoadState.error(String message)
    : this(
        isLoading: false,
        userMessage: message,
        questions: const <FlashcardQuestion>[],
        currentIndex: 0,
        isAnswerRevealed: false,
      );

  const FlashcardLoadState.loaded(List<FlashcardQuestion> questions)
    : this(
        isLoading: false,
        userMessage: null,
        questions: questions,
        currentIndex: 0,
        isAnswerRevealed: false,
      );

  FlashcardLoadState copyWith({
    bool? isLoading,
    String? userMessage,
    bool clearUserMessage = false,
    List<FlashcardQuestion>? questions,
    int? currentIndex,
    bool? isAnswerRevealed,
  }) {
    return FlashcardLoadState(
      isLoading: isLoading ?? this.isLoading,
      userMessage: clearUserMessage ? null : userMessage ?? this.userMessage,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      isAnswerRevealed: isAnswerRevealed ?? this.isAnswerRevealed,
    );
  }
}
