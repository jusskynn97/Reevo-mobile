import 'package:reevo/features/user/domain/entity/user_entity.dart';

abstract class UserRepository {
  Future<User> getUserProfile(String userId, String accessToken);
  Future<User> getOtherUserProfile(String userId, String accessToken);
  Future<void> followUser(String userId, String accessToken);
  Future<void> unfollowUser(String userId, String accessToken);
}
