import '../models/category_model.dart';
import '../services/api_service.dart';

class CategoryRepository {
  final ApiService apiService;

  CategoryRepository({required this.apiService});

  Future<List<Category>> getCategories({String? type}) async {
    final data = await apiService.getCategories(type: type);
    return data.map<Category>((json) => Category.fromJson(json)).toList();
  }

  Future<Category> createCategory({
    required String name,
    required String? icon,
    required String? color,
    required String type,
  }) async {
    final data = await apiService.createCategory(
      name: name,
      icon: icon,
      color: color,
      type: type,
    );
    return Category.fromJson(data);
  }

  Future<Category> updateCategory({
    required String categoryId,
    required String name,
    required String? color,
  }) async {
    final data = await apiService.updateCategory(
      categoryId: categoryId,
      name: name,
      color: color,
    );
    return Category.fromJson(data);
  }

  Future<void> deleteCategory(String categoryId) async {
    await apiService.deleteCategory(categoryId);
  }
}
