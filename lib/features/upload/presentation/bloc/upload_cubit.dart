import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:reevo/core/di/service_locator.dart';
import 'package:reevo/core/services/notification_service.dart';
import 'package:reevo/features/upload/domain/entity/video_upload_entity.dart';
import 'package:reevo/features/upload/domain/usecase/upload_video_usecase.dart';

/// State for the upload flow
class UploadState {
  final int currentStep;
  final AssetEntity? selectedVideoAsset;
  final int selectedVideoIndex;
  final double trimStart;
  final double trimEnd;
  final double videoDuration;
  final String description;
  final String? coverImagePath;
  final String visibility;
  final bool allowComments;
  final bool hostWatchTogether;
  final bool isScheduled;
  final DateTime? scheduledDateTime;
  final bool isUploading;
  final String? uploadError;
  final VideoUploadEntity? uploadResult;

  const UploadState({
    this.currentStep = 0,
    this.selectedVideoAsset,
    this.selectedVideoIndex = -1,
    this.trimStart = 0.0,
    this.trimEnd = 1.0,
    this.videoDuration = 0.0,
    this.description = '',
    this.coverImagePath,
    this.visibility = 'everyone',
    this.allowComments = true,
    this.hostWatchTogether = false,
    this.isScheduled = false,
    this.scheduledDateTime,
    this.isUploading = false,
    this.uploadError,
    this.uploadResult,
  });

  UploadState copyWith({
    int? currentStep,
    AssetEntity? selectedVideoAsset,
    int? selectedVideoIndex,
    double? trimStart,
    double? trimEnd,
    double? videoDuration,
    String? description,
    String? coverImagePath,
    String? visibility,
    bool? allowComments,
    bool? hostWatchTogether,
    bool? isScheduled,
    DateTime? scheduledDateTime,
    bool? isUploading,
    bool clearScheduledDateTime = false,
    String? uploadError,
    bool clearUploadError = false,
    VideoUploadEntity? uploadResult,
    bool clearUploadResult = false,
  }) {
    return UploadState(
      currentStep: currentStep ?? this.currentStep,
      selectedVideoAsset: selectedVideoAsset ?? this.selectedVideoAsset,
      selectedVideoIndex: selectedVideoIndex ?? this.selectedVideoIndex,
      trimStart: trimStart ?? this.trimStart,
      trimEnd: trimEnd ?? this.trimEnd,
      videoDuration: videoDuration ?? this.videoDuration,
      description: description ?? this.description,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      visibility: visibility ?? this.visibility,
      allowComments: allowComments ?? this.allowComments,
      hostWatchTogether: hostWatchTogether ?? this.hostWatchTogether,
      isScheduled: isScheduled ?? this.isScheduled,
      scheduledDateTime: clearScheduledDateTime
          ? null
          : (scheduledDateTime ?? this.scheduledDateTime),
      isUploading: isUploading ?? this.isUploading,
      uploadError: clearUploadError ? null : (uploadError ?? this.uploadError),
      uploadResult: clearUploadResult ? null : (uploadResult ?? this.uploadResult),
    );
  }
}

/// Cubit managing the upload flow state
class UploadCubit extends Cubit<UploadState> {
  final UploadVideoUseCase _uploadVideoUseCase;

  UploadCubit({required UploadVideoUseCase uploadVideoUseCase})
      : _uploadVideoUseCase = uploadVideoUseCase,
        super(const UploadState());

  void nextStep() {
    if (state.currentStep < 1) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  /// Chọn video thật từ gallery
  void selectVideo(AssetEntity asset) async {
    final duration = asset.duration.toDouble(); // Duration in seconds

    emit(state.copyWith(
      selectedVideoAsset: asset,
      selectedVideoIndex: -1, // Không dùng index mock nữa
      videoDuration: duration,
      trimStart: 0.0,
      trimEnd: 1.0,
    ));
  }

  void updateTrimStart(double start) {
    emit(state.copyWith(trimStart: start));
  }

  void updateTrimEnd(double end) {
    emit(state.copyWith(trimEnd: end));
  }

  void updateTrim(double start, double end) {
    emit(state.copyWith(trimStart: start, trimEnd: end));
  }

  void updateDescription(String description) {
    emit(state.copyWith(description: description));
  }

  void updateVisibility(String visibility) {
    emit(state.copyWith(visibility: visibility));
  }

  void toggleComments() {
    emit(state.copyWith(allowComments: !state.allowComments));
  }

  void toggleWatchTogether() {
    emit(state.copyWith(hostWatchTogether: !state.hostWatchTogether));
  }

  void toggleSchedule() {
    final newScheduled = !state.isScheduled;
    if (newScheduled) {
      final defaultTime = DateTime.now().add(const Duration(hours: 1));
      emit(state.copyWith(
        isScheduled: true,
        scheduledDateTime: defaultTime,
      ));
    } else {
      emit(state.copyWith(
        isScheduled: false,
        clearScheduledDateTime: true,
      ));
    }
  }

  void updateScheduledDateTime(DateTime dateTime) {
    emit(state.copyWith(scheduledDateTime: dateTime));
  }

  /// Map UI visibility string to backend VideoPrivacy enum name
  String _mapVisibilityToPrivacy(String visibility) {
    switch (visibility) {
      case 'friends':
        return 'FRIENDS';
      case 'only_me':
        return 'PRIVATE';
      case 'everyone':
      default:
        return 'PUBLIC';
    }
  }

  /// Reset state for a new upload
  void reset() {
    emit(const UploadState());
  }

  /// Submit the video upload to the backend API
  Future<void> submitUpload() async {
    if (state.selectedVideoAsset == null || state.isUploading) return;

    final uploadParams = UploadVideoParams(
      filePath: '', // Will be updated below
      description: state.description,
      videoPrivacy: _mapVisibilityToPrivacy(state.visibility),
      scheduleAt: state.isScheduled ? state.scheduledDateTime : null,
      allowComment: state.allowComments,
    );

    emit(state.copyWith(
      isUploading: true,
      clearUploadError: true,
      clearUploadResult: true,
    ));

    // Get the actual file path from the selected asset
    final file = await state.selectedVideoAsset!.file;
    if (file == null) {
      emit(state.copyWith(
        isUploading: false,
        uploadError: 'Could not access the selected video file.',
      ));
      return;
    }

    final params = uploadParams.copyWith(filePath: file.path);

    debugPrint('=== UPLOAD SUBMITTED (BACKGROUND) ===');
    debugPrint('Video file: ${file.path}');
    debugPrint('Description: ${state.description}');
    debugPrint('Privacy: ${params.videoPrivacy}');
    debugPrint('Schedule: ${params.scheduleAt}');
    debugPrint('Allow comments: ${params.allowComment}');
    debugPrint('========================');

    await _performUpload(params);
  }

  Future<void> retryUpload() async {
    if (state.selectedVideoAsset == null || state.isUploading) return;

    final file = await state.selectedVideoAsset!.file;
    if (file == null) return;

    final params = UploadVideoParams(
      filePath: file.path,
      description: state.description,
      videoPrivacy: _mapVisibilityToPrivacy(state.visibility),
      scheduleAt: state.isScheduled ? state.scheduledDateTime : null,
      allowComment: state.allowComments,
    );

    emit(state.copyWith(
      isUploading: true,
      clearUploadError: true,
    ));

    await _performUpload(params);
  }

  Future<void> _performUpload(UploadVideoParams params) async {
    int retryCount = 0;
    const int maxRetries = 3;
    bool success = false;

    while (retryCount < maxRetries && !success) {
      final result = await _uploadVideoUseCase.call(params);

      await result.fold(
        (failure) async {
          retryCount++;
          debugPrint('Upload attempt $retryCount failed: ${failure.message}');
          if (retryCount >= maxRetries) {
            emit(state.copyWith(
              isUploading: false,
              uploadError: failure.message ?? 'Upload failed after $maxRetries attempts.',
            ));
            
            // Show error in-app notification
            getIt<NotificationService>().showInAppNotification(
              title: 'Upload Failed',
              body: failure.message ?? 'Please check your connection and try again.',
              type: NotificationType.error,
              onTap: () {
                // Potential retry logic here
              },
            );
          } else {
            // Wait before retrying (exponential backoff)
            await Future.delayed(Duration(seconds: retryCount * 2));
          }
        },
        (uploadEntity) async {
          debugPrint('Upload success: ${uploadEntity.uploadId} - ${uploadEntity.status}');
          emit(state.copyWith(
            isUploading: false,
            uploadResult: uploadEntity,
          ));
          success = true;

          // Show success in-app notification
          getIt<NotificationService>().showInAppNotification(
            title: 'Upload Successful',
            body: 'Your video has been published successfully!',
            type: NotificationType.success,
          );
        },
      );
    }
  }
}