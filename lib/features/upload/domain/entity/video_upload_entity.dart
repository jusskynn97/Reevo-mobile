import 'package:equatable/equatable.dart';

class VideoUploadEntity extends Equatable {
  final String uploadId;
  final String message;
  final String status;

  const VideoUploadEntity({
    required this.uploadId,
    required this.message,
    required this.status,
  });

  @override
  List<Object?> get props => [uploadId, message, status];
}
