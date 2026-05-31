import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:reevo/core/error/failure.dart';
import 'package:reevo/features/upload/domain/entity/video_upload_entity.dart';
import 'package:reevo/features/upload/domain/repository/upload_repository.dart';

class UploadVideoUseCase {
  final UploadRepository repository;

  UploadVideoUseCase(this.repository);

  Future<Either<Failure, VideoUploadEntity>> call(UploadVideoParams params) async {
    return await repository.uploadVideo(
      filePath: params.filePath,
      description: params.description,
      videoPrivacy: params.videoPrivacy,
      scheduleAt: params.scheduleAt,
      allowComment: params.allowComment,
    );
  }
}

class UploadVideoParams extends Equatable {
  final String filePath;
  final String description;
  final String videoPrivacy;
  final DateTime? scheduleAt;
  final bool allowComment;

  const UploadVideoParams({
    required this.filePath,
    required this.description,
    required this.videoPrivacy,
    this.scheduleAt,
    required this.allowComment,
  });

  UploadVideoParams copyWith({
    String? filePath,
    String? description,
    String? videoPrivacy,
    DateTime? scheduleAt,
    bool? allowComment,
  }) {
    return UploadVideoParams(
      filePath: filePath ?? this.filePath,
      description: description ?? this.description,
      videoPrivacy: videoPrivacy ?? this.videoPrivacy,
      scheduleAt: scheduleAt ?? this.scheduleAt,
      allowComment: allowComment ?? this.allowComment,
    );
  }

  @override
  List<Object?> get props => [filePath, description, videoPrivacy, scheduleAt, allowComment];
}
