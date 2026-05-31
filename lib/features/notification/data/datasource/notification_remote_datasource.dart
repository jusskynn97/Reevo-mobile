import 'package:dio/dio.dart';
import 'package:reevo/features/notification/data/model/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> registerDevice(String fcmToken, String deviceType);
  Future<void> unregisterDevice(String fcmToken);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  NotificationRemoteDataSourceImpl({required this.dio, required this.baseUrl});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await dio.get('$baseUrl/api/v1/notifications');
    if (response.data['success'] == true) {
      final List list = response.data['data'];
      return list.map((e) => NotificationModel.fromJson(e)).toList();
    }
    throw Exception(response.data['message'] ?? 'Failed to fetch notifications');
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final response = await dio.post('$baseUrl/api/v1/notifications/$notificationId/read');
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to mark as read');
    }
  }

  @override
  Future<void> registerDevice(String fcmToken, String deviceType) async {
    final response = await dio.post(
      '$baseUrl/api/v1/notifications/register-device',
      queryParameters: {
        'fcmToken': fcmToken,
        'deviceType': deviceType,
      },
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to register device');
    }
  }

  @override
  Future<void> unregisterDevice(String fcmToken) async {
    final response = await dio.post(
      '$baseUrl/api/v1/notifications/unregister-device',
      queryParameters: {
        'fcmToken': fcmToken,
      },
    );
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to unregister device');
    }
  }
}
