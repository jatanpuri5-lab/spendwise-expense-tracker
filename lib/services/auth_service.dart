// lib/services/auth_service.dart

import 'api_service.dart';

class AuthUser {
  final int id;
  final String name;
  final String email;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

class AuthResult {
  final String token;
  final AuthUser user;

  const AuthResult({
    required this.token,
    required this.user,
  });
}

class AuthService {
  AuthService(this._api);

  final ApiService _api;
  AuthUser? currentUser;

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final json = await _api.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;

    return _setSession(json);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final json = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;

    return _setSession(json);
  }

  void logout() {
    _api.authToken = null;
    currentUser = null;
  }

  AuthResult _setSession(Map<String, dynamic> json) {
    final token = json['token'] as String;
    final user = AuthUser.fromJson(json['user'] as Map<String, dynamic>);

    _api.authToken = token;
    currentUser = user;

    return AuthResult(token: token, user: user);
  }
}
