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
      final results = await Future.wait([
        transactionRepository.getTransactions(limit: 5),
        transactionRepository.apiService.getDashboardSummary(),
        transactionRepository.apiService.getExpenseAnalytics(),
      ]);

      final transactions = results[0] as List<TransactionModel>;
      final summaryData = results[1] as Map<String, dynamic>;
      final analyticsData = results[2] as Map<String, dynamic>;

      _summary = {
        'balance': (summaryData['balance'] as num?)?.toDouble() ?? 0.0,
        'income': (summaryData['totalIncome'] as num?)?.toDouble() ?? 0.0,
        'expense': (summaryData['totalExpenses'] as num?)?.toDouble() ?? 0.0,
        'netCashFlow': (summaryData['balance'] as num?)?.toDouble() ?? 0.0,
      };

      _analytics = {'categoryExpenses': analyticsData['data'] ?? []};

      _recentTransactions = transactions;
    } catch (e) {
      _errorMessage = 'Failed to load dashboard data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
