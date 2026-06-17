import 'package:json_annotation/json_annotation.dart';

part 'saving_goal_model.g.dart';

@JsonSerializable()
class SavingGoal {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavingGoal({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressPercentage =>
      (currentAmount / targetAmount * 100).clamp(0, 100);

  factory SavingGoal.fromJson(Map<String, dynamic> json) =>
      _$SavingGoalFromJson(json);
  Map<String, dynamic> toJson() => _$SavingGoalToJson(this);
}
