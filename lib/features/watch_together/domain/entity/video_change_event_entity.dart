
import 'package:equatable/equatable.dart';

abstract class VideoChangeEventEntity extends Equatable {
  String get videoId;
  String get videoUrl;
  String? get thumbnailUrl;
  int get timestamp;
  String get userId;
  String get username;

  const VideoChangeEventEntity();
}
