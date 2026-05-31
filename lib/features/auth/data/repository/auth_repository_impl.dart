import 'package:reevo/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:reevo/features/auth/domain/entity/auth_entity.dart';
import 'package:reevo/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    return await remoteDataSource.login(request);
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    return await remoteDataSource.register(request);
  }

  @override
  Future<AuthResponse> refreshToken(String refreshToken) async {
    return await remoteDataSource.refreshToken(refreshToken);
  }

  @override
  Future<void> logout(String refreshToken) async {
    return await remoteDataSource.logout(refreshToken);
  }
}
