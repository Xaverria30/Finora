import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_theme.dart';
import '../../services/validators.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../models/budget_model.dart';
import '../../l10n/app_localizations.dart';

class AddBudgetScreen extends StatefulWidget {
  final Budget? budget;
  const AddBudgetScreen({super.key, this.budget});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  String _selectedCategory = '';
  late String _selectedMonth;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.budget?.limitAmount != null
          ? (widget.budget!.limitAmount % 1 == 0
                ? widget.budget!.limitAmount.toInt().toString()
                : widget.budget!.limitAmount.toString())
          : '',
    );
    // Set current month in YYYY-MM format
    final now = DateTime.now();
    _selectedMonth =
        widget.budget?.month ??
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
    _selectedCategory = widget.budget?.categoryId ?? '';

    Future.microtask(() {
      context.read<CategoryViewModel>().loadCategories();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.budget != null
              ? AppLocalizations.of(context).translate('edit_budget_amount')
              : AppLocalizations.of(context).translate('create_budget'),
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
                AppLocalizations.of(context).translate('category'),
                style: AppTextStyles.label,
              ),
              const SizedBox(height: AppSpacing.sm),
              Consumer<CategoryViewModel>(
                builder: (context, categoryVM, _) {
                  final categories = categoryVM.expenseCategories;

                  if (_selectedCategory.isEmpty && categories.isNotEmpty) {
                    Future.microtask(
                      () =>
                          setState(() => _selectedCategory = categories[0].id),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    value:
                        _selectedCategory.isNotEmpty &&
                            categories.any((c) => c.id == _selectedCategory)
                        ? _selectedCategory
                        : null,
                    items: categories
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat.id,
                            child: Text(
                              AppLocalizations.getCategoryName(
                                context,
                                cat.name,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: widget.budget != null
                        ? null
                        : (value) =>
                              setState(() => _selectedCategory = value ?? ''),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(
                        context,
                      ).translate('select_expense_category'),
                      prefixIcon: const Icon(Icons.category_outlined),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? AppLocalizations.of(
                            context,
                          ).translate('category_error')
                        : null,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppLocalizations.of(context).translate('monthly_budget'),
                style: AppTextStyles.label,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(
                    context,
                  ).translate('amount_hint'),
                  prefixIcon: const Icon(Icons.attach_money_outlined),
                  prefixText: 'Rp ',
                  helperText: AppLocalizations.of(
                    context,
                  ).translate('enter_budget_helper'),
                ),
                validator: Validators.validateAmount,
              ),
              const SizedBox(height: AppSpacing.xl),
              Consumer<BudgetViewModel>(
                builder: (context, budgetVM, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: budgetVM.isLoading || _selectedCategory.isEmpty
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _submitForm(context, budgetVM);
                              }
                            },
                      child: budgetVM.isLoading
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
                              widget.budget != null
                                  ? AppLocalizations.of(
                                      context,
                                    ).translate('update')
                                  : AppLocalizations.of(
                                      context,
                                    ).translate('save'),
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

  void _submitForm(BuildContext context, BudgetViewModel budgetVM) async {
    final success = widget.budget != null
        ? await budgetVM.updateBudget(
            budgetId: widget.budget!.id,
            limitAmount: double.parse(_amountController.text),
          )
        : await budgetVM.createBudget(
            categoryId: _selectedCategory,
            limitAmount: double.parse(_amountController.text),
            month: _selectedMonth,
          );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    }
  }
}
