import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';
import '../../models/category_model.dart';
import '../../services/validators.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../l10n/app_localizations.dart';

class AddCategoryScreen extends StatefulWidget {
  final Category? category;
  final String? initialType;

  const AddCategoryScreen({super.key, this.category, this.initialType});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedType;
  Color _selectedColor = AppColors.primary;
  String? _selectedIcon;

  final List<Color> _colors = [
    AppColors.primary,
    AppColors.success,
    AppColors.error,
    const Color(0xFFFF6F00),
    const Color(0xFF7C3AED),
    const Color(0xFF06B6D4),
    const Color(0xFFEC4899),
    const Color(0xFFFCD34D),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedType = widget.initialType ?? 'expense';

    if (widget.category != null) {
      _selectedType = widget.category!.type.toString().split('.').last;
      _selectedIcon = widget.category!.icon;
      if (widget.category!.color != null) {
        try {
          _selectedColor = Color(
            int.parse('FF${widget.category!.color}', radix: 16),
          );
        } catch (e) {
          _selectedColor = AppColors.primary;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? AppLocalizations.of(context).translate('edit_category')
              : AppLocalizations.of(context).translate('add_category'),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('category_type'),
                style: AppTextStyles.label,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      label: AppLocalizations.of(context).translate('income'),
                      value: 'income',
                      isSelected: _selectedType == 'income',
                      onPressed: () => setState(() => _selectedType = 'income'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildTypeButton(
                      label: AppLocalizations.of(context).translate('expense'),
                      value: 'expense',
                      isSelected: _selectedType == 'expense',
                      onPressed: () =>
                          setState(() => _selectedType = 'expense'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppLocalizations.of(context).translate('category_name'),
                style: AppTextStyles.label,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(
                    context,
                  ).translate('category_name_hint'),
                  prefixIcon: Icon(Icons.label_outlined),
                ),
                validator: Validators.validateNotEmpty,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppLocalizations.of(context).translate('category_color'),
                style: AppTextStyles.label,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: _colors.map((color) {
                  final isSelected = _selectedColor.value == color.value;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              Consumer<CategoryViewModel>(
                builder: (context, categoryVM, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: categoryVM.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _submitForm(context, categoryVM, isEditing);
                              }
                            },
                      child: categoryVM.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              isEditing
                                  ? AppLocalizations.of(
                                      context,
                                    ).translate('update_category')
                                  : AppLocalizations.of(
                                      context,
                                    ).translate('save_category'),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? AppColors.primary
            : (Theme.of(context).brightness == Brightness.light
                  ? AppColors.surface
                  : const Color(0xFF2C2C2C)),
        foregroundColor: isSelected
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface,
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Text(label),
      ),
    );
  }

  void _submitForm(
    BuildContext context,
    CategoryViewModel categoryVM,
    bool isEditing,
  ) async {
    final success = isEditing
        ? await categoryVM.updateCategory(
            categoryId: widget.category!.id,
            name: _nameController.text,
            color: _selectedColor.value.toRadixString(16),
          )
        : await categoryVM.createCategory(
            name: _nameController.text,
            type: _selectedType,
            icon: _selectedIcon,
            color: _selectedColor.value.toRadixString(16),
          );

    if (!mounted) return;

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate(
              isEditing ? 'category_updated_success' : 'category_saved_success',
            ),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }
}
