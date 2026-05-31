import 'package:dio/dio.dart';
import 'package:reevo/features/user/domain/entity/user_entity.dart';

abstract class UserRemoteDataSource {
  Future<User> getUserProfile(String userId, String accessToken);
  Future<User> getOtherUserProfile(String userId, String accessToken);
  Future<void> followUser(String userId, String accessToken);
  Future<void> unfollowUser(String userId, String accessToken);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  UserRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<User> getUserProfile(String userId, String accessToken) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/users/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return User(
          id: data['id'],
          username: data['username'],
          displayName: data['displayName'],
          avatarUrl: data['avatarUrl'],
          bio: data['bio'],
          followerCount: data['followerCount'],
          followingCount: data['followingCount'],
          friendCount: data['friendCount'],
          isFollowing: data['isFollowing'],
          isFriend: data['isFriend'],
        );
      }
      throw Exception('Failed to get user profile');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get user profile');
    }
  }

  @override
  Future<User> getOtherUserProfile(String userId, String accessToken) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/users/$userId/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return User(
          id: data['id'],
          username: data['username'],
          displayName: data['displayName'],
          avatarUrl: data['avatarUrl'],
          bio: data['bio'],
          followerCount: data['followerCount'],
          followingCount: data['followingCount'],
          friendCount: data['friendCount'],
          isFollowing: data['isFollowing'],
          isFriend: data['isFriend'],
        );
      }
      throw Exception('Failed to get user profile');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get user profile');
    }
  }

  @override
  Future<void> followUser(String userId, String accessToken) async {
    try {
      await dio.post(
        '$baseUrl/api/users/$userId/follow',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to follow user');
    }
  }

  @override
  Future<void> unfollowUser(String userId, String accessToken) async {
    try {
      await dio.delete(
        '$baseUrl/api/users/$userId/follow',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to unfollow user');
    }
  }
}
