import 'package:newsletter_portal/domain/repositories/auth_repository.dart';
import 'package:newsletter_portal/domain/repositories/profile_repository.dart';
import 'package:newsletter_portal/data/datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final ProfileRepository profileRepository;

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.profileRepository,
  });

  @override
  Future<void> register(String email, String username, String password) async {
    await remoteDatasource.register(email, username, password);
  }

  @override
  Future<void> login(String username, String password) async {
    await remoteDatasource.login(username, password);
  }

  @override
  Future<void> logout() async {
    await remoteDatasource.logout();
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      await profileRepository.getProfile();
      return true;
    } catch (e) {
      return false;
    }
  }
}
