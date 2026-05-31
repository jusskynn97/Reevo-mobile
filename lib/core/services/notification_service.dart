import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:reevo/core/di/service_locator.dart';
import 'package:reevo/core/router/app_router.dart';
import 'package:reevo/core/services/token_storage_service.dart';
import 'package:reevo/core/theme/color.dart';
import 'package:reevo/features/notification/domain/repository/notification_repository.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final TokenStorageService _tokenStorageService = getIt<TokenStorageService>();

  Future<void> initialize() async {
    // Request permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM Token and register with backend
    _fcm.getToken().then((token) {
      if (token != null) {
        debugPrint('FCM Token: $token');
        _registerDevice(token);
      }
    });

    // Listen for token refreshes
    _fcm.onTokenRefresh.listen(_registerDevice);

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    
    // Handle notification clicks when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      debugPrint('Notification tapped with payload: ${response.payload}');
      _handleDeepLink(response.payload!);
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.notification?.title}');
    // Show in-app notification
    showInAppNotification(
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      type: NotificationType.success,
      onTap: () {
        if (message.data.containsKey('videoId')) {
          _handleDeepLink('video/${message.data['videoId']}');
        }
      },
    );
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.data}');
    if (message.data.containsKey('videoId')) {
      _handleDeepLink('video/${message.data['videoId']}');
    }
  }

  void _handleDeepLink(String path) {
    // Navigate using appRouter
    appRouter.push('/$path');
  }

  Future<void> _registerDevice(String token) async {
    final repository = getIt<NotificationRepository>();
    final deviceType = Platform.isAndroid ? 'ANDROID' : (Platform.isIOS ? 'IOS' : 'WEB');
    
    // Save token locally
    await _tokenStorageService.saveFcmToken(token);
    
    final result = await repository.registerDevice(token, deviceType);
    result.fold(
      (failure) => debugPrint('Failed to register device: ${failure.message}'),
      (_) => debugPrint('Successfully registered device with FCM token'),
    );
  }

  Future<void> unregisterDevice() async {
    final repository = getIt<NotificationRepository>();
    final fcmToken = _tokenStorageService.getFcmToken();
    
    if (fcmToken != null) {
      final result = await repository.unregisterDevice(fcmToken);
      result.fold(
        (failure) => debugPrint('Failed to unregister device: ${failure.message}'),
        (_) => debugPrint('Successfully unregistered device with FCM token'),
      );
    }
  }

  void showInAppNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.info,
    VoidCallback? onTap,
  }) {
    showOverlayNotification((context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                OverlaySupportEntry.of(context)?.dismiss();
                onTap?.call();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: _getTypeColor(type).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getTypeColor(type).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getTypeIcon(type),
                        color: _getTypeColor(type),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            body,
                            style: TextStyle(
                              color: AppColors.grey3,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.grey3, size: 18),
                      onPressed: () => OverlaySupportEntry.of(context)?.dismiss(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }, duration: const Duration(seconds: 4));
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return AppColors.brand;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.info:
      default:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle_rounded;
      case NotificationType.error:
        return Icons.error_rounded;
      case NotificationType.info:
      default:
        return Icons.info_rounded;
    }
  }
}

enum NotificationType { success, error, info }

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}
