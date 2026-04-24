import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_theme.dart';
import '../../services/validators.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

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
    _amountController = TextEditingController();
    // Set current month in YYYY-MM format
    final now = DateTime.now();
    _selectedMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
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
      appBar: AppBar(title: const Text('Buat Anggaran'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kategori', style: AppTextStyles.label),
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
                    value: _selectedCategory.isNotEmpty
                        ? _selectedCategory
                        : null,
                    items: categories
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value ?? ''),
                    decoration: const InputDecoration(
                      hintText: 'Pilih kategori pengeluaran',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Kategori harus dipilih'
                        : null,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Anggaran Bulanan', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: '0',
                  prefixIcon: Icon(Icons.attach_money_outlined),
                  prefixText: 'Rp ',
                  helperText: 'Masukkan jumlah anggaran untuk bulan ini',
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
                          : const Text('Buat Anggaran'),
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
    final success = await budgetVM.createBudget(
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
