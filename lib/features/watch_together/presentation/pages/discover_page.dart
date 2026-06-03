
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/color.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/watch_room_service.dart';
import '../bloc/discover_bloc.dart';
import 'room_page.dart';
import 'create_room_page.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final WatchRoomService _watchRoomService = getIt<WatchRoomService>();
  @override
  void initState() {
    super.initState();
    GetIt.I<DiscoverBloc>().add(LoadPublicRooms());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Watch Together', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              GetIt.I<DiscoverBloc>().add(LoadPublicRooms());
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateRoomPage()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<DiscoverBloc, DiscoverState>(
        bloc: GetIt.I<DiscoverBloc>(),
        builder: (context, state) {
          if (state is DiscoverLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DiscoverError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
          } else if (state is DiscoverLoaded) {
            if (state.rooms.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  GetIt.I<DiscoverBloc>().add(LoadPublicRooms());
                },
                child: ListView(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      alignment: Alignment.center,
                      child: const Text('No active rooms. Create one!', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                GetIt.I<DiscoverBloc>().add(LoadPublicRooms());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.rooms.length,
                itemBuilder: (context, index) {
                  final room = state.rooms[index];
                  return Card(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () {
                        _watchRoomService.joinRoom(room, false);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RoomPage(roomId: room.id)),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            if (room.thumbnailUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: room.thumbnailUrl!,
                                  width: 80,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(color: AppColors.grey2),
                                  errorWidget: (context, url, error) => Container(color: AppColors.grey2),
                                ),
                              )
                            else
                              Container(
                                width: 80,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.grey2,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.video_library, color: AppColors.grey3),
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(room.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  if (room.description != null)
                                    Text(room.description!, style: const TextStyle(color: AppColors.grey3, fontSize: 12)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.people, color: AppColors.grey3, size: 16),
                                      const SizedBox(width: 4),
                                      Text('${room.participantCount}/${room.maxUsers}', style: const TextStyle(color: AppColors.grey3)),
                                      const SizedBox(width: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: room.privacy == 'PUBLIC' ? AppColors.brand : AppColors.grey2,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          room.privacy,
                                          style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}

