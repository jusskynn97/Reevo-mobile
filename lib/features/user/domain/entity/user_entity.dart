import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final int followerCount;
  final int followingCount;
  final int friendCount;
  final bool isFollowing;
  final bool isFriend;

  const User({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.followerCount = 0,
    this.followingCount = 0,
    this.friendCount = 0,
    this.isFollowing = false,
    this.isFriend = false,
  });

  User copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? bio,
    int? followerCount,
    int? followingCount,
    int? friendCount,
    bool? isFollowing,
    bool? isFriend,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      friendCount: friendCount ?? this.friendCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isFriend: isFriend ?? this.isFriend,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        displayName,
        avatarUrl,
        bio,
        followerCount,
        followingCount,
        friendCount,
        isFollowing,
        isFriend,
      ];
}
