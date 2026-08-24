import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:past_question_paper_v1/features/profile/data/profile_repository.dart';
import 'package:past_question_paper_v1/features/profile/domain/learner_profile.dart';
import 'package:past_question_paper_v1/features/profile/providers/profile_providers.dart';

void main() {
  const userId = 'user-1';
  final timestamp = DateTime.utc(2026, 8, 22);

  LearnerProfile profile({String? displayName = 'Irvin', int? grade = 12}) {
    return LearnerProfile(
      userId: userId,
      displayName: displayName,
      grade: grade,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  test('loads the current learner profile', () async {
    final repository = FakeProfileRepository(loadedProfile: profile());

    final container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      profileControllerProvider(userId).future,
    );

    expect(result.displayName, 'Irvin');
    expect(result.grade, 12);
    expect(repository.loadedUserId, userId);
  });

  test('updates and exposes the saved profile', () async {
    final repository = FakeProfileRepository(
      loadedProfile: profile(displayName: null, grade: null),
      updatedProfile: profile(displayName: 'Irvin Senwedi', grade: 12),
    );

    final container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final provider = profileControllerProvider(userId);

    await container.read(provider.future);

    await container
        .read(provider.notifier)
        .updateProfile(displayName: '  Irvin Senwedi  ', grade: 12);

    final result = container.read(provider).value;

    expect(result?.displayName, 'Irvin Senwedi');
    expect(result?.grade, 12);
    expect(repository.savedDisplayName, 'Irvin Senwedi');
    expect(repository.savedGrade, 12);
    expect(repository.updateCount, 1);
  });

  test('rejects an invalid display name', () async {
    final repository = FakeProfileRepository(loadedProfile: profile());

    final container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final provider = profileControllerProvider(userId);

    await container.read(provider.future);

    await container
        .read(provider.notifier)
        .updateProfile(displayName: 'A', grade: 12);

    expect(container.read(provider).hasError, isTrue);
    expect(repository.updateCount, 0);
  });
}

final class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({required this.loadedProfile, this.updatedProfile});

  final LearnerProfile loadedProfile;
  final LearnerProfile? updatedProfile;

  String? loadedUserId;
  String? savedDisplayName;
  int? savedGrade;
  int updateCount = 0;

  @override
  Future<LearnerProfile> getProfile({required String userId}) async {
    loadedUserId = userId;
    return loadedProfile;
  }

  @override
  Future<LearnerProfile> updateProfile({
    required String displayName,
    required int grade,
  }) async {
    updateCount++;
    savedDisplayName = displayName;
    savedGrade = grade;

    final result = updatedProfile;

    if (result == null) {
      throw StateError('No fake updated profile configured.');
    }

    return result;
  }
}
