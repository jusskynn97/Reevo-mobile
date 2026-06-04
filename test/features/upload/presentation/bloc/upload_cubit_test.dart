import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:reevo/features/upload/domain/entity/video_upload_entity.dart';
import 'package:reevo/features/upload/domain/usecase/upload_video_usecase.dart';
import 'package:reevo/features/upload/presentation/bloc/upload_cubit.dart';
import 'package:reevo/core/error/failure.dart';

import 'upload_cubit_test.mocks.dart';

@GenerateMocks([UploadVideoUseCase])
void main() {
  late UploadCubit cubit;
  late MockUploadVideoUseCase mockUploadVideoUseCase;

  setUp(() {
    mockUploadVideoUseCase = MockUploadVideoUseCase();
    cubit = UploadCubit(uploadVideoUseCase: mockUploadVideoUseCase);
  });

  group('UploadCubit Unit Tests', () {
    test('initial state should be correct', () {
      expect(cubit.state.currentStep, 0);
      expect(cubit.state.isUploading, false);
    });

    test('nextStep should increment currentStep', () {
      cubit.nextStep();
      expect(cubit.state.currentStep, 1);
    });

    test('reset should return state to initial', () {
      cubit.nextStep();
      cubit.reset();
      expect(cubit.state.currentStep, 0);
    });

    // Note: To test submitUpload, we would need to mock AssetEntity and file access
    // which is complex for a unit test. We focus on state logic here.
  });
}
