
import 'package:flutter/material.dart';
import 'package:reevo/core/theme/color.dart';
import 'package:reevo/core/di/service_locator.dart';
import 'package:reevo/core/services/watch_room_service.dart';
import 'package:reevo/features/watch_together/presentation/bloc/discover_bloc.dart';
import 'package:reevo/features/watch_together/presentation/pages/room_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxUsersController = TextEditingController();
  String _selectedPrivacy = 'PUBLIC';

  final WatchRoomService _watchRoomService = getIt<WatchRoomService>();
  late final DiscoverBloc _discoverBloc;

  @override
  void initState() {
    super.initState();
    _discoverBloc = getIt<DiscoverBloc>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxUsersController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _discoverBloc.add(
        CreateRoom(
          name: _nameController.text,
          description: _descriptionController.text,
          privacy: _selectedPrivacy,
          maxUsers: _maxUsersController.text.isNotEmpty
              ? int.parse(_maxUsersController.text)
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _discoverBloc,
      child: BlocConsumer<DiscoverBloc, DiscoverState>(
        listenWhen: (prev, curr) {
          if (prev is DiscoverLoading && curr is DiscoverLoaded) {
            return true;
          }
          return false;
        },
        listener: (context, state) {
          if (state is DiscoverError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is DiscoverLoaded) {
            // Navigate to RoomPage with the new room
            final roomId = _watchRoomService.currentRoom?.id;
            if (roomId != null && mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => RoomPage(roomId: roomId),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              title: const Text('Create Room', style: TextStyle(color: Colors.white)),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Room name
                    const Text(
                      'Room Name',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter room name',
                        hintStyle: TextStyle(color: AppColors.grey3),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.grey2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.brand),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a room name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Enter room description (optional)',
                        hintStyle: TextStyle(color: AppColors.grey3),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.grey2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.brand),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Privacy
                    const Text(
                      'Privacy',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedPrivacy,
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: AppColors.surface,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.grey2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.brand),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'PUBLIC', child: Text('Public')),
                        DropdownMenuItem(value: 'PRIVATE', child: Text('Private')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedPrivacy = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Max users
                    const Text(
                      'Max Users (optional)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _maxUsersController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter max number of users',
                        hintStyle: TextStyle(color: AppColors.grey3),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.grey2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.brand),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Create button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state is DiscoverLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brand,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: state is DiscoverLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text(
                                'Create Room',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
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
}

