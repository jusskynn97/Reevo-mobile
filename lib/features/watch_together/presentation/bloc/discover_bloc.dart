
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entity/watch_room_entity.dart';
import '../../domain/repository/watch_together_repository.dart';
import '../../../../core/services/watch_room_service.dart';

part 'discover_event.dart';
part 'discover_state.dart';

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final WatchTogetherRepository repository;
  final WatchRoomService watchRoomService;

  DiscoverBloc(this.repository, this.watchRoomService) : super(DiscoverInitial()) {
    on<LoadPublicRooms>(_onLoadPublicRooms);
    on<CreateRoom>(_onCreateRoom);
  }

  Future<void> _onLoadPublicRooms(
      LoadPublicRooms event, Emitter<DiscoverState> emit) async {
    emit(DiscoverLoading());
    try {
      final rooms = await repository.getPublicRooms();
      emit(DiscoverLoaded(rooms));
    } catch (e) {
      emit(DiscoverError(e.toString()));
    }
  }

  Future<void> _onCreateRoom(
      CreateRoom event, Emitter<DiscoverState> emit) async {
    try {
      final room = await repository.createRoom(
        name: event.name,
        description: event.description,
        videoId: event.videoId,
        videoUrl: event.videoUrl,
        thumbnailUrl: event.thumbnailUrl,
        privacy: event.privacy,
        maxUsers: event.maxUsers,
      );
      watchRoomService.joinRoom(room, true);
      add(LoadPublicRooms());
    } catch (e) {
      if (state is DiscoverLoaded) {
        emit(DiscoverError(e.toString()));
        emit(DiscoverLoaded((state as DiscoverLoaded).rooms));
      }
    }
  }
}
