// lib/providers/auth_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/models.dart';

part 'auth_provider.g.dart';

enum AuthStatus { authenticated, unauthenticated, loading }

@riverpod
class AuthState extends _$AuthState {
  @override
  AuthStatus build() => AuthStatus.unauthenticated;

  void setAuthenticated() {
    state = AuthStatus.authenticated;
  }

  void setUnauthenticated() {
    state = AuthStatus.unauthenticated;
  }

  void setLoading() {
    state = AuthStatus.loading;
  }
}
