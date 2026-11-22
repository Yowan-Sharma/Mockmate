import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../../../core/storage/secure_storage.dart';

enum AuthStatus {
  initializing,
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? token;

  const AuthState({
    required this.status,
    this.errorMessage,
    this.token,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? token,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage, // We want to be able to nullify it, so no fallback to this.errorMessage
      token: token ?? this.token,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState(status: AuthStatus.initializing)) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final token = await SecureStorage.getToken();
      // Add a slight delay for better UX on splash screen
      await Future.delayed(const Duration(milliseconds: 1500));
      
      if (token != null) {
        state = state.copyWith(status: AuthStatus.authenticated, token: token);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      final token = await _repository.login(email, password);
      await SecureStorage.saveToken(token);
      state = state.copyWith(status: AuthStatus.authenticated, token: token);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> signup(String fullName, String email, String password, String confirmPassword) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      final token = await _repository.signup(fullName, email, password, confirmPassword);
      await SecureStorage.saveToken(token);
      state = state.copyWith(status: AuthStatus.authenticated, token: token);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    await SecureStorage.deleteToken();
    state = state.copyWith(status: AuthStatus.unauthenticated, token: null);
  }
  
  void resetError() {
    if (state.status == AuthStatus.error) {
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null);
    }
  }
}

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
