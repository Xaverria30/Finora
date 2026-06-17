import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'preferences_service.dart';

class RealApiService implements ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000/api';
      }
    } catch (_) {}
    return 'http://localhost:3000/api';
  }

  final http.Client httpClient;
  final PreferencesService preferencesService;
  String? _authToken;

  RealApiService({required this.httpClient, required this.preferencesService}) {
    _authToken = preferencesService.getAuthToken();
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  void _handleError(http.Response response, String defaultError) {
    try {
      final data = jsonDecode(response.body);
      final errorData = data['error'] ?? data['message'];

      String message;
      if (errorData == null) {
        message = '$defaultError: ${response.statusCode}';
      } else if (errorData is Map) {
        message = errorData['message']?.toString() ?? errorData.toString();
      } else {
        message = errorData.toString();
      }

      throw ApiException(message, statusCode: response.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        '$defaultError: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  Future<http.Response> _requestWithRetry(
    Future<http.Response> Function() requestFn,
  ) async {
    var response = await requestFn();
    if (response.statusCode == 401) {
      final rToken = preferencesService.getRefreshToken();
      if (rToken != null) {
        try {
          final refreshData = await refreshToken(rToken);
          if (refreshData.containsKey('accessToken')) {
            response = await requestFn();
          }
        } catch (_) {}
      }
    }
    return response;
  }

  Future<http.Response> _get(Uri uri) =>
      _requestWithRetry(() => httpClient.get(uri, headers: _headers));

  Future<http.Response> _post(Uri uri, {Object? body}) =>
      _requestWithRetry(() => httpClient.post(uri, headers: _headers, body: body));

  Future<http.Response> _put(Uri uri, {Object? body}) =>
      _requestWithRetry(() => httpClient.put(uri, headers: _headers, body: body));

  Future<http.Response> _delete(Uri uri) =>
      _requestWithRetry(() => httpClient.delete(uri, headers: _headers));

  @override
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    await preferencesService.saveAuthToken(token);
  }

  @override
  Future<String?> getAuthToken() async {
    return _authToken;
  }

  @override
  Future<void> clearAuthToken() async {
    _authToken = null;
    await preferencesService.clearSession();
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String currency,
  }) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'currency': currency,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['refreshToken'] != null) {
        await preferencesService.saveRefreshToken(data['refreshToken']);
      }
      return data;
    }
    _handleError(response, 'Register gagal');
    return {}; // Unreachable, but needed for return type
  }

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await setAuthToken(data['accessToken']);
      if (data['refreshToken'] != null) {
        await preferencesService.saveRefreshToken(data['refreshToken']);
      }
      return data;
    }
    _handleError(response, 'Login gagal');
    return {}; // Unreachable
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: _headers,
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await setAuthToken(data['accessToken']);
      if (data['refreshToken'] != null) {
        await preferencesService.saveRefreshToken(data['refreshToken']);
      }
      return data;
    }
    _handleError(response, 'Refresh token gagal');
    return {}; // Unreachable
  }

  @override
  Future<void> logout() async {
    final response = await _post(
      Uri.parse('$baseUrl/auth/logout'),
    );

    if (response.statusCode == 200) {
      await clearAuthToken();
    } else {
      _handleError(response, 'Logout gagal');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _post(
      Uri.parse('$baseUrl/auth/change-password'),
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      _handleError(response, 'Ubah password gagal');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    // Endpoint publik — tidak perlu token autentikasi
    final response = await httpClient.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'newPassword': newPassword}),
    );

    if (response.statusCode != 200) {
      _handleError(response, 'Reset password gagal');
    }
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _get(
      Uri.parse('$baseUrl/users/me'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    _handleError(response, 'Ambil user gagal');
    return {};
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String currency,
  }) async {
    final response = await _put(
      Uri.parse('$baseUrl/users/me'),
      body: jsonEncode({'name': name, 'currency': currency}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    _handleError(response, 'Update profil gagal');
    return {};
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories({String? type}) async {
    final queryParams = {if (type != null) 'type': type};
    final uri = Uri.parse(
      '$baseUrl/categories',
    ).replace(queryParameters: queryParams);

    final response = await _get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    }
    _handleError(response, 'Ambil kategori gagal');
    return [];
  }

  @override
  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String? icon,
    required String? color,
    required String type,
  }) async {
    final response = await _post(
      Uri.parse('$baseUrl/categories'),
      body: jsonEncode({
        'name': name,
        'icon': icon,
        'color': color,
        'type': type,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    _handleError(response, 'Buat kategori gagal');
    return {};
  }

  @override
  Future<Map<String, dynamic>> updateCategory({
    required String categoryId,
    required String name,
    required String? color,
  }) async {
    final response = await _put(
      Uri.parse('$baseUrl/categories/$categoryId'),
      body: jsonEncode({'name': name, 'color': color}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    _handleError(response, 'Update kategori gagal');
    return {};
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    final response = await _delete(
      Uri.parse('$baseUrl/categories/$categoryId'),
    );

    if (response.statusCode != 204) {
      _handleError(response, 'Hapus kategori gagal');
    }
  }

  @override
  Future<Map<String, dynamic>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    String? categoryId,
    String? startDate,
    String? endDate,
    String? search,
  }) async {
    final queryParams = {
      'page': '$page',
      'limit': '$limit',
      if (type != null) 'type': type,
      if (categoryId != null) 'categoryId': categoryId,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      if (search != null) 'search': search,
    };

    final response = await _get(
      Uri.parse('$baseUrl/transactions').replace(queryParameters: queryParams),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    _handleError(response, 'Ambil transaksi gagal');
    return {};
  }

  @override
  Future<Map<String, dynamic>> getTransactionDetail(
    String transactionId,
  ) async {
    final response = await _get(
      Uri.parse('$baseUrl/transactions/$transactionId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    _handleError(response, 'Ambil detail transaksi gagal');
    return {};
  }

  @override
  Future<Map<String, dynamic>> createTransaction({
    required String categoryId,
    required double amount,
    required String type,
    required String description,
    required String date,
    List<String>? tags,
  }) async {
    final response = await _post(
      Uri.parse('$baseUrl/transactions'),
      body: jsonEncode({
        'categoryId': categoryId,
        'amount': amount,
        'type': type,
        'description': description,
        'date': date,
        'tags': tags,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    _handleError(response, 'Buat transaksi gagal');
    return {};
  }

  @override
  Future<Map<String, dynamic>> updateTransaction({
    required String transactionId,
    required String categoryId,
    required double amount,
    required String description,
    required String date,
  }) async {
    final response = await _put(
      Uri.parse('$baseUrl/transactions/$transactionId'),
      body: jsonEncode({
        'categoryId': categoryId,
        'amount': amount,
        'description': description,
        'date': date,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    _handleError(response, 'Update transaksi gagal');
    return {};
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    final response = await _delete(
      Uri.parse('$baseUrl/transactions/$transactionId'),
    );

    if (response.statusCode != 204) {
      _handleError(response, 'Hapus transaksi gagal');
    }
  }

  @override
  Future<Map<String, dynamic>> getBudgets({String? month}) async {
    final queryParams = {if (month != null) 'month': month};

    final response = await _get(
      Uri.parse('$baseUrl/budgets').replace(queryParameters: queryParams),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    _handleError(response, 'Ambil budget gagal');
    return {};
  }

  @override
  Future<Map<String, dynamic>> getBudgetDetail(String budgetId) async {
    final response = await _get(
      Uri.parse('$baseUrl/budgets/$budgetId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    _handleError(response, 'Ambil detail budget gagal');
    return {};
  }

  @override
  Future<Map<String, dynamic>> createBudget({
    required String categoryId,
    required double limitAmount,
    required String month,
  }) async {
    final response = await _post(
      Uri.parse('$baseUrl/budgets'),
      body: jsonEncode({
        'categoryId': categoryId,
        'limitAmount': limitAmount,
        'month': month,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    _handleError(response, 'Buat budget gagal');
    return {};
  }

  @override
  Future<Map<String, dynamic>> updateBudget({
    required String budgetId,
    required double limitAmount,
  }) async {
    final response = await _put(
      Uri.parse('$baseUrl/budgets/$budgetId'),
      body: jsonEncode({'limitAmount': limitAmount}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    _handleError(response, 'Update budget gagal');
    return {};
  }

  @override
  Future<void> deleteBudget(String budgetId) async {
    final response = await _delete(
      Uri.parse('$baseUrl/budgets/$budgetId'),
    );

    if (response.statusCode != 204) {
      _handleError(response, 'Hapus budget gagal');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSavingGoals() async {
    final response = await _get(
      Uri.parse('$baseUrl/saving-goals'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    }
    _handleError(response, 'Ambil tujuan tabungan gagal');
    return [];
  }

  @override
  Future<Map<String, dynamic>> getSavingGoalDetail(String goalId) async {
    final response = await _get(
      Uri.parse('$baseUrl/saving-goals/$goalId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    _handleError(response, 'Ambil detail tujuan tabungan gagal');
    return {};
  }

  @override
  Future<Map<String, dynamic>> createSavingGoal({
    required String name,
    required String? description,
    required double targetAmount,
    required String deadline,
    double currentAmount = 0.0,
  }) async {
    final response = await _post(
      Uri.parse('$baseUrl/saving-goals'),
      body: jsonEncode({
        'name': name,
        'description': description,
        'targetAmount': targetAmount,
        'deadline': deadline,
        'currentAmount': currentAmount,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    _handleError(response, 'Buat tujuan tabungan gagal');
    return {};
  }

  @override
  Future<Map<String, dynamic>> addContribution({
    required String goalId,
    required double amount,
    required String description,
  }) async {
    final response = await _post(
      Uri.parse('$baseUrl/saving-goals/$goalId/contribute'),
      body: jsonEncode({'amount': amount, 'description': description}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    _handleError(response, 'Tambah kontribusi gagal');
    return {};
  }

  @override
  Future<Map<String, dynamic>> updateSavingGoal({
    required String goalId,
    required double targetAmount,
    required String deadline,
    double currentAmount = 0.0,
  }) async {
    final response = await _put(
      Uri.parse('$baseUrl/saving-goals/$goalId'),
      body: jsonEncode({
        'targetAmount': targetAmount,
        'deadline': deadline,
        'currentAmount': currentAmount,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    _handleError(response, 'Update tujuan tabungan gagal');
    return {};
  }

  @override
  Future<void> deleteSavingGoal(String goalId) async {
    final response = await _delete(
      Uri.parse('$baseUrl/saving-goals/$goalId'),
    );

    if (response.statusCode != 204) {
      _handleError(response, 'Hapus tujuan tabungan gagal');
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardSummary({
    String period = 'monthly',
    String? month,
  }) async {
    final queryParams = {'period': period, if (month != null) 'month': month};

    final response = await _get(
      Uri.parse(
        '$baseUrl/dashboard/summary',
      ).replace(queryParameters: queryParams),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    _handleError(response, 'Ambil ringkasan dashboard gagal');
    return {};
  }

  @override
  Future<Map<String, dynamic>> getExpenseAnalytics({
    String? month,
    String groupBy = 'category',
  }) async {
    final queryParams = {'groupBy': groupBy, if (month != null) 'month': month};

    final response = await _get(
      Uri.parse(
        '$baseUrl/dashboard/analytics/expenses',
      ).replace(queryParameters: queryParams),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    _handleError(response, 'Ambil analitik pengeluaran gagal');
    return {};
  }
}
