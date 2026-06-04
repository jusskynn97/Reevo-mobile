import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reevo/features/user/domain/entity/user_entity.dart';
import 'package:reevo/features/user/domain/repository/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc({required this.repository}) : super(const UserInitial()) {
    on<GetUserProfileEvent>(_onGetUserProfile);
    on<GetOtherUserProfileEvent>(_onGetOtherUserProfile);
    on<FollowUserEvent>(_onFollowUser);
    on<UnfollowUserEvent>(_onUnfollowUser);
  }

  Future<void> _onGetUserProfile(
    GetUserProfileEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      final user = await repository.getUserProfile(event.userId, event.accessToken);
      emit(UserProfileLoaded(user: user));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onGetOtherUserProfile(
    GetOtherUserProfileEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      final user = await repository.getOtherUserProfile(event.userId, event.accessToken);
      emit(UserProfileLoaded(user: user));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onFollowUser(
    FollowUserEvent event,
    Emitter<UserState> emit,
  ) async {
    final currentState = state;
    if (currentState is UserProfileLoaded) {
      // Optimistic update
      final updatedUser = currentState.user.copyWith(
        isFollowing: true,
        followerCount: currentState.user.followerCount + 1,
      );
      emit(UserProfileLoaded(user: updatedUser));

      try {
        await repository.followUser(event.userId, event.accessToken);
      } catch (e) {
        // Revert on error
        emit(UserProfileLoaded(user: currentState.user));
        emit(UserError(message: e.toString()));
      }
    }
  }

  Future<void> _onUnfollowUser(
    UnfollowUserEvent event,
    Emitter<UserState> emit,
  ) async {
    final currentState = state;
    if (currentState is UserProfileLoaded) {
      // Optimistic update
      final updatedUser = currentState.user.copyWith(
        isFollowing: false,
        followerCount: currentState.user.followerCount - 1,
      );
      emit(UserProfileLoaded(user: updatedUser));

      try {
        await repository.unfollowUser(event.userId, event.accessToken);
      } catch (e) {
        // Revert on error
        emit(UserProfileLoaded(user: currentState.user));
        emit(UserError(message: e.toString()));
      }
    }
  }
}
