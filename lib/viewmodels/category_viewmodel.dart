import 'package:flutter/foundation.dart';
import '../models/category_model.dart' as category_model;
import '../repositories/category_repository.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository categoryRepository;

  List<category_model.Category> _categories = [];
  List<category_model.Category> _incomeCategories = [];
  List<category_model.Category> _expenseCategories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<category_model.Category> get categories => _categories;
  List<category_model.Category> get incomeCategories => _incomeCategories;
  List<category_model.Category> get expenseCategories => _expenseCategories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CategoryViewModel({required this.categoryRepository});

  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final all = await categoryRepository.getCategories();
      _categories = all;

      // Filter secara lokal untuk memastikan sinkronisasi UI
      _incomeCategories = all
          .where((c) => c.type == category_model.CategoryType.income)
          .toList();
      _expenseCategories = all
          .where((c) => c.type == category_model.CategoryType.expense)
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCategory({
    required String name,
    required String? icon,
    required String? color,
    required String type,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await categoryRepository.createCategory(
        name: name,
        icon: icon,
        color: color,
        type: type,
      );

      // Refresh semua list agar konsisten
      await loadCategories();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCategory({
    required String categoryId,
    required String name,
    required String? color,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await categoryRepository.updateCategory(
        categoryId: categoryId,
        name: name,
        color: color,
      );

      final index = _categories.indexWhere((c) => c.id == categoryId);
      if (index != -1) {
        _categories[index] = updated;
      }

      await loadCategories();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await categoryRepository.deleteCategory(categoryId);
      _categories.removeWhere((c) => c.id == categoryId);
      _incomeCategories.removeWhere((c) => c.id == categoryId);
      _expenseCategories.removeWhere((c) => c.id == categoryId);
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
