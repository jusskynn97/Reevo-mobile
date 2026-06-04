import 'package:dio/dio.dart';
import 'package:reevo/features/interaction/data/model/comment_model.dart';

abstract class InteractionRemoteDataSource {
  Future<InteractionActionResponseModel> likeVideo(String videoId);
  Future<InteractionActionResponseModel> unlikeVideo(String videoId);
  Future<CommentResponseModel> commentVideo({
    required String videoId,
    required String content,
    String? parentId,
  });
  Future<CommentListResponseModel> getComments(String videoId);
  Future<InteractionActionResponseModel> likeComment(String commentId);
  Future<InteractionActionResponseModel> unlikeComment(String commentId);
  Future<CommentListResponseModel> getReplies(String commentId);
}

class InteractionRemoteDataSourceImpl implements InteractionRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  InteractionRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<InteractionActionResponseModel> likeVideo(String videoId) async {
    try {
      final response = await dio.post('$baseUrl/api/interactions/videos/$videoId/like');
      return InteractionActionResponseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<InteractionActionResponseModel> unlikeVideo(String videoId) async {
    try {
      final response = await dio.delete('$baseUrl/api/interactions/videos/$videoId/like');
      return InteractionActionResponseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CommentResponseModel> commentVideo({
    required String videoId,
    required String content,
    String? parentId,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/interactions/videos/$videoId/comments',
        data: {
          'content': content,
          if (parentId != null) 'parentId': parentId,
        },
      );
      return CommentResponseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CommentListResponseModel> getComments(String videoId) async {
    try {
      final response = await dio.get('$baseUrl/api/interactions/videos/$videoId/comments');
      return CommentListResponseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<InteractionActionResponseModel> likeComment(String commentId) async {
    try {
      final response = await dio.post('$baseUrl/api/interactions/comments/$commentId/like');
      return InteractionActionResponseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<InteractionActionResponseModel> unlikeComment(String commentId) async {
    try {
      final response = await dio.delete('$baseUrl/api/interactions/comments/$commentId/like');
      return InteractionActionResponseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CommentListResponseModel> getReplies(String commentId) async {
    try {
      final response = await dio.get('$baseUrl/api/interactions/comments/$commentId/replies');
      return CommentListResponseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
