
part of 'discover_bloc.dart';

abstract class DiscoverEvent {
  const DiscoverEvent();
}

class LoadPublicRooms extends DiscoverEvent {
  const LoadPublicRooms();
}

class CreateRoom extends DiscoverEvent {
  final String name;
  final String? description;
  final String? videoId;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? privacy;
  final int? maxUsers;

  CreateRoom({
    required this.name,
    this.description,
    this.videoId,
    this.videoUrl,
    this.thumbnailUrl,
    this.privacy,
    this.maxUsers,
  });
}

