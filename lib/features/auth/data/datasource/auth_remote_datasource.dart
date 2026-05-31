import 'package:dio/dio.dart';
import 'package:reevo/features/auth/domain/entity/auth_entity.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<AuthResponse> refreshToken(String refreshToken);
  Future<void> logout(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/auth/login',
        data: {
          'email': request.email,
          'password': request.password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return AuthResponse(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          userId: data['userId'],
        );
      }
      throw Exception('Login failed');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/auth/register',
        data: {
          'username': request.username,
          'email': request.email,
          'password': request.password,
          'displayName': request.displayName,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return AuthResponse(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          userId: data['userId'],
        );
      }
      throw Exception('Register failed');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Register failed');
    }
  }

  @override
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/auth/refresh',
        data: refreshToken,  // Gửi raw token string thay vì JSON object
        options: Options(
          contentType: 'application/json',
        ),
      );

      if (response.statusCode == 200) {
        // Xử lý response data - có thể là response.data hoặc response.data['data']
        final responseData = response.data;
        final data = responseData is Map && responseData.containsKey('data') 
            ? responseData['data'] 
            : responseData;
        
        return AuthResponse(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          userId: data['userId'],
        );
      }
      throw Exception('Refresh token failed');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Refresh token failed');
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await dio.post(
        '$baseUrl/api/auth/logout',
        data: refreshToken,  // Gửi raw token string thay vì JSON object
        options: Options(
          contentType: 'application/json',
        ),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Logout failed');
    }
  }
}
