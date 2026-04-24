import '../models/transaction_model.dart';
import '../services/api_service.dart';

class TransactionRepository {
  final ApiService apiService;

  TransactionRepository({required this.apiService});

  Future<List<TransactionModel>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    String? categoryId,
    String? startDate,
    String? endDate,
    String? search,
  }) async {
    final data = await apiService.getTransactions(
      page: page,
      limit: limit,
      type: type,
      categoryId: categoryId,
      startDate: startDate,
      endDate: endDate,
      search: search,
    );

    final transactions = (data['data'] as List?)
        ?.map<TransactionModel>(
          (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();

    return transactions ?? [];
  }

  Future<TransactionModel> getTransactionDetail(String transactionId) async {
    final data = await apiService.getTransactionDetail(transactionId);
    return TransactionModel.fromJson(data);
  }

  Future<TransactionModel> createTransaction({
    required String categoryId,
    required double amount,
    required String type,
    required String description,
    required String date,
    List<String>? tags,
  }) async {
    final data = await apiService.createTransaction(
      categoryId: categoryId,
      amount: amount,
      type: type,
      description: description,
      date: date,
      tags: tags,
    );
    return TransactionModel.fromJson(data);
  }

  Future<TransactionModel> updateTransaction({
    required String transactionId,
    required String categoryId,
    required double amount,
    required String description,
    required String date,
  }) async {
    final data = await apiService.updateTransaction(
      transactionId: transactionId,
      categoryId: categoryId,
      amount: amount,
      description: description,
      date: date,
    );
    return TransactionModel.fromJson(data);
  }

  Future<void> deleteTransaction(String transactionId) async {
    await apiService.deleteTransaction(transactionId);
  }
}
