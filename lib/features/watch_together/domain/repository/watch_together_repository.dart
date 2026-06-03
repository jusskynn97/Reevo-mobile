
import '../entity/watch_room_entity.dart';
import '../entity/room_participant_entity.dart';
import '../entity/room_message_entity.dart';

abstract class WatchTogetherRepository {
  Future<WatchRoomEntity> createRoom({
    required String name,
    String? description,
    String? videoId,
    String? videoUrl,
    String? thumbnailUrl,
    String? privacy,
    int? maxUsers,
  });

  Future<List<WatchRoomEntity>> getPublicRooms();

  Future<WatchRoomEntity> getRoom(String roomId);

  Future<void> joinRoom(String roomId);

  Future<void> leaveRoom(String roomId);

  Future<List<RoomParticipantEntity>> getRoomParticipants(String roomId);

  Future<RoomMessageEntity> sendMessage({
    required String roomId,
    required String content,
    String? imageUrl,
  });

  Future<List<RoomMessageEntity>> getRoomMessages(String roomId);
}

