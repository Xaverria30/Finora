import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';
import '../../models/category_model.dart' as category_model;
import '../../viewmodels/category_viewmodel.dart';
import '../../l10n/app_localizations.dart';
import 'add_category_screen.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      context.read<CategoryViewModel>().loadCategories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('category')),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context).translate('income')),
            Tab(text: AppLocalizations.of(context).translate('expense')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Consumer<CategoryViewModel>(
            builder: (context, categoryVM, _) {
              return _buildCategoryList(categoryVM.incomeCategories, context);
            },
          ),
          Consumer<CategoryViewModel>(
            builder: (context, categoryVM, _) {
              return _buildCategoryList(categoryVM.expenseCategories, context);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCategoryScreen(
                initialType: _tabController.index == 0 ? 'income' : 'expense',
              ),
            ),
          );
        },
        tooltip: AppLocalizations.of(context).translate('add_category'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryList(List categories, BuildContext context) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppLocalizations.of(context).translate('no_categories'),
              style: AppTextStyles.body.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.category_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              AppLocalizations.getCategoryName(context, category.name),
              style: AppTextStyles.label,
            ),
            subtitle: Text(
              category.type == category_model.CategoryType.income
                  ? AppLocalizations.of(context).translate('income')
                  : AppLocalizations.of(context).translate('expense'),
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                color: category.type == category_model.CategoryType.income
                    ? AppColors.success
                    : AppColors.error,
              ),
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 20),
                      SizedBox(width: AppSpacing.md),
                      Text(AppLocalizations.of(context).translate('edit')),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddCategoryScreen(category: category),
                      ),
                    );
                  },
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        AppLocalizations.of(context).translate('delete'),
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          AppLocalizations.of(
                            context,
                          ).translate('delete_category_confirm_title'),
                        ),
                        content: Text(
                          AppLocalizations.of(context)
                              .translate('delete_category_confirm_message')
                              .replaceAll('{name}', category.name),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              AppLocalizations.of(context).translate('cancel'),
                              style: AppTextStyles.body.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<CategoryViewModel>().deleteCategory(
                                category.id,
                              );
                              Navigator.pop(context);
                            },
                            child: Text(
                              AppLocalizations.of(context).translate('delete'),
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
