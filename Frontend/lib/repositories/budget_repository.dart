import '../models/budget_model.dart';
import '../services/api_service.dart';

class BudgetRepository {
  final ApiService apiService;

  BudgetRepository({required this.apiService});

  Future<List<Budget>> getBudgets({String? month}) async {
    final data = await apiService.getBudgets(month: month);
    final budgets = (data['data'] as List?)
        ?.map<Budget>((json) => Budget.fromJson(json as Map<String, dynamic>))
        .toList();
    return budgets ?? [];
  }

  Future<Budget> getBudgetDetail(String budgetId) async {
    final data = await apiService.getBudgetDetail(budgetId);
    return Budget.fromJson(data);
  }

  Future<Budget> createBudget({
    required String categoryId,
    required double limitAmount,
    required String month,
  }) async {
    final data = await apiService.createBudget(
      categoryId: categoryId,
      limitAmount: limitAmount,
      month: month,
    );
    return Budget.fromJson(data);
  }

  Future<Budget> updateBudget({
    required String budgetId,
    required double limitAmount,
  }) async {
    final data = await apiService.updateBudget(
      budgetId: budgetId,
      limitAmount: limitAmount,
    );
    return Budget.fromJson(data);
  }

  Future<void> deleteBudget(String budgetId) async {
    await apiService.deleteBudget(budgetId);
  }
}
