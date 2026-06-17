abstract class ApiService {
  Future<void> setAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> clearAuthToken();

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String currency,
  });

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> refreshToken(String refreshToken);
  Future<void> logout();
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  });

  Future<Map<String, dynamic>> getCurrentUser();
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String currency,
  });

  Future<List<Map<String, dynamic>>> getCategories({String? type});
  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String? icon,
    required String? color,
    required String type,
  });
  Future<Map<String, dynamic>> updateCategory({
    required String categoryId,
    required String name,
    required String? color,
  });
  Future<void> deleteCategory(String categoryId);

  Future<Map<String, dynamic>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    String? categoryId,
    String? startDate,
    String? endDate,
    String? search,
  });
  Future<Map<String, dynamic>> getTransactionDetail(String transactionId);
  Future<Map<String, dynamic>> createTransaction({
    required String categoryId,
    required double amount,
    required String type,
    required String description,
    required String date,
    List<String>? tags,
  });
  Future<Map<String, dynamic>> updateTransaction({
    required String transactionId,
    required String categoryId,
    required double amount,
    required String description,
    required String date,
  });
  Future<void> deleteTransaction(String transactionId);

  Future<Map<String, dynamic>> getBudgets({String? month});
  Future<Map<String, dynamic>> getBudgetDetail(String budgetId);
  Future<Map<String, dynamic>> createBudget({
    required String categoryId,
    required double limitAmount,
    required String month,
  });
  Future<Map<String, dynamic>> updateBudget({
    required String budgetId,
    required double limitAmount,
  });
  Future<void> deleteBudget(String budgetId);

  Future<List<Map<String, dynamic>>> getSavingGoals();
  Future<Map<String, dynamic>> getSavingGoalDetail(String goalId);
  Future<Map<String, dynamic>> createSavingGoal({
    required String name,
    required String? description,
    required double targetAmount,
    required String deadline,
    double currentAmount = 0.0,
  });
  Future<Map<String, dynamic>> addContribution({
    required String goalId,
    required double amount,
    required String description,
  });
  Future<Map<String, dynamic>> updateSavingGoal({
    required String goalId,
    required double targetAmount,
    required String deadline,
    double currentAmount = 0.0,
  });
  Future<void> deleteSavingGoal(String goalId);

  Future<Map<String, dynamic>> getDashboardSummary({
    String period = 'monthly',
    String? month,
  });
  Future<Map<String, dynamic>> getExpenseAnalytics({
    String? month,
    String groupBy = 'category',
  });
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
