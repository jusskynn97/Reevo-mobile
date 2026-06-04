
import 'dart:async';
import 'package:reevo/features/newfeed/domain/entity/video_entity.dart';
import 'package:reevo/features/watch_together/domain/entity/watch_room_entity.dart';

class WatchRoomService {
  WatchRoomEntity? _currentRoom;
  bool _isHost = false;
  
  final StreamController<WatchRoomEntity?> _roomController = StreamController<WatchRoomEntity?>.broadcast();
  final StreamController<bool> _isHostController = StreamController<bool>.broadcast();
  
  Stream<WatchRoomEntity?> get currentRoomStream => _roomController.stream;
  Stream<bool> get isHostStream => _isHostController.stream;
  
  WatchRoomEntity? get currentRoom => _currentRoom;
  bool get isHost => _isHost;
  
  void joinRoom(WatchRoomEntity room, bool isHost) {
    _currentRoom = room;
    _isHost = isHost;
    _roomController.add(room);
    _isHostController.add(isHost);
  }
  
  void leaveRoom() {
    _currentRoom = null;
    _isHost = false;
    _roomController.add(null);
    _isHostController.add(false);
  }
  
  void dispose() {
    _roomController.close();
    _isHostController.close();
  }
}
