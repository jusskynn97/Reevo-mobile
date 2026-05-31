import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reevo/core/di/service_locator.dart';
import 'package:reevo/core/theme/color.dart';
import 'package:reevo/features/upload/domain/usecase/upload_video_usecase.dart';
import 'package:reevo/features/upload/presentation/bloc/upload_cubit.dart';
import 'package:reevo/features/upload/presentation/widgets/video_select_step.dart';
import 'package:reevo/features/upload/presentation/widgets/post_details_step.dart';

/// Main upload page with 2-step flow:
/// Step 1 - Video selection & editing
/// Step 2 - Post details & schedule
class UploadVideoPage extends StatefulWidget {
  const UploadVideoPage({super.key});

  @override
  State<UploadVideoPage> createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage>
    with SingleTickerProviderStateMixin {
  late final UploadCubit _cubit;
  late final PageController _pageController;
  late final AnimationController _progressAnimController;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<UploadCubit>();
    _pageController = PageController();
    _progressAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // If not currently uploading, reset to step 0
    if (!_cubit.state.isUploading) {
      _cubit.reset();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _progressAnimController.animateTo(
        (_cubit.state.currentStep + 1) / 2,
      );
    });
  }

  void _showUploadSuccessSnackBar() {
    final isScheduled = _cubit.state.isScheduled;
    final uploadResult = _cubit.state.uploadResult;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isScheduled ? Icons.schedule_rounded : Icons.check_circle_rounded,
              color: Colors.black,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isScheduled
                        ? 'Video scheduled successfully!'
                        : 'Video uploaded successfully!',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (uploadResult != null)
                    Text(
                      uploadResult.message,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.brand,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _showUploadErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressAnimController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (_cubit.state.currentStep > 0) {
      _cubit.previousStep();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _handleNext() {
    if (_cubit.state.selectedVideoAsset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a video to proceed.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    _cubit.nextStep();
  }

  void _handleSubmit() {
    _cubit.submitUpload();
    // Navigate back to Feed immediately
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return BlocConsumer<UploadCubit, UploadState>(
      bloc: _cubit,
      listener: (context, state) {
        _pageController.animateToPage(
          state.currentStep,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
        _progressAnimController.animateTo(
          (state.currentStep + 1) / 2,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // Top bar
              _buildTopBar(state, topPadding),

              // Step content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Step 1: Video Selection
                    VideoSelectStep(
                      selectedVideo: state.selectedVideoAsset,
                      trimStart: state.trimStart,
                      trimEnd: state.trimEnd,
                      videoDuration: state.videoDuration,
                      onVideoSelected: (asset) {
                        _cubit.selectVideo(asset);
                      },
                      onTrimStartChanged: _cubit.updateTrimStart,
                      onTrimEndChanged: _cubit.updateTrimEnd,
                    ),

                    // Step 2: Post details
                    PostDetailsStep(
                      description: state.description,
                      visibility: state.visibility,
                      allowComments: state.allowComments,
                      hostWatchTogether: state.hostWatchTogether,
                      isScheduled: state.isScheduled,
                      scheduledDateTime: state.scheduledDateTime,
                      isUploading: state.isUploading,
                      onDescriptionChanged: _cubit.updateDescription,
                      onVisibilityChanged: _cubit.updateVisibility,
                      onToggleComments: _cubit.toggleComments,
                      onToggleWatchTogether: _cubit.toggleWatchTogether,
                      onToggleSchedule: _cubit.toggleSchedule,
                      onScheduleDateTimeChanged: _cubit.updateScheduledDateTime,
                      onSubmit: _handleSubmit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(UploadState state, double topPadding) {
    final isStep1 = state.currentStep == 0;

    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 8,
        left: 4,
        right: 4,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.grey5.withOpacity(0.5), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TextButton(
                onPressed: _handleBack,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Back', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.grey5, width: 1),
                ),
                child: Text(
                  'Step ${state.currentStep + 1} of 2',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),

              if (isStep1)
                TextButton(
                  onPressed: _handleNext,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.brand,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                )
              else
                const SizedBox(width: 72),
            ],
          ),

          const SizedBox(height: 8),

          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListenableBuilder(
              listenable: _progressAnimController,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _progressAnimController.value,
                    backgroundColor: AppColors.grey5,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brand),
                    minHeight: 3,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}