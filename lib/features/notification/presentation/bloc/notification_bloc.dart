import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:reevo/features/notification/domain/entity/notification_entity.dart';
import 'package:reevo/features/notification/domain/repository/notification_repository.dart';

// Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class FetchNotificationsEvent extends NotificationEvent {}

class MarkNotificationAsReadEvent extends NotificationEvent {
  final String notificationId;
  const MarkNotificationAsReadEvent(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}

// States
enum NotificationStatus { initial, loading, success, failure }

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<NotificationEntity> notifications;
  final String? errorMessage;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.errorMessage,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationEntity>? notifications,
    String? errorMessage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notifications, errorMessage];
}

// Bloc
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc({required this.repository}) : super(const NotificationState()) {
    on<FetchNotificationsEvent>(_onFetchNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkAsRead);
  }

  Future<void> _onFetchNotifications(FetchNotificationsEvent event, Emitter<NotificationState> emit) async {
    emit(state.copyWith(status: NotificationStatus.loading));
    final result = await repository.getNotifications();
    result.fold(
      (failure) => emit(state.copyWith(status: NotificationStatus.failure, errorMessage: failure.message)),
      (notifications) => emit(state.copyWith(status: NotificationStatus.success, notifications: notifications)),
    );
  }

  Future<void> _onMarkAsRead(MarkNotificationAsReadEvent event, Emitter<NotificationState> emit) async {
    final result = await repository.markAsRead(event.notificationId);
    result.fold(
      (failure) => null, // Silently ignore error for now
      (_) {
        final updatedList = state.notifications.map((n) {
          if (n.id == event.notificationId) {
            return NotificationEntity(
              id: n.id,
              userId: n.userId,
              type: n.type,
              title: n.title,
              message: n.message,
              metadata: n.metadata,
              isRead: true,
              createdAt: n.createdAt,
              readAt: DateTime.now(),
            );
          }
          return n;
        }).toList();
        emit(state.copyWith(notifications: updatedList));
      },
    );
  }
}
