import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

enum TransactionType { income, expense }

@JsonSerializable()
class TransactionModel {
  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  @JsonKey(fromJson: _transactionTypeFromJson, toJson: _transactionTypeToJson)
  final TransactionType type;
  final String? description;
  final DateTime date;
  final String? receiptUrl;
  final List<String>? tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.type,
    this.description,
    required this.date,
    this.receiptUrl,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  String get category {
    const categoryMap = {
      'cat-1': 'Makanan & Minuman',
      'cat-2': 'Transportasi',
      'cat-3': 'Hiburan',
      'cat-4': 'Kesehatan',
      'cat-5': 'Gaji',
      'cat-6': 'Bonus',
    };
    return categoryMap[categoryId] ?? categoryId;
  }
}

TransactionType _transactionTypeFromJson(String? value) {
  return TransactionType.values.firstWhere(
    (e) => e.toString().split('.').last == value,
    orElse: () => TransactionType.expense,
  );
}

String _transactionTypeToJson(TransactionType type) {
  return type.toString().split('.').last;
}
