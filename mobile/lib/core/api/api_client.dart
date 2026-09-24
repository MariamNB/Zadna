import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient({
    Dio? dio,
    FlutterSecureStorage? storage,
  })  : _dio = dio ?? Dio(),
        _storage = storage ?? const FlutterSecureStorage() {
    _configureClient();
  }

  Dio get dio => _dio;

  void _configureClient() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = ApiConfig.connectTimeout;
    _dio.options.receiveTimeout = ApiConfig.receiveTimeout;
    // sendTimeout must be null on Flutter Web — setting it attaches an
    // onSendProgress listener that turns every request into a CORS preflight.
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        final isRefreshCall = error.requestOptions.path.contains('/auth/refresh');
        if (error.response?.statusCode == 401 && !isRefreshCall) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            final token = await _storage.read(key: 'access_token');
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            return handler.resolve(await _dio.fetch(error.requestOptions));
          }
          await _clearAuth();
        }
        return handler.next(error);
      },
    ));

    // Convert snake_case response keys to camelCase so generated models parse correctly
    _dio.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        response.data = _convertKeysToCamel(response.data);
        return handler.next(response);
      },
    ));

    // Add logging interceptor in debug mode
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('[Dio] $obj'),
    ));
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        await _storage.write(key: 'access_token', value: data['accessToken'] as String);
        if (data['refreshToken'] != null) {
          await _storage.write(key: 'refresh_token', value: data['refreshToken'] as String);
        }
        return true;
      }
    } catch (e) {
      print('Token refresh failed: $e');
    }
    return false;
  }

  Future<void> _clearAuth() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'household_id');
  }

  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String householdId,
  }) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    await _storage.write(key: 'user_id', value: userId);
    await _storage.write(key: 'household_id', value: householdId);
  }

  Future<String?> getAccessToken() => _storage.read(key: 'access_token');
  Future<String?> getRefreshToken() => _storage.read(key: 'refresh_token');
  Future<String?> getUserId() => _storage.read(key: 'user_id');
  Future<String?> getHouseholdId() => _storage.read(key: 'household_id');

  String _snakeToCamel(String key) => key.replaceAllMapped(
        RegExp(r'_([a-z])'),
        (m) => m.group(1)!.toUpperCase(),
      );

  dynamic _convertKeysToCamel(dynamic data) {
    if (data is Map) {
      return Map.fromEntries(
        data.entries.map((e) => MapEntry(_snakeToCamel(e.key as String), _convertKeysToCamel(e.value))),
      );
    }
    if (data is List) return data.map(_convertKeysToCamel).toList();
    return data;
  }

  Future<void> logout() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken != null) {
      try {
        await _dio.post('/auth/logout', data: {'refresh_token': refreshToken});
      } catch (e) {
        // Ignore logout errors
      }
    }
    await _clearAuth();
  }
}