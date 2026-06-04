import 'package:dartz/dartz.dart';
import 'package:reevo/core/error/failure.dart';
import 'package:reevo/features/upload/domain/entity/video_upload_entity.dart';

abstract class UploadRepository {
  Future<Either<Failure, VideoUploadEntity>> uploadVideo({
    required String filePath,
    required String description,
    required String videoPrivacy,
    required DateTime? scheduleAt,
    required bool allowComment,
  });
}
