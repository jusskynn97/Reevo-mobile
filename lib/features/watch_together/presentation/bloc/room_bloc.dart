
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entity/watch_room_entity.dart';
import '../../domain/entity/room_participant_entity.dart';
import '../../domain/entity/room_message_entity.dart';
import '../../domain/entity/video_sync_event_entity.dart';
import '../../domain/entity/video_change_event_entity.dart';
import '../../domain/repository/watch_together_repository.dart';
import '../../data/model/video_sync_event_model.dart';
import '../../data/model/video_change_event_model.dart';
import '../../data/model/room_message_model.dart';
import '../../data/model/room_participant_model.dart';
import '../../../../core/services/websocket_service.dart';

part 'room_event.dart';
part 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final WatchTogetherRepository repository;
  final WebSocketService webSocketService;
  List<RoomMessageEntity> messages = [];
  List<RoomParticipantEntity> participants = [];
  String? currentRoomId;

  RoomBloc({
    required this.repository,
    required this.webSocketService,
  }) : super(RoomInitial()) {
    on<InitializeRoom>(_onInitializeRoom);
    on<SendMessage>(_onSendMessage);
    on<SendVideoSync>(_onSendVideoSync);
    on<ChangeVideo>(_onChangeVideo);
    on<ToggleMic>(_onToggleMic);
    on<ToggleChat>(_onToggleChat);
    on<ToggleParticipantsDrawer>(_onToggleParticipantsDrawer);
    on<LeaveRoom>(_onLeaveRoom);
    on<DeleteRoom>(_onDeleteRoom);
    on<_NewMessageReceived>(_onNewMessageReceived);
    on<_ParticipantJoined>(_onParticipantJoined);
    on<_ParticipantLeft>(_onParticipantLeft);
    on<_VideoSyncReceived>(_onVideoSyncReceived);
    on<_VideoChangeReceived>(_onVideoChangeReceived);
  }

  Future<void> _onInitializeRoom(
      InitializeRoom event, Emitter<RoomState> emit) async {
    currentRoomId = event.roomId;
    emit(RoomLoading());
    try {
      final room = await repository.getRoom(event.roomId);
      participants = await repository.getRoomParticipants(event.roomId);
      messages = await repository.getRoomMessages(event.roomId);
      await repository.joinRoom(event.roomId);
      _subscribeToWebSocket(event.roomId);
      
      // If room has a videoId set, create an initial VideoChangeEvent
      VideoChangeEventEntity? initialVideoChange;
      if (room.videoId != null && room.videoUrl != null) {
        initialVideoChange = VideoChangeEventModel(
          videoId: room.videoId!,
          videoUrl: room.videoUrl!,
          thumbnailUrl: room.thumbnailUrl,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          userId: '',
          username: '',
        );
      }
      
      emit(RoomLoaded(
        room: room,
        participants: participants,
        messages: messages,
        videoChangeEvent: initialVideoChange,
      ));
    } catch (e) {
      emit(RoomError(e.toString()));
    }
  }

  void _subscribeToWebSocket(String roomId) {
    // Subscribe to new messages
    webSocketService.subscribe<RoomMessageEntity>(
      '/topic/room/$roomId/messages',
      (json) => RoomMessageModel.fromJson(json),
    ).listen((message) {
      add(_NewMessageReceived(message));
    });

    // Subscribe to new participants
    webSocketService.subscribe<RoomParticipantEntity>(
      '/topic/room/$roomId/participants',
      (json) => RoomParticipantModel.fromJson(json),
    ).listen((participant) {
      add(_ParticipantJoined(participant));
    });

    // Subscribe to participants leaving
    webSocketService.subscribeRaw(
      '/topic/room/$roomId/participants/leave',
    ).listen((userId) {
      add(_ParticipantLeft(userId as String));
    });

    // Subscribe to video sync events
    webSocketService.subscribe<VideoSyncEventEntity>(
      '/topic/room/$roomId/video-sync',
      (json) => VideoSyncEventModel.fromJson(json),
    ).listen((event) {
      add(_VideoSyncReceived(event));
    });

    // Subscribe to video change events
    webSocketService.subscribe<VideoChangeEventEntity>(
      '/topic/room/$roomId/video-change',
      (json) => VideoChangeEventModel.fromJson(json),
    ).listen((event) {
      add(_VideoChangeReceived(event));
    });
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<RoomState> emit) async {
    try {
      await repository.sendMessage(
        roomId: currentRoomId!,
        content: event.content,
      );
    } catch (e) {
      // Handle error
    }
  }

  void _onSendVideoSync(SendVideoSync event, Emitter<RoomState> emit) {
    final wsEvent = VideoSyncEventModel(
      type: event.type,
      position: event.position,
      playing: event.playing,
    );
    webSocketService.send(
        '/app/room/$currentRoomId/video-sync', wsEvent.toJson());
  }

  Future<void> _onChangeVideo(ChangeVideo event, Emitter<RoomState> emit) async {
    // Only host can change video, send event to server
    final videoChangeEvent = VideoChangeEventModel(
      videoId: event.videoId,
      videoUrl: event.videoUrl,
      thumbnailUrl: event.thumbnailUrl,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      userId: '',
      username: '',
    );
    
    // Cập nhật state ngay lập tức cho chủ phòng
    if (state is RoomLoaded) {
      final currentState = state as RoomLoaded;
      emit(currentState.copyWith(
        room: currentState.room.copyWith(
          videoId: event.videoId,
          videoUrl: event.videoUrl,
          thumbnailUrl: event.thumbnailUrl,
        ),
        videoChangeEvent: videoChangeEvent,
      ));
    }
    
    webSocketService.send(
      '/app/room/$currentRoomId/video-change',
      videoChangeEvent.toJson(),
    );
  }

  void _onToggleMic(ToggleMic event, Emitter<RoomState> emit) {
    if (state is RoomLoaded) {
      final currentState = state as RoomLoaded;
      emit(currentState.copyWith(isMicMuted: !currentState.isMicMuted));
    }
  }

  void _onToggleChat(ToggleChat event, Emitter<RoomState> emit) {
    if (state is RoomLoaded) {
      final currentState = state as RoomLoaded;
      emit(currentState.copyWith(isChatOpen: !currentState.isChatOpen));
    }
  }

  void _onToggleParticipantsDrawer(
      ToggleParticipantsDrawer event, Emitter<RoomState> emit) {
    if (state is RoomLoaded) {
      final currentState = state as RoomLoaded;
      emit(currentState.copyWith(
          isParticipantsDrawerOpen: !currentState.isParticipantsDrawerOpen));
    }
  }

  void _onNewMessageReceived(
      _NewMessageReceived event, Emitter<RoomState> emit) {
    if (state is RoomLoaded) {
      messages.add(event.message);
      emit((state as RoomLoaded).copyWith(messages: List.from(messages)));
    }
  }

  void _onParticipantJoined(
      _ParticipantJoined event, Emitter<RoomState> emit) {
    if (state is RoomLoaded) {
      participants.add(event.participant);
      emit((state as RoomLoaded)
          .copyWith(participants: List.from(participants)));
    }
  }

  void _onParticipantLeft(_ParticipantLeft event, Emitter<RoomState> emit) {
    if (state is RoomLoaded) {
      participants.removeWhere((p) => p.userId == event.userId);
      emit((state as RoomLoaded)
          .copyWith(participants: List.from(participants)));
    }
  }

  void _onVideoSyncReceived(
      _VideoSyncReceived event, Emitter<RoomState> emit) {
    if (state is RoomLoaded) {
      emit((state as RoomLoaded).copyWith(videoSyncEvent: event.event));
    }
  }

  void _onVideoChangeReceived(
      _VideoChangeReceived event, Emitter<RoomState> emit) {
    if (state is RoomLoaded) {
      final currentState = state as RoomLoaded;
      emit(currentState.copyWith(
        room: currentState.room.copyWith(
          videoId: event.event.videoId,
          videoUrl: event.event.videoUrl,
          thumbnailUrl: event.event.thumbnailUrl,
        ),
        videoChangeEvent: event.event,
      ));
    }
  }

  Future<void> _onLeaveRoom(LeaveRoom event, Emitter<RoomState> emit) async {
    if (currentRoomId != null) {
      try {
        await repository.leaveRoom(currentRoomId!);
      } catch (e) {
        // Handle error
      }
    }
  }

  Future<void> _onDeleteRoom(DeleteRoom event, Emitter<RoomState> emit) async {
    try {
      await repository.deleteRoom(event.roomId);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> leaveRoom() async {
    if (currentRoomId != null) {
      try {
        await repository.leaveRoom(currentRoomId!);
      } catch (e) {
        // Handle error
      }
    }
  }

  @override
  Future<void> close() {
    leaveRoom();
    return super.close();
  }
}
