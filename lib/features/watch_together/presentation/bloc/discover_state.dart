
part of 'discover_bloc.dart';

abstract class DiscoverState {}

class DiscoverInitial extends DiscoverState {}

class DiscoverLoading extends DiscoverState {}

class DiscoverLoaded extends DiscoverState {
  final List<WatchRoomEntity> rooms;

  DiscoverLoaded(this.rooms);
}

class DiscoverError extends DiscoverState {
  final String message;

  DiscoverError(this.message);
}
