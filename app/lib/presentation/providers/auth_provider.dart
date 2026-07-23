import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsletter_portal/domain/entities/user.dart';
import 'package:newsletter_portal/domain/repositories/auth_repository.dart';
import 'package:newsletter_portal/domain/repositories/profile_repository.dart';
import 'package:newsletter_portal/core/network/dio_client.dart';
import 'package:newsletter_portal/data/datasources/auth_remote_datasource.dart';
import 'package:newsletter_portal/data/datasources/profile_remote_datasource.dart';
import 'package:newsletter_portal/data/repositories/auth_repository_impl.dart';
import 'package:newsletter_portal/data/repositories/profile_repository_impl.dart';
import 'package:newsletter_portal/presentation/widgets/tag_picker.dart';

sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  AuthNotifier(this._authRepository, this._profileRepository) : super(AuthInitial());

  Future<void> checkAuth() async {
    state = AuthLoading();
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _profileRepository.getProfile();
        state = AuthAuthenticated(user);
      } else {
        state = AuthUnauthenticated();
      }
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> login(String username, String password) async {
    state = AuthLoading();
    try {
      await _authRepository.login(username, password);
      final user = await _profileRepository.getProfile();
      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> register(String email, String username, String password) async {
    state = AuthLoading();
    try {
      await _authRepository.register(email, username, password);
      await login(username, password);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> logout() async {
    // Skip AuthLoading so the router only redirects once (avoids remounting LoginPage).
    try {
      await _authRepository.logout();
    } catch (_) {
      // Clear local session even if the network call fails.
    }
    state = AuthUnauthenticated();
  }
}


final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return AuthRemoteDatasource(dio);
});

final profileRemoteDatasourceProvider = Provider<ProfileRemoteDatasource>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return ProfileRemoteDatasource(dio);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remote = ref.watch(profileRemoteDatasourceProvider);
  return ProfileRepositoryImpl(remoteDatasource: remote);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(authRemoteDatasourceProvider);
  final profile = ref.watch(profileRepositoryProvider);
  return AuthRepositoryImpl(remoteDatasource: remote, profileRepository: profile);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(profileRepositoryProvider),
  )..checkAuth();
});

final allTopicsProvider = FutureProvider<List<TagItem>>((ref) async {
  const fallbackTopics = [
    (tag: 'politics', displayName: 'Politics'),
    (tag: 'business', displayName: 'Business & Economy'),
    (tag: 'technology', displayName: 'Technology'),
    (tag: 'macro-economics', displayName: 'Macro Economics'),
    (tag: 'markets', displayName: 'Markets'),
    (tag: 'energy', displayName: 'Energy & Resources'),
    (tag: 'defense', displayName: 'Defense & Security'),
    (tag: 'climate', displayName: 'Climate & Environment'),
    (tag: 'real-estate', displayName: 'Real Estate'),
    (tag: 'healthcare', displayName: 'Healthcare'),
    (tag: 'crypto', displayName: 'Crypto & Digital Assets'),
    (tag: 'geopolitics', displayName: 'Geopolitics'),
  ];

  try {
    final repository = ref.watch(profileRepositoryProvider);
    final topics = await repository.getAllTopics();
    if (topics.isNotEmpty) {
      return topics.map((t) => (tag: t.tag, displayName: t.displayName)).toList();
    }
    return fallbackTopics;
  } catch (_) {
    return fallbackTopics;
  }
});
