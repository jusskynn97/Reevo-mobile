import 'package:dartz/dartz.dart';
import 'package:reevo/core/error/failure.dart';
import 'package:reevo/features/upload/data/datasource/upload_remote_datasource.dart';
import 'package:reevo/features/upload/domain/entity/video_upload_entity.dart';
import 'package:reevo/features/upload/domain/repository/upload_repository.dart';

class UploadRepositoryImpl implements UploadRepository {
  final UploadRemoteDataSource remoteDataSource;

  UploadRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, VideoUploadEntity>> uploadVideo({
    required String filePath,
    required String description,
    required String videoPrivacy,
    required DateTime? scheduleAt,
    required bool allowComment,
  }) async {
    try {
      final result = await remoteDataSource.uploadVideo(
        filePath: filePath,
        description: description,
        videoPrivacy: videoPrivacy,
        scheduleAt: scheduleAt,
        allowComment: allowComment,
      );

      if (result.success) {
        return Right(result.data.toEntity());
      } else {
        return Left(ServerFailure(message: result.message));
      }
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
