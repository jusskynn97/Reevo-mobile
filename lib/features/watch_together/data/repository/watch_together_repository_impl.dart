
import '../../domain/entity/watch_room_entity.dart';
import '../../domain/entity/room_participant_entity.dart';
import '../../domain/entity/room_message_entity.dart';
import '../../domain/repository/watch_together_repository.dart';
import '../datasource/watch_together_remote_datasource.dart';
import '../model/watch_room_model.dart';
import '../model/room_participant_model.dart';
import '../model/room_message_model.dart';

class WatchTogetherRepositoryImpl implements WatchTogetherRepository {
  final WatchTogetherRemoteDatasource remoteDatasource;

  WatchTogetherRepositoryImpl(this.remoteDatasource);

  @override
  Future<WatchRoomEntity> createRoom({
    required String name,
    String? description,
    String? videoId,
    String? videoUrl,
    String? thumbnailUrl,
    String? privacy,
    int? maxUsers,
  }) {
    return remoteDatasource.createRoom(
      name: name,
      description: description,
      videoId: videoId,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      privacy: privacy,
      maxUsers: maxUsers,
    );
  }

  @override
  Future<List<WatchRoomEntity>> getPublicRooms() async {
    final models = await remoteDatasource.getPublicRooms();
    return models;
  }

  @override
  Future<WatchRoomEntity> getRoom(String roomId) {
    return remoteDatasource.getRoom(roomId);
  }

  @override
  Future<void> joinRoom(String roomId) {
    return remoteDatasource.joinRoom(roomId);
  }

  @override
  Future<void> leaveRoom(String roomId) {
    return remoteDatasource.leaveRoom(roomId);
  }

  @override
  Future<List<RoomParticipantEntity>> getRoomParticipants(String roomId) async {
    final models = await remoteDatasource.getRoomParticipants(roomId);
    return models;
  }

  @override
  Future<RoomMessageEntity> sendMessage({
    required String roomId,
    required String content,
    String? imageUrl,
  }) {
    return remoteDatasource.sendMessage(
      roomId: roomId,
      content: content,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<List<RoomMessageEntity>> getRoomMessages(String roomId) async {
    final models = await remoteDatasource.getRoomMessages(roomId);
    return models;
  }

  @override
  Future<void> deleteRoom(String roomId) {
    return remoteDatasource.deleteRoom(roomId);
  }
}

