import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService apiService;

  AuthRepository({required this.apiService});

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String currency,
  }) async {
    final response = await apiService.register(
      name: name,
      email: email,
      password: password,
      currency: currency,
    );
    await apiService.setAuthToken(response['accessToken']);
    return response;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await apiService.login(email: email, password: password);
    await apiService.setAuthToken(response['accessToken']);
    return response;
  }

  Future<void> logout() async {
    try {
      await apiService.logout();
    } catch (_) {
      // Ignore API error during logout to ensure local session is always cleared
    } finally {
      await apiService.clearAuthToken();
    }
  }

  Future<User> getCurrentUser() async {
    final data = await apiService.getCurrentUser();
    return User.fromJson(data);
  }

  Future<User> updateProfile({
    required String name,
    required String currency,
  }) async {
    final data = await apiService.updateProfile(name: name, currency: currency);
    return User.fromJson(data);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await apiService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await apiService.resetPassword(email: email, newPassword: newPassword);
  }
}
