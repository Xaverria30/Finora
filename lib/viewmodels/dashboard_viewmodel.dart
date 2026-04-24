import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final TransactionRepository transactionRepository;

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _summary = {};
  Map<String, dynamic> _analytics = {};
  List<TransactionModel> _recentTransactions = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get summary => _summary;
  Map<String, dynamic> get analytics => _analytics;
  List<TransactionModel> get recentTransactions => _recentTransactions;

  DashboardViewModel({required this.transactionRepository});

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final transactions = await transactionRepository.getTransactions();

      double totalIncome = 0;
      double totalExpense = 0;
      final categoryExpenses = <String, double>{};

      for (final transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          totalIncome += transaction.amount;
        } else if (transaction.type == TransactionType.expense) {
          totalExpense += transaction.amount;
          final desc = transaction.description ?? 'Other';
          categoryExpenses.update(
            desc,
            (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount,
          );
        }
      }

      final balance = totalIncome - totalExpense;
      final netCashFlow = totalIncome - totalExpense;

      _summary = {
        'balance': balance,
        'income': totalIncome,
        'expense': totalExpense,
        'netCashFlow': netCashFlow,
      };

      _analytics = {
        'categoryExpenses': categoryExpenses.entries
            .map((e) => {'category': e.key, 'amount': e.value})
            .toList(),
      };

      _recentTransactions = transactions.take(5).toList();
    } catch (e) {
      _errorMessage = 'Failed to load dashboard data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
