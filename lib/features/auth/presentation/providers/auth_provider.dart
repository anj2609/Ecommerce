import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ecommerce_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    final user = _repository.currentUser;
    if (user != null) {
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repository.signInWithGoogle();
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _repository.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
