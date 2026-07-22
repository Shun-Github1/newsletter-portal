abstract class AuthRepository {
  Future<void> register(String email, String username, String password);
  Future<void> login(String username, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
}
