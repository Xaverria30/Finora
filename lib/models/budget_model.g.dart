// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Budget _$BudgetFromJson(Map<String, dynamic> json) => Budget(
  id: json['id'] as String,
  userId: json['userId'] as String,
  categoryId: json['categoryId'] as String,
  categoryName: json['categoryName'] as String,
  limitAmount: (json['limitAmount'] as num).toDouble(),
  spent: (json['spent'] as num).toDouble(),
  month: json['month'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BudgetToJson(Budget instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'categoryId': instance.categoryId,
  'categoryName': instance.categoryName,
  'limitAmount': instance.limitAmount,
  'spent': instance.spent,
  'month': instance.month,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
