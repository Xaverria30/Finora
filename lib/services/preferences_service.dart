import 'package:finora/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Uses SQLite under the hood, with in-memory cache for synchronous access.

  final DatabaseService _dbService = DatabaseService();

  // Cached values for quick synchronous access.
  String? _cachedToken;
  String? _cachedUserId;
  String? _cachedName;
  String? _cachedCurrency;
  String? _cachedRefreshToken;

  // Keep the old constructor signature for backward compatibility.
  // The optional SharedPreferences param is ignored — SQLite is used instead.
  PreferencesService([SharedPreferences? _]);

  /// Call once at app startup to restore session from SQLite into cache.
  Future<void> initFromDB() async {
    final data = await _dbService.getSession();
    if (data != null) {
      _cachedToken = data['token'] as String?;
      _cachedUserId = data['userId'] as String?;
      _cachedName = data['name'] as String?;
      _cachedCurrency = data['currency'] as String?;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedRefreshToken = prefs.getString('refresh_token');
    } catch (_) {}
  }

  Future<void> saveAuthToken(String token) async {
    _cachedToken = token;
    final current = await _dbService.getSession() ?? {};
    await _dbService.saveSession(
      token: token,
      userId: current['userId'] as String? ?? _cachedUserId ?? '',
      name: current['name'] as String? ?? _cachedName ?? '',
      currency: current['currency'] as String? ?? _cachedCurrency ?? '',
    );
  }

  String? getAuthToken() => _cachedToken;

  Future<void> saveRefreshToken(String token) async {
    _cachedRefreshToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('refresh_token', token);
    } catch (_) {}
  }

  String? getRefreshToken() => _cachedRefreshToken;

  Future<void> saveUserData({
    required String userId,
    required String name,
    required String email,
    required String currency,
  }) async {
    _cachedUserId = userId;
    _cachedName = name;
    _cachedCurrency = currency;
    await _dbService.saveSession(
      token: _cachedToken ?? '',
      userId: userId,
      name: name,
      currency: currency,
    );
  }

  String? getUserId() => _cachedUserId;
  String? getUserName() => _cachedName;
  String? getUserEmail() => null; // email not stored in current schema
  String? getCurrency() => _cachedCurrency;

  Future<void> saveTheme(String themeMode) async {
    // Not persisted in current DB schema.
  }

  String getTheme() => 'light';

  Future<void> saveLanguage(String languageCode) async {
    // Not persisted in current DB schema.
  }

  String getLanguage() => 'id';

  Future<void> clearSession() async {
    _cachedToken = null;
    _cachedUserId = null;
    _cachedName = null;
    _cachedCurrency = null;
    _cachedRefreshToken = null;
    await _dbService.clearSession();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('refresh_token');
    } catch (_) {}
  }

  bool isLoggedIn() => _cachedToken != null && _cachedUserId != null;
}
