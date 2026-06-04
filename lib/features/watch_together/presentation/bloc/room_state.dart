
part of 'room_bloc.dart';

abstract class RoomState {}

class RoomInitial extends RoomState {}

class RoomLoading extends RoomState {}

class RoomLoaded extends RoomState {
  final WatchRoomEntity room;
  final List<RoomParticipantEntity> participants;
  final List<RoomMessageEntity> messages;
  final VideoSyncEventEntity? videoSyncEvent;
  final VideoChangeEventEntity? videoChangeEvent;
  final bool isMicMuted;
  final bool isChatOpen;
  final bool isParticipantsDrawerOpen;

  RoomLoaded({
    required this.room,
    required this.participants,
    required this.messages,
    this.videoSyncEvent,
    this.videoChangeEvent,
    this.isMicMuted = true,
    this.isChatOpen = false,
    this.isParticipantsDrawerOpen = false,
  });

  RoomLoaded copyWith({
    WatchRoomEntity? room,
    List<RoomParticipantEntity>? participants,
    List<RoomMessageEntity>? messages,
    VideoSyncEventEntity? videoSyncEvent,
    VideoChangeEventEntity? videoChangeEvent,
    bool? isMicMuted,
    bool? isChatOpen,
    bool? isParticipantsDrawerOpen,
  }) {
    return RoomLoaded(
      room: room ?? this.room,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      videoSyncEvent: videoSyncEvent,
      videoChangeEvent: videoChangeEvent,
      isMicMuted: isMicMuted ?? this.isMicMuted,
      isChatOpen: isChatOpen ?? this.isChatOpen,
      isParticipantsDrawerOpen: isParticipantsDrawerOpen ?? this.isParticipantsDrawerOpen,
    );
  }
}

class RoomError extends RoomState {
  final String message;

  RoomError(this.message);
}
