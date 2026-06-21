import '../models/saving_goal_model.dart';
import '../services/api_service.dart';

class SavingGoalRepository {
  final ApiService apiService;

  SavingGoalRepository({required this.apiService});

  Future<List<SavingGoal>> getSavingGoals() async {
    final data = await apiService.getSavingGoals();
    return data.map<SavingGoal>((json) => SavingGoal.fromJson(json)).toList();
  }

  Future<SavingGoal> getSavingGoalDetail(String goalId) async {
    final data = await apiService.getSavingGoalDetail(goalId);
    return SavingGoal.fromJson(data);
  }

  Future<SavingGoal> createSavingGoal({
    required String name,
    required String? description,
    required double targetAmount,
    required String deadline,
    double currentAmount = 0.0,
  }) async {
    final data = await apiService.createSavingGoal(
      name: name,
      description: description,
      targetAmount: targetAmount,
      deadline: deadline,
      currentAmount: currentAmount,
    );
    return SavingGoal.fromJson(data);
  }

  Future<SavingGoal> addContribution({
    required String goalId,
    required double amount,
    required String description,
  }) async {
    final data = await apiService.addContribution(
      goalId: goalId,
      amount: amount,
      description: description,
    );
    return SavingGoal.fromJson(data);
  }

  Future<SavingGoal> updateSavingGoal({
    required String goalId,
    required double targetAmount,
    required String deadline,
    double currentAmount = 0.0,
  }) async {
    final data = await apiService.updateSavingGoal(
      goalId: goalId,
      targetAmount: targetAmount,
      deadline: deadline,
      currentAmount: currentAmount,
    );
    return SavingGoal.fromJson(data);
  }

  Future<void> deleteSavingGoal(String goalId) async {
    await apiService.deleteSavingGoal(goalId);
  }
}
