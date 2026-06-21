import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository transactionRepository;

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  final int _limit = 20;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TransactionViewModel({required this.transactionRepository});

  Future<void> loadTransactions({
    int page = 1,
    String? type,
    String? categoryId,
    String? search,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await transactionRepository.getTransactions(
        page: page,
        limit: _limit,
        type: type,
        categoryId: categoryId,
        search: search,
      );
      _currentPage = page;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction({
    required String categoryId,
    required double amount,
    required String type,
    required String description,
    required String date,
    List<String>? tags,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newTransaction = await transactionRepository.createTransaction(
        categoryId: categoryId,
        amount: amount,
        type: type,
        description: description,
        date: date,
        tags: tags,
      );
      _transactions.insert(0, newTransaction);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTransaction({
    required String transactionId,
    required String categoryId,
    required double amount,
    required String description,
    required String date,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await transactionRepository.updateTransaction(
        transactionId: transactionId,
        categoryId: categoryId,
        amount: amount,
        description: description,
        date: date,
      );
      final index = _transactions.indexWhere((t) => t.id == transactionId);
      if (index != -1) {
        _transactions[index] = updated;
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

  Future<bool> deleteTransaction(String transactionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await transactionRepository.deleteTransaction(transactionId);
      _transactions.removeWhere((t) => t.id == transactionId);
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
