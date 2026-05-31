import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reevo/core/di/service_locator.dart';
import 'package:reevo/core/theme/color.dart';
import 'package:reevo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:reevo/features/newfeed/domain/entity/video_entity.dart';
import 'package:reevo/features/newfeed/domain/repository/video_repository.dart';
import 'package:reevo/features/user/presentation/bloc/user_bloc.dart';

class ProfilePage extends StatefulWidget {
  final String? userId;

  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool get _isOwnProfile => widget.userId == null;
  Timer? _refreshTimer;
  List<VideoEntity> _videos = [];
  bool _isLoadingVideos = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadUserVideos();
    // Refresh profile every 10 seconds for real-time updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _loadUserProfile();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _loadUserProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (_isOwnProfile) {
        context.read<UserBloc>().add(
              GetUserProfileEvent(
                userId: authState.userId,
                accessToken: authState.accessToken,
              ),
            );
      } else {
        context.read<UserBloc>().add(
              GetOtherUserProfileEvent(
                userId: widget.userId!,
                accessToken: authState.accessToken,
              ),
            );
      }
    }
  }

  Future<void> _loadUserVideos() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userId = _isOwnProfile ? authState.userId : widget.userId!;
      setState(() {
        _isLoadingVideos = true;
        _errorMessage = null;
      });
      try {
        final result = await getIt<VideoRepository>().getUserVideos(userId: userId);
        result.fold(
          (failure) {
            setState(() {
              _isLoadingVideos = false;
              _errorMessage = failure.toString();
            });
            print("Error loading videos: $failure");
          },
          (videos) {
            setState(() {
              _videos = videos;
              _isLoadingVideos = false;
            });
            print("Loaded ${videos.length} videos");
          },
        );
      } catch (e) {
        setState(() {
          _isLoadingVideos = false;
          _errorMessage = e.toString();
        });
        print("Exception loading videos: $e");
      }
    }
  }

  void _toggleFollow() {
    final authState = context.read<AuthBloc>().state;
    final userState = context.read<UserBloc>().state;
    if (authState is AuthAuthenticated && userState is UserProfileLoaded) {
      if (userState.user.isFollowing) {
        context.read<UserBloc>().add(
              UnfollowUserEvent(
                userId: userState.user.id,
                accessToken: authState.accessToken,
              ),
            );
      } else {
        context.read<UserBloc>().add(
              FollowUserEvent(
                userId: userState.user.id,
                accessToken: authState.accessToken,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: !_isOwnProfile
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    // If no previous route, go to home
                    context.go('/');
                  }
                },
              )
            : null,
        title: _isOwnProfile
            ? Row(
                children: [
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      if (state is UserProfileLoaded) {
                        return Text(
                          '@${state.user.username}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }
                      return const Text('@', style: TextStyle(color: Colors.white));
                    },
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                ],
              )
            : null,
        actions: _isOwnProfile
            ? [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: AppColors.surface,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.logout, color: Colors.white),
                              title: const Text(
                                'Đăng xuất',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                context.pop(); // Close the modal
                                context.read<AuthBloc>().add(const AuthLogoutEvent());
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.menu, color: Colors.white),
                ),
              ]
            : null,
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is UserProfileLoaded) {
            final user = state.user;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildProfileHeader(user),
                ),
                SliverToBoxAdapter(
                  child: _buildStatsRow(user),
                ),
                SliverToBoxAdapter(
                  child: _buildActionButtons(user),
                ),
                if (_errorMessage != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(_errorMessage!, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadUserVideos,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_isLoadingVideos)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                if (!_isLoadingVideos && _errorMessage == null) _buildContentGrid(),
              ],
            );
          } else if (state is UserError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUserProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('No data'),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Avatar with add button
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.brand,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ClipOval(
                    child: user.avatarUrl != null
                        ? Image.network(
                            user.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[600],
                              );
                            },
                          )
                        : Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey[600],
                          ),
                  ),
                ),
              ),
              if (_isOwnProfile)
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.brand,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.black,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // Display name
          Text(
            user.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Bio
          if (user.bio != null && user.bio!.isNotEmpty)
            Text(
              user.bio!,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            _formatNumber(user.followerCount ~/ 2),
            'Likes',
          ),
          Container(
            width: 1,
            height: 30,
            color: AppColors.grey4,
          ),
          _buildStatItem(
            _formatNumber(user.followerCount),
            'Followers',
          ),
          Container(
            width: 1,
            height: 30,
            color: AppColors.grey4,
          ),
          _buildStatItem(
            _formatNumber(user.followingCount),
            'Following',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isOwnProfile ? () {} : _toggleFollow,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.grey4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isOwnProfile ? 'Edit Profile' : (user.isFollowing ? 'Unfollow' : 'Follow'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.grey4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Share Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      sliver: _videos.isEmpty
          ? const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Text(
                    'No videos yet',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
          : SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final video = _videos[index];
                  return _buildGridItem(video);
                },
                childCount: _videos.length,
              ),
            ),
    );
  }

  Widget _buildGridItem(VideoEntity video) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage(video.thumbnailUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 8,
            left: 8,
            child: Row(
              children: [
                const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  _formatNumber(video.likeCount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}
