import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:past_question_paper_v1/features/comments/data/question_comments_repository.dart';
import 'package:past_question_paper_v1/features/comments/domain/question_comment.dart';
import 'package:past_question_paper_v1/features/comments/providers/question_comments_providers.dart';

void main() {
  const questionId = 'question-1';
  final timestamp = DateTime.utc(2026, 8, 22);

  QuestionComment comment({
    required String id,
    bool isOwnComment = false,
    String body = 'Helpful explanation.',
  }) {
    return QuestionComment(
      id: id,
      questionId: questionId,
      authorUserId: 'user-1',
      authorDisplayName: 'Irvin',
      body: body,
      externalUrl: null,
      linkProvider: null,
      isOwnComment: isOwnComment,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  test('loads comments for a question', () async {
    final repository = FakeQuestionCommentsRepository(
      loadedComments: [comment(id: 'comment-1')],
    );

    final container = ProviderContainer(
      overrides: [
        questionCommentsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      questionCommentsControllerProvider(questionId).future,
    );

    expect(result.comments.length, 1);
    expect(result.comments.first.id, 'comment-1');
    expect(repository.loadedQuestionId, questionId);
  });

  test('adds a newly created comment to the list', () async {
    final createdComment = comment(
      id: 'comment-2',
      isOwnComment: true,
      body: 'My explanation.',
    );

    final repository = FakeQuestionCommentsRepository(
      loadedComments: [comment(id: 'comment-1')],
      createdComment: createdComment,
    );

    final container = ProviderContainer(
      overrides: [
        questionCommentsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final provider = questionCommentsControllerProvider(questionId);

    await container.read(provider.future);

    final created = await container
        .read(provider.notifier)
        .createComment(body: '  My explanation.  ');

    final state = container.read(provider).value;

    expect(created, isTrue);
    expect(state?.comments.length, 2);
    expect(state?.comments.first.id, 'comment-2');
    expect(repository.createdBody, 'My explanation.');
    expect(repository.createCount, 1);
  });

  test('restores a comment when deletion fails', () async {
    final ownComment = comment(id: 'comment-1', isOwnComment: true);

    final repository = FakeQuestionCommentsRepository(
      loadedComments: [ownComment],
      deleteResult: false,
    );

    final container = ProviderContainer(
      overrides: [
        questionCommentsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final provider = questionCommentsControllerProvider(questionId);

    await container.read(provider.future);

    final deleted = await container
        .read(provider.notifier)
        .deleteComment('comment-1');

    final state = container.read(provider).value;

    expect(deleted, isFalse);
    expect(state?.comments.length, 1);
    expect(state?.comments.first.id, 'comment-1');
    expect(state?.errorMessage, 'Unable to delete your comment.');
  });
}

final class FakeQuestionCommentsRepository
    implements QuestionCommentsRepository {
  FakeQuestionCommentsRepository({
    this.loadedComments = const [],
    this.createdComment,
    this.deleteResult = true,
  });

  final List<QuestionComment> loadedComments;
  final QuestionComment? createdComment;
  final bool deleteResult;

  String? loadedQuestionId;
  String? createdQuestionId;
  String? createdBody;
  String? createdExternalUrl;
  String? deletedCommentId;

  int createCount = 0;

  @override
  Future<List<QuestionComment>> getComments({
    required String questionId,
    int limit = 50,
  }) async {
    loadedQuestionId = questionId;
    return loadedComments;
  }

  @override
  Future<QuestionComment> createComment({
    required String questionId,
    required String body,
    String? externalUrl,
  }) async {
    createCount++;
    createdQuestionId = questionId;
    createdBody = body;
    createdExternalUrl = externalUrl;

    final result = createdComment;

    if (result == null) {
      throw StateError('No fake created comment configured.');
    }

    return result;
  }

  @override
  Future<bool> deleteComment({required String commentId}) async {
    deletedCommentId = commentId;
    return deleteResult;
  }
}
