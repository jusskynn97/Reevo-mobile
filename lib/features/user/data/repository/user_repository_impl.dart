import 'package:reevo/features/user/data/datasource/user_remote_datasource.dart';
import 'package:reevo/features/user/domain/entity/user_entity.dart';
import 'package:reevo/features/user/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> getUserProfile(String userId, String accessToken) async {
    return await remoteDataSource.getUserProfile(userId, accessToken);
  }

  @override
  Future<User> getOtherUserProfile(String userId, String accessToken) async {
    return await remoteDataSource.getOtherUserProfile(userId, accessToken);
  }

  @override
  Future<void> followUser(String userId, String accessToken) async {
    return await remoteDataSource.followUser(userId, accessToken);
  }

  @override
  Future<void> unfollowUser(String userId, String accessToken) async {
    return await remoteDataSource.unfollowUser(userId, accessToken);
  }
}
