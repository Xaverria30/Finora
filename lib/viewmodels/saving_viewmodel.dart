import 'package:flutter/foundation.dart';
import '../models/saving_goal_model.dart';
import '../repositories/saving_goal_repository.dart';

class SavingViewModel extends ChangeNotifier {
  final SavingGoalRepository savingGoalRepository;

  List<SavingGoal> _savingGoals = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SavingGoal> get savingGoals => _savingGoals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SavingViewModel({required this.savingGoalRepository});

  Future<void> loadSavingGoals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _savingGoals = await savingGoalRepository.getSavingGoals();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSavingGoal({
    required String name,
    required String? description,
    required double targetAmount,
    required String deadline,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newGoal = await savingGoalRepository.createSavingGoal(
        name: name,
        description: description,
        targetAmount: targetAmount,
        deadline: deadline,
      );
      _savingGoals.add(newGoal);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addContribution({
    required String goalId,
    required double amount,
    required String description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await savingGoalRepository.addContribution(
        goalId: goalId,
        amount: amount,
        description: description,
      );
      final index = _savingGoals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        _savingGoals[index] = updated;
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

  Future<bool> updateSavingGoal({
    required String goalId,
    required double targetAmount,
    required String deadline,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await savingGoalRepository.updateSavingGoal(
        goalId: goalId,
        targetAmount: targetAmount,
        deadline: deadline,
      );
      final index = _savingGoals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        _savingGoals[index] = updated;
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

  Future<bool> deleteSavingGoal(String goalId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await savingGoalRepository.deleteSavingGoal(goalId);
      _savingGoals.removeWhere((g) => g.id == goalId);
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
