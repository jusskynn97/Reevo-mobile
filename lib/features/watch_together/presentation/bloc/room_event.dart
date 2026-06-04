
part of 'room_bloc.dart';

abstract class RoomEvent {
  const RoomEvent();
}

class InitializeRoom extends RoomEvent {
  final String roomId;

  InitializeRoom(this.roomId);
}

class SendMessage extends RoomEvent {
  final String content;

  SendMessage(this.content);
}

class SendVideoSync extends RoomEvent {
  final String type;
  final int position;
  final bool? playing;

  SendVideoSync({
    required this.type,
    required this.position,
    this.playing,
  });
}

class ChangeVideo extends RoomEvent {
  final String videoId;
  final String videoUrl;
  final String? thumbnailUrl;

  ChangeVideo({
    required this.videoId,
    required this.videoUrl,
    this.thumbnailUrl,
  });
}

class ToggleMic extends RoomEvent {
  const ToggleMic();
}

class ToggleChat extends RoomEvent {
  const ToggleChat();
}

class ToggleParticipantsDrawer extends RoomEvent {
  const ToggleParticipantsDrawer();
}

class LeaveRoom extends RoomEvent {
  const LeaveRoom();
}

class DeleteRoom extends RoomEvent {
  final String roomId;

  const DeleteRoom(this.roomId);
}

class _NewMessageReceived extends RoomEvent {
  final RoomMessageEntity message;

  _NewMessageReceived(this.message);
}

class _ParticipantJoined extends RoomEvent {
  final RoomParticipantEntity participant;

  _ParticipantJoined(this.participant);
}

class _ParticipantLeft extends RoomEvent {
  final String userId;

  _ParticipantLeft(this.userId);
}

class _VideoSyncReceived extends RoomEvent {
  final VideoSyncEventEntity event;

  _VideoSyncReceived(this.event);
}

class _VideoChangeReceived extends RoomEvent {
  final VideoChangeEventEntity event;

  _VideoChangeReceived(this.event);
}
