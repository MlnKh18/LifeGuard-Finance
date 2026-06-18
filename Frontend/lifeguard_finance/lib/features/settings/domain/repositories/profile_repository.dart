import '../entities/profile_summary.dart';

abstract class ProfileRepository {
  Future<ProfileSummary> getProfileSummary();
  Future<void> clearLocalProfileData();
}
