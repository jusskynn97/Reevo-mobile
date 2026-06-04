import 'package:reevo/features/auth/domain/entity/auth_entity.dart';
import 'package:reevo/features/auth/domain/repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthResponse> call(LoginRequest request) {
    return repository.login(request);
  }
}

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<AuthResponse> call(RegisterRequest request) {
    return repository.register(request);
  }
}

class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  Future<AuthResponse> call(String refreshToken) {
    return repository.refreshToken(refreshToken);
  }
}

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call(String refreshToken) {
    return repository.logout(refreshToken);
  }
}
