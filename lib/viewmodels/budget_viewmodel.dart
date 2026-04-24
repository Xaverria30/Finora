import 'package:flutter/foundation.dart';
import '../models/budget_model.dart';
import '../repositories/budget_repository.dart';

class BudgetViewModel extends ChangeNotifier {
  final BudgetRepository budgetRepository;

  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _errorMessage;
  final Map<String, dynamic> _summary = {};

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get summary => _summary;

  BudgetViewModel({required this.budgetRepository});

  Future<void> loadBudgets({String? month}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _budgets = await budgetRepository.getBudgets(month: month);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBudget({
    required String categoryId,
    required double limitAmount,
    required String month,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newBudget = await budgetRepository.createBudget(
        categoryId: categoryId,
        limitAmount: limitAmount,
        month: month,
      );
      _budgets.add(newBudget);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBudget({
    required String budgetId,
    required double limitAmount,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await budgetRepository.updateBudget(
        budgetId: budgetId,
        limitAmount: limitAmount,
      );
      final index = _budgets.indexWhere((b) => b.id == budgetId);
      if (index != -1) {
        _budgets[index] = updated;
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

  Future<bool> deleteBudget(String budgetId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await budgetRepository.deleteBudget(budgetId);
      _budgets.removeWhere((b) => b.id == budgetId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
