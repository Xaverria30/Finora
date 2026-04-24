import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';
import '../../services/validators.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../viewmodels/notification_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../widgets/auth_components.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

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
    _descriptionController = TextEditingController();
    _amountController = TextEditingController();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.onBackground,
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
                  child: AuthTabControl(
                    isLogin: _selectedType == 'income',
                    onToggle: (val) {
                      setState(() {
                        _selectedType = val ? 'income' : 'expense';
                        _selectedCategory = ''; // Fix: Reset category on switch
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildFieldLabel('Deskripsi'),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Beli makanan, gaji, dll',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: Validators.validateNotEmpty,
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildFieldLabel('Kategori'),
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
                    value: _selectedCategory.isNotEmpty &&
                            categories.any((c) => c.id == _selectedCategory)
                        ? _selectedCategory
                        : null,
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value ?? ''),
                    decoration: const InputDecoration(
                      hintText: 'Pilih kategori',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Kategori harus dipilih'
                        : null,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildFieldLabel('Jumlah'),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                decoration: const InputDecoration(
                  hintText: '0',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  prefixText: 'Rp ',
                  prefixStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                validator: Validators.validateAmount,
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildFieldLabel('Tanggal'),
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
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: AppColors.onBackground,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate.toString().split(' ')[0],
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              Consumer<TransactionViewModel>(
                builder: (context, transactionVM, _) {
                  return GradientButton(
                    text: 'Simpan Transaksi',
                    icon: Icons.check_circle_outline_rounded,
                    isLoading: transactionVM.isLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _selectedCategory.isNotEmpty) {
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
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _submitForm(BuildContext context, TransactionViewModel transactionVM) async {
    final success = await transactionVM.addTransaction(
      categoryId: _selectedCategory,
      amount: double.parse(_amountController.text),
      type: _selectedType,
      description: _descriptionController.text,
      date: _selectedDate.toString().split(' ')[0],
    );

    if (!mounted) return;

    if (success) {
      context.read<NotificationViewModel>().showTransactionSuccess('created');
      Navigator.pop(context);
    }
  }
}

