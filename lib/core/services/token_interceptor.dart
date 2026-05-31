import 'dart:async';
import 'package:dio/dio.dart';
import 'package:reevo/core/services/token_storage_service.dart';

class TokenInterceptor extends Interceptor {
  final TokenStorageService tokenStorageService;
  final Dio authDio; // Dio instance cho auth endpoints (không có interceptor)
  final Dio apiDio; // Dio instance cho API endpoints (có token interceptor)
  
  // Lock để tránh refresh token nhiều lần song song
  final _refreshLock = Lock();
  
  // Track đã từng refresh lần nào để tránh vòng lặp vô tận
  final Set<String> _refreshedRequests = {};

  TokenInterceptor({
    required this.tokenStorageService,
    required this.authDio,
    required this.apiDio,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = tokenStorageService.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 403 || err.response?.statusCode == 401) {
      // Tạo key độc nhất cho request này
      final requestKey = '${err.requestOptions.method}:${err.requestOptions.path}';
      
      // Nếu request này đã refresh token rồi, thì không refresh nữa
      if (_refreshedRequests.contains(requestKey)) {
        print('Request already refreshed, skip: $requestKey');
        await tokenStorageService.clearTokens();
        return handler.next(err);
      }
      
      // Sử dụng lock để tránh refresh token nhiều lần
      return _refreshLock.synchronized(() async {
        try {
          final refreshToken = tokenStorageService.getRefreshToken();
          if (refreshToken == null) {
            print('No refresh token found');
            await tokenStorageService.clearTokens();
            return handler.next(err);
          }

          print('Refreshing token...');
          // Gọi refresh token API với authDio (không có TokenInterceptor)
          // Backend yêu cầu raw string data, không phải JSON object
          Response response;
          try {
            response = await authDio.post(
              '/api/auth/refresh',
              data: refreshToken,  // Gửi raw token string thay vì JSON object
              options: Options(
                contentType: 'application/json',
              ),
            );
          } on DioException catch (dioErr) {
            print('Refresh token request failed:');
            print('  Status: ${dioErr.response?.statusCode}');
            print('  Error: ${dioErr.message}');
            print('  Response data: ${dioErr.response?.data}');
            await tokenStorageService.clearTokens();
            return handler.next(err);
          }

          // Check response status code
          if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
            print('Token refreshed successfully');
            // Xử lý response data - có thể là response.data hoặc response.data['data']
            final responseData = response.data;
            final data = responseData is Map && responseData.containsKey('data') 
                ? responseData['data'] 
                : responseData;
            
            final newAccessToken = data['accessToken'];
            final newRefreshToken = data['refreshToken'];
            final userId = data['userId'];

            // Cập nhật tokens TRƯỚC khi retry
            await tokenStorageService.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
              userId: userId,
            );

            // Đánh dấu request này đã được refresh
            _refreshedRequests.add(requestKey);

            // Retry request gốc với token mới
            final options = err.requestOptions;
            
            // Đặt lại URL đầy đủ nếu path không có scheme
            final requestUrl = options.path.startsWith('http') 
                ? options.path 
                : options.path;

            try {
              print('Retrying request: $requestUrl');
              // Copy headers nhưng xóa Authorization header cũ để onRequest tự set token mới
              final newHeaders = Map<String, dynamic>.from(options.headers);
              newHeaders.remove('Authorization');
              
              final newResponse = await apiDio.request(
                requestUrl,
                options: Options(
                  method: options.method,
                  headers: newHeaders, // Headers không có Authorization cũ
                  contentType: options.contentType,
                ),
                data: options.data,
                queryParameters: options.queryParameters,
              );

              // Xóa key khỏi refreshed set sau khi thành công
              _refreshedRequests.remove(requestKey);
              print('Retry request succeeded');
              return handler.resolve(newResponse);
            } catch (retryError) {
              print('Retry request failed: $retryError');
              // Nếu retry vẫn thất bại, trả về lỗi gốc
              return handler.next(err);
            }
          } else {
            // Refresh token failed (401, 403, 5xx, etc)
            print('Refresh token failed with status: ${response.statusCode}');
            print('Response data: ${response.data}');
            // Chỉ xóa access token, GIỮ refresh token để user có thể thử refresh lại
            // Hoặc có thể logout hoàn toàn nếu là 401/403 từ backend
            await tokenStorageService.clearTokens();
            return handler.next(err);
          }
        } catch (e) {
          // Token refresh thất bại, logout
          print('Unexpected token refresh error: $e');
          await tokenStorageService.clearTokens();
          return handler.next(err);
        }
      });
    }
    return handler.next(err);
  }
}

/// Lock class để đồng bộ hóa các thao tác refresh token
class Lock {
  Completer<void>? _completer;

  Future<T> synchronized<T>(Future<T> Function() callback) async {
    while (_completer != null) {
      await _completer!.future;
    }

    _completer = Completer<void>();
    try {
      return await callback();
    } finally {
      _completer!.complete();
      _completer = null;
    }
  }
}

