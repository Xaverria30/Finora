import 'package:json_annotation/json_annotation.dart';

part 'budget_model.g.dart';

@JsonSerializable()
class Budget {
  final String id;
  final String userId;
  final String categoryId;
  final String categoryName;
  final double limitAmount;
  final double spent;
  final String month;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    required this.limitAmount,
    required this.spent,
    required this.month,
    required this.createdAt,
    required this.updatedAt,
  });

  double get remaining => (limitAmount - spent).clamp(0, double.infinity);
  double get percentage => (spent / limitAmount * 100).clamp(0, 100);
  bool get isExceeded => spent > limitAmount;

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetToJson(this);
}
