import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/api/api_client.dart';
import '../models/auth_request.dart';
import '../models/token_response.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Map<String, dynamic> _jwtPayload(String token) {
    final payload = token.split('.')[1];
    final decoded = utf8.decode(base64Url.decode(base64Url.normalize(payload)));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }

  Future<void> _storeTokenResponse(TokenResponse tokens) async {
    final claims = _jwtPayload(tokens.accessToken);
    await _apiClient.storeTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken ?? '',
      userId: claims['sub'] as String? ?? '',
      householdId: claims['household_id'] as String? ?? '',
    );
  }

  Future<TokenResponse> register({
    required String email,
    required String password,
  }) async {
    final request = RegisterRequest(email: email, password: password);
    final response = await _apiClient.dio.post(
      '/auth/register',
      data: request.toJson(),
    );
    final tokens = TokenResponse.fromJson(response.data);
    await _storeTokenResponse(tokens);
    return tokens;
  }

  Future<TokenResponse> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequest(email: email, password: password);
    final response = await _apiClient.dio.post(
      '/auth/login',
      data: request.toJson(),
    );
    final tokens = TokenResponse.fromJson(response.data);
    await _storeTokenResponse(tokens);
    return tokens;
  }

  Future<void> logout() async {
    await _apiClient.logout();
  }

  Future<TokenResponse?> refreshToken() async {
    try {
      final refreshToken = await _apiClient.getRefreshToken();
      if (refreshToken == null) return null;

      final response = await _apiClient.dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      return TokenResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _apiClient.logout();
      }
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiClient.getAccessToken();
    return token != null;
  }

  Future<String?> getCurrentUserId() async => _apiClient.getUserId();
  Future<String?> getCurrentHouseholdId() async => _apiClient.getHouseholdId();
}