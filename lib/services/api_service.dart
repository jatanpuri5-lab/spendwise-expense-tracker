// lib/services/api_service.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _lanApiUrl = String.fromEnvironment('API_BASE_URL');
  static const Duration requestTimeout = Duration(seconds: 10);

  static String get defaultBaseUrl {
    if (_lanApiUrl.isNotEmpty) {
      return _lanApiUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api';
    }

    return 'http://localhost:5000/api';
  }

  final http.Client _client;
  String baseUrl = defaultBaseUrl;
  String? authToken;

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
  }

  Future<dynamic> get(String path) async {
    return _send(() => _client.get(_uri(path), headers: _headers));
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    return _send(
      () => _client.post(
        _uri(path),
        headers: _headers,
        body: jsonEncode(body),
      ),
    );
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    return _send(
      () => _client.put(
        _uri(path),
        headers: _headers,
        body: jsonEncode(body),
      ),
    );
  }

  Future<void> delete(String path) async {
    await _send(() => _client.delete(_uri(path), headers: _headers));
  }

  Uri _uri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath');
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(requestTimeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(
        'Connection timeout. Please check backend and Wi-Fi.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Cannot connect to server. Make sure backend is running.',
      );
    } catch (err) {
      if (err is ApiException) {
        rethrow;
      }

      throw const ApiException(
        'Cannot connect to server. Make sure backend is running.',
      );
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 204) {
      return null;
    }

    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message = decoded is Map<String, dynamic>
        ? decoded['message']?.toString() ?? 'API request failed'
        : 'API request failed';

    throw ApiException(message, response.statusCode);
  }
}
