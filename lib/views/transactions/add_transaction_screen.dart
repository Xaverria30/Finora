import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transaction_model.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';
import '../../services/validators.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/notification_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/auth_components.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;
  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;

  String _selectedType = 'income';
  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.transaction?.description ?? '',
    );
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    if (widget.transaction != null) {
      _selectedType = widget.transaction!.type.name;
      _selectedCategory = widget.transaction!.categoryId ?? '';
      _selectedDate = widget.transaction!.date;
    }
    Future.microtask(() {
      context.read<CategoryViewModel>().loadCategories();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.transaction != null
              ? AppLocalizations.of(context).translate('edit_transaction')
              : AppLocalizations.of(context).translate('add_transaction'),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),

              // Transaction Type Selector
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: widget.transaction != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedType == 'income'
                                ? (Theme.of(context).brightness ==
                                          Brightness.light
                                      ? const Color(0xFFE0F2F1)
                                      : const Color(
                                          0xFF4DB6AC,
                                        ).withOpacity(0.2))
                                : (Theme.of(context).brightness ==
                                          Brightness.light
                                      ? const Color(0xFFFCE4EC)
                                      : const Color(
                                          0xFFE93188,
                                        ).withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            _selectedType == 'income'
                                ? AppLocalizations.of(
                                    context,
                                  ).translate('income')
                                : AppLocalizations.of(
                                    context,
                                  ).translate('expense'),
                            style: TextStyle(
                              color: _selectedType == 'income'
                                  ? const Color(0xFF4DB6AC)
                                  : const Color(0xFFE93188),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : AuthTabControl(
                          isLogin: _selectedType == 'income',
                          leftLabel: AppLocalizations.of(
                            context,
                          ).translate('income'),
                          rightLabel: AppLocalizations.of(
                            context,
                          ).translate('expense'),
                          onToggle: (isIncome) {
                            setState(() {
                              _selectedType = isIncome ? 'income' : 'expense';
                              _selectedCategory =
                                  ''; // Reset category when type changes
                            });
                          },
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildFieldLabel(
                AppLocalizations.of(context).translate('description'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(
                    context,
                  ).translate('description_hint'),
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                validator: Validators.validateNotEmpty,
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildFieldLabel(
                AppLocalizations.of(context).translate('category'),
              ),
              Consumer<CategoryViewModel>(
                builder: (context, categoryVM, _) {
                  final categories = _selectedType == 'income'
                      ? categoryVM.incomeCategories
                      : categoryVM.expenseCategories;

                  if (_selectedCategory.isEmpty && categories.isNotEmpty) {
                    Future.microtask(() {
                      if (mounted) {
                        setState(() => _selectedCategory = categories[0].id);
                      }
                    });
                  }

                  return DropdownButtonFormField<String>(
                    value:
                        _selectedCategory.isNotEmpty &&
                            categories.any((c) => c.id == _selectedCategory)
                        ? _selectedCategory
                        : null,
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Text(
                          AppLocalizations.getCategoryName(context, cat.name),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value ?? ''),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(
                        context,
                      ).translate('category'),
                      prefixIcon: const Icon(Icons.category_outlined),
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

              _buildFieldLabel(
                AppLocalizations.of(context).translate('amount'),
              ),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(
                    context,
                  ).translate('amount_hint'),
                  prefixIcon: const Icon(Icons.attach_money_outlined),
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                validator: Validators.validateAmount,
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildFieldLabel(AppLocalizations.of(context).translate('date')),
              InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    setState(() => _selectedDate = pickedDate);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.surface
                        : const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate.toString().split(' ')[0],
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              Consumer<TransactionViewModel>(
                builder: (context, transactionVM, _) {
                  return GradientButton(
                    text: widget.transaction != null
                        ? AppLocalizations.of(context).translate('update')
                        : AppLocalizations.of(context).translate('save'),
                    icon: Icons.check_circle_outline_rounded,
                    isLoading: transactionVM.isLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          _selectedCategory.isNotEmpty) {
                        _submitForm(context, transactionVM);
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color:
              Theme.of(context).textTheme.labelLarge?.color ??
              AppColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _submitForm(
    BuildContext context,
    TransactionViewModel transactionVM,
  ) async {
    final success = widget.transaction != null
        ? await transactionVM.updateTransaction(
            transactionId: widget.transaction!.id,
            categoryId: _selectedCategory,
            amount: double.parse(_amountController.text),
            description: _descriptionController.text,
            date: _selectedDate.toString().split(' ')[0],
          )
        : await transactionVM.addTransaction(
            categoryId: _selectedCategory,
            amount: double.parse(_amountController.text),
            type: _selectedType,
            description: _descriptionController.text,
            date: _selectedDate.toString().split(' ')[0],
          );

    if (!mounted) return;

    if (success) {
      context.read<BudgetViewModel>().loadBudgets();
      context.read<DashboardViewModel>().loadDashboardData();
      Navigator.pop(context);
    }
  }
}
