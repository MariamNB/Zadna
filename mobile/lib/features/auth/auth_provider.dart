import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/token_response.dart';
import '../../data/repositories/auth_repository.dart';

abstract class AuthState {
  const AuthState();
}

class Authenticated extends AuthState {
  final TokenResponse tokens;
  final String userId;
  final String householdId;

  const Authenticated({
    required this.tokens,
    required this.userId,
    required this.householdId,
  });
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class Loading extends AuthState {
  const Loading();
}

class Error extends AuthState {
  final String message;
  const Error(this.message);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const Unauthenticated());

  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const Loading();
    try {
      final tokens = await _repository.register(email: email, password: password);
      final userId = await _repository.getCurrentUserId() ?? '';
      final householdId = await _repository.getCurrentHouseholdId() ?? '';
      state = Authenticated(
        tokens: tokens,
        userId: userId,
        householdId: householdId,
      );
    } catch (e) {
      state = Error(e.toString());
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const Loading();
    try {
      final tokens = await _repository.login(email: email, password: password);
      final userId = await _repository.getCurrentUserId() ?? '';
      final householdId = await _repository.getCurrentHouseholdId() ?? '';
      state = Authenticated(
        tokens: tokens,
        userId: userId,
        householdId: householdId,
      );
    } catch (e) {
      state = Error(e.toString());
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const Unauthenticated();
  }

  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await _repository.isLoggedIn();
      if (!isLoggedIn) {
        state = const Unauthenticated();
        return;
      }

      final tokens = await _repository.refreshToken();
      if (tokens != null) {
        final userId = await _repository.getCurrentUserId() ?? '';
        final householdId = await _repository.getCurrentHouseholdId() ?? '';
        state = Authenticated(
          tokens: tokens,
          userId: userId,
          householdId: householdId,
        );
      } else {
        await _repository.logout();
        state = const Unauthenticated();
      }
    } catch (_) {
      await _repository.logout();
      state = const Unauthenticated();
    }
  }
}