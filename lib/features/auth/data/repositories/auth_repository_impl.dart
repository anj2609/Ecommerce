import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  User? get currentUser => _remoteDataSource.currentUser;

  @override
  Stream<User?> get authStateChanges => _remoteDataSource.authStateChanges;

  @override
  Future<User?> signInWithGoogle() => _remoteDataSource.signInWithGoogle();

  @override
  Future<void> signOut() => _remoteDataSource.signOut();

  @override
  bool get isLoggedIn => _remoteDataSource.isLoggedIn;
}
