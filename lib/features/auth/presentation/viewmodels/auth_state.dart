import 'package:beitak_app/features/auth/domain/entities/auth_session_entity.dart';

enum AuthStatus { loading, unauthenticated, guest, authenticated }

class AuthState {
  final AuthStatus status;
  final AuthSessionEntity? session;

  const AuthState._(this.status, this.session);

  const AuthState.loading() : this._(AuthStatus.loading, null);

  const AuthState.unauthenticated() : this._(AuthStatus.unauthenticated, null);

  const AuthState.guest(AuthSessionEntity s) : this._(AuthStatus.guest, s);

  const AuthState.authenticated(AuthSessionEntity s)
      : this._(AuthStatus.authenticated, s);

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isGuest => status == AuthStatus.guest;

  String get role => (session?.user?.role ?? '').toLowerCase();

  bool get isProvider =>
      role == 'provider' ||
      role == 'service_provider' ||
      role == 'serviceprovider';
}
