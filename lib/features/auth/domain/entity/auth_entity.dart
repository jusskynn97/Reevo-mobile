import 'package:equatable/equatable.dart';

class AuthResponse extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String userId;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, userId];
}

class LoginRequest extends Equatable {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequest extends Equatable {
  final String username;
  final String email;
  final String password;
  final String? displayName;

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [username, email, password, displayName];
}
