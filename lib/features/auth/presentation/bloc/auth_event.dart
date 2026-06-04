part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String? displayName;

  const AuthRegisterEvent({
    required this.username,
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [username, email, password, displayName];
}

class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();
}

class AuthCheckStatusEvent extends AuthEvent {
  const AuthCheckStatusEvent();
}

class AuthRefreshTokenEvent extends AuthEvent {
  const AuthRefreshTokenEvent();
}
