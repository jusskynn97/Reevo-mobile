
import 'dart:convert';
import 'package:dio/dio.dart';
import '../model/watch_room_model.dart';
import '../model/room_participant_model.dart';
import '../model/room_message_model.dart';
import '../model/video_sync_event_model.dart';

class WatchTogetherRemoteDatasource {
  final Dio dio;

  WatchTogetherRemoteDatasource(this.dio);

  Future<WatchRoomModel> createRoom({
    required String name,
    String? description,
    String? videoId,
    String? videoUrl,
    String? thumbnailUrl,
    String? privacy,
    int? maxUsers,
  }) async {
    final response = await dio.post(
      '/api/watch-together/rooms',
      data: {
        'name': name,
        'description': description,
        'videoId': videoId,
        'videoUrl': videoUrl,
        'thumbnailUrl': thumbnailUrl,
        'privacy': privacy,
        'maxUsers': maxUsers,
      },
    );
    return WatchRoomModel.fromJson(response.data['data']);
  }

  Future<List<WatchRoomModel>> getPublicRooms() async {
    final response = await dio.get('/api/watch-together/rooms/public');
    return (response.data['data'] as List)
        .map((json) => WatchRoomModel.fromJson(json))
        .toList();
  }

  Future<WatchRoomModel> getRoom(String roomId) async {
    final response = await dio.get('/api/watch-together/rooms/$roomId');
    return WatchRoomModel.fromJson(response.data['data']);
  }

  Future<void> joinRoom(String roomId) async {
    await dio.post('/api/watch-together/rooms/$roomId/join');
  }

  Future<void> leaveRoom(String roomId) async {
    await dio.post('/api/watch-together/rooms/$roomId/leave');
  }

  Future<List<RoomParticipantModel>> getRoomParticipants(String roomId) async {
    final response = await dio.get('/api/watch-together/rooms/$roomId/participants');
    return (response.data['data'] as List)
        .map((json) => RoomParticipantModel.fromJson(json))
        .toList();
  }

  Future<RoomMessageModel> sendMessage({
    required String roomId,
    required String content,
    String? imageUrl,
  }) async {
    final response = await dio.post(
      '/api/watch-together/rooms/$roomId/messages',
      data: {
        'content': content,
        'imageUrl': imageUrl,
      },
    );
    return RoomMessageModel.fromJson(response.data['data']);
  }

  Future<List<RoomMessageModel>> getRoomMessages(String roomId) async {
    final response = await dio.get('/api/watch-together/rooms/$roomId/messages');
    return (response.data['data'] as List)
        .map((json) => RoomMessageModel.fromJson(json))
        .toList();
  }

  Future<void> deleteRoom(String roomId) async {
    await dio.delete('/api/watch-together/rooms/$roomId');
  }
}

