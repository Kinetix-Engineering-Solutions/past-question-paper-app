import '../domain/learner_profile.dart';

abstract interface class ProfileRepository {
  Future<LearnerProfile> getProfile({required String userId});

  Future<LearnerProfile> updateProfile({
    required String displayName,
    required int grade,
  });
}
