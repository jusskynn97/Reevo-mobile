import 'package:reevo/features/auth/domain/entity/auth_entity.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<AuthResponse> refreshToken(String refreshToken);
  Future<void> logout(String refreshToken);
}
