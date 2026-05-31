import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reevo/core/di/service_locator.dart';
import 'package:reevo/core/services/notification_service.dart';
import 'package:reevo/core/services/token_storage_service.dart';
import 'package:reevo/features/auth/domain/entity/auth_entity.dart';
import 'package:reevo/features/auth/domain/usecase/auth_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final TokenStorageService tokenStorageService;
  final NotificationService _notificationService = getIt<NotificationService>();

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.refreshTokenUseCase,
    required this.tokenStorageService,
  }) : super(const AuthInitial()) {
    on<AuthLoginEvent>(_onAuthLogin);
    on<AuthRegisterEvent>(_onAuthRegister);
    on<AuthLogoutEvent>(_onAuthLogout);
    on<AuthCheckStatusEvent>(_onAuthCheckStatus);
    on<AuthRefreshTokenEvent>(_onAuthRefreshToken);
  }

  Future<void> _onAuthLogin(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final request = LoginRequest(
        email: event.email,
        password: event.password,
      );
      final response = await loginUseCase(request);

      // Save tokens
      await tokenStorageService.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.userId,
      );

      emit(
        AuthAuthenticated(
          userId: response.userId,
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        ),
      );
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final request = RegisterRequest(
        username: event.username,
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      final response = await registerUseCase(request);

      // Save tokens
      await tokenStorageService.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.userId,
      );

      emit(
        AuthAuthenticated(
          userId: response.userId,
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        ),
      );
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // First unregister device from backend
      await _notificationService.unregisterDevice();
      
      // Then logout from auth service
      final refreshToken = tokenStorageService.getRefreshToken();
      if (refreshToken != null) {
        await logoutUseCase(refreshToken);
      }
      
      // Clear all local data
      await tokenStorageService.clearTokens();
      
      emit(const AuthUnauthenticated());
    } catch (e) {
      // Still clear tokens and logout even if something fails
      await tokenStorageService.clearTokens();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (tokenStorageService.isLoggedIn()) {
      final accessToken = tokenStorageService.getAccessToken();
      final refreshToken = tokenStorageService.getRefreshToken();
      final userId = tokenStorageService.getUserId();

      emit(
        AuthAuthenticated(
          userId: userId!,
          accessToken: accessToken!,
          refreshToken: refreshToken!,
        ),
      );
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthRefreshToken(
    AuthRefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final refreshToken = tokenStorageService.getRefreshToken();
      if (refreshToken == null) {
        await tokenStorageService.clearTokens();
        emit(const AuthUnauthenticated());
        return;
      }

      final response = await refreshTokenUseCase(refreshToken);

      // Update tokens
      await tokenStorageService.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.userId,
      );

      emit(
        AuthAuthenticated(
          userId: response.userId,
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        ),
      );
    } catch (e) {
      // Token refresh failed, logout
      await tokenStorageService.clearTokens();
      emit(const AuthUnauthenticated());
    }
  }
}
