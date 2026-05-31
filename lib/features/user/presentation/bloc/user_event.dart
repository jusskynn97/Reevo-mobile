part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class GetUserProfileEvent extends UserEvent {
  final String userId;
  final String accessToken;

  const GetUserProfileEvent({
    required this.userId,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [userId, accessToken];
}

class GetOtherUserProfileEvent extends UserEvent {
  final String userId;
  final String accessToken;

  const GetOtherUserProfileEvent({
    required this.userId,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [userId, accessToken];
}

class FollowUserEvent extends UserEvent {
  final String userId;
  final String accessToken;

  const FollowUserEvent({
    required this.userId,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [userId, accessToken];
}

class UnfollowUserEvent extends UserEvent {
  final String userId;
  final String accessToken;

  const UnfollowUserEvent({
    required this.userId,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [userId, accessToken];
}
