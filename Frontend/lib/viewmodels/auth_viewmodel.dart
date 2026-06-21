import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/firebase_messaging_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  final FirebaseMessagingService _fcmService;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  // State khusus untuk operasi password
  bool _isPasswordLoading = false;
  String? _passwordError;
  bool _passwordSuccess = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  bool get isPasswordLoading => _isPasswordLoading;
  String? get passwordError => _passwordError;
  bool get passwordSuccess => _passwordSuccess;

  AuthViewModel({
    required this.authRepository,
    FirebaseMessagingService? fcmService,
  }) : _fcmService = fcmService ?? FirebaseMessagingService();

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String currency,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await authRepository.register(
        name: name,
        email: email,
        password: password,
        currency: currency,
      );
      _isLoggedIn = true;
      _errorMessage = null;
      await loadCurrentUser();

      // Ambil userId dari response atau dari currentUser
      final userId =
          _currentUser?.id ??
          response['user']?['id'] as String? ??
          response['userId'] as String?;

      if (userId != null && userId.isNotEmpty) {
        // Await FCM init agar permission prompt muncul sebelum navigasi
        await _fcmService.initialize(userId: userId);
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await authRepository.login(
        email: email,
        password: password,
      );
      _isLoggedIn = true;
      await loadCurrentUser();

      // Ambil userId dari response atau dari currentUser
      final userId =
          _currentUser?.id ??
          response['user']?['id'] as String? ??
          response['userId'] as String?;

      if (userId != null && userId.isNotEmpty) {
        await _fcmService.initialize(userId: userId);
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoggedIn = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await authRepository.logout();
      await _fcmService.deleteToken(); // Hapus FCM token saat logout
      _fcmService.resetInitialized();  // Reset agar login berikutnya bisa init ulang
    } catch (e) {
      debugPrint("Logout error: $e");
    } finally {
      _isLoggedIn = false;
      _currentUser = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await authRepository.getCurrentUser();
      if (_currentUser != null) {
        _isLoggedIn = true;
        // FCM init hanya dilakukan di login() / register().
        // loadCurrentUser() hanya me-restore state user, bukan trigger FCM ulang.
        // Untuk session restore (app restart), FCM diinisialisasi di bawah.
        await _fcmService.initialize(userId: _currentUser!.id);
      }
      _errorMessage = null;
    } catch (e) {
      // Clear error message because this is a background session check,
      // we don't want to show "unauthorized token" on the login screen.
      _errorMessage = null;
      _isLoggedIn = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String currency,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await authRepository.updateProfile(
        name: name,
        currency: currency,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isPasswordLoading = true;
    _passwordError = null;
    _passwordSuccess = false;
    notifyListeners();

    try {
      await authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _passwordSuccess = true;
      return true;
    } catch (e) {
      _passwordError = e.toString();
      return false;
    } finally {
      _isPasswordLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    _isPasswordLoading = true;
    _passwordError = null;
    _passwordSuccess = false;
    notifyListeners();

    try {
      await authRepository.resetPassword(email: email, newPassword: newPassword);
      _passwordSuccess = true;
      return true;
    } catch (e) {
      _passwordError = e.toString();
      return false;
    } finally {
      _isPasswordLoading = false;
      notifyListeners();
    }
  }

  void clearPasswordState() {
    _passwordError = null;
    _passwordSuccess = false;
    notifyListeners();
  }
}
