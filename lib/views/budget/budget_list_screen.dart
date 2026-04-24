import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';
import '../../models/budget_model.dart';
import '../../models/transaction_model.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import 'add_budget_screen.dart';

class BudgetListScreen extends StatefulWidget {
  const BudgetListScreen({super.key});

  @override
  State<BudgetListScreen> createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends State<BudgetListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BudgetViewModel>().loadBudgets();
      context.read<TransactionViewModel>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      body: Consumer2<BudgetViewModel, TransactionViewModel>(
        builder: (context, budgetVM, transactionVM, _) {
          if (budgetVM.isLoading && budgetVM.budgets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          double totalBudget = 0;
          double totalSpent = 0;

          for (var budget in budgetVM.budgets) {
            totalBudget += (budget.limitAmount as num).toDouble();

            final categoryTransactions = transactionVM.transactions
                .where(
                  (t) =>
                      t.category == budget.categoryName &&
                      t.type == TransactionType.expense,
                )
                .toList();

            for (var tx in categoryTransactions) {
              totalSpent += (tx.amount as num).toDouble();
            }
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            children: [
              const SizedBox(height: 20),
              const Text(
                'Anggaran',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1C1E),
                ),
              ),
              const Text(
                'Kelola pengeluaran bulananmu',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              if (budgetVM.budgets.isNotEmpty)
                _buildSummaryCard(totalBudget, totalSpent),
              const SizedBox(height: AppSpacing.lg),
              if (budgetVM.budgets.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                      ),
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 64,
                        color: AppColors.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Belum ada anggaran',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddBudgetScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Buat Anggaran'),
                      ),
                    ],
                  ),
                )
              else
                ...budgetVM.budgets.map((budget) {
                  final spent = _calculateSpent(budget, transactionVM);
                  final health = budget.limitAmount > 0
                      ? spent / budget.limitAmount.toDouble()
                      : 0.0;

                  return _buildBudgetCard(
                    context,
                    budget,
                    spent,
                    health.toDouble(),
                    budgetVM,
                  );
                }).toList(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBudgetScreen()),
          );
        },
        tooltip: 'Tambah Anggaran',
        child: const Icon(Icons.add),
      ),
    );
  }

  double _calculateSpent(Budget budget, TransactionViewModel transactionVM) {
    final categoryTransactions = transactionVM.transactions
        .where(
          (t) =>
              t.category == budget.categoryName &&
              t.type == TransactionType.expense,
        )
        .toList();

    double spent = 0;
    for (var tx in categoryTransactions) {
      spent += tx.amount;
    }
    return spent;
  }

  Widget _buildSummaryCard(double totalBudget, double totalSpent) {
    final progress = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF960A6), Color(0xFFE93188)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE93188).withOpacity(0.3),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -30,
            top: -10,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Ringkasan Anggaran Bulan Ini',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Anggaran',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp${totalBudget.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Terpakai',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp${totalSpent.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                          style: const TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progres',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(
    BuildContext context,
    Budget budget,
    double spent,
    double health,
    BudgetViewModel budgetVM,
  ) {
    final remaining = budget.limitAmount - spent;
    final progress = (spent / budget.limitAmount).clamp(0.0, 1.0);
    
    // Determine icon and color based on category
    IconData iconData = Icons.category_rounded;
    if (budget.categoryName.toLowerCase().contains('makan')) {
      iconData = Icons.restaurant_rounded;
    } else if (budget.categoryName.toLowerCase().contains('transport')) {
      iconData = Icons.directions_car_rounded;
    } else if (budget.categoryName.toLowerCase().contains('belanja')) {
      iconData = Icons.shopping_bag_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 5),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFFCE4EC),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: const Color(0xFFE93188), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.categoryName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1C1E),
                      ),
                    ),
                    Text(
                      'Rp${budget.limitAmount.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')} / bulan',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle_outline_rounded, color: Color(0xFF4DB6AC), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Aman',
                      style: TextStyle(
                        color: Color(0xFF4DB6AC),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE93188),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TERPAKAI',
                    style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp${spent.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1C1E),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'SISA',
                    style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp${remaining.clamp(0, double.infinity).toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4DB6AC),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetDetail(
    BuildContext context,
    Budget budget,
    double spent,
    double health,
    BudgetViewModel budgetVM,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detail Anggaran', style: AppTextStyles.headline),
          const SizedBox(height: AppSpacing.lg),
          _buildDetailRow('Kategori', budget.categoryName),
          _buildDetailRow(
            'Anggaran',
            'Rp${budget.limitAmount.toStringAsFixed(0)}',
          ),
          _buildDetailRow('Terpakai', 'Rp${spent.toStringAsFixed(0)}'),
          _buildDetailRow(
            'Sisa',
            'Rp${(budget.limitAmount - spent).toStringAsFixed(0)}',
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hapus Anggaran?'),
                        content: const Text(
                          'Apakah Anda yakin ingin menghapus anggaran ini?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              budgetVM.deleteBudget(budget.id);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Hapus',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Hapus'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.onSurface.withOpacity(0.6),
            ),
          ),
          Text(value, style: AppTextStyles.label),
        ],
      ),
    );
  }
}
