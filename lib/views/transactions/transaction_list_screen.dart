import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../utils/formatters.dart';
import 'add_transaction_screen.dart';
import '../../l10n/app_localizations.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  late TextEditingController _searchController;
  String _selectedType = 'all';
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    Future.microtask(() {
      context.read<TransactionViewModel>().loadTransactions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('transactions'),
          style: TextStyle(
            color: Theme.of(context).textTheme.headlineMedium?.color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<TransactionViewModel>(
        builder: (context, transactionVM, _) {
          if (transactionVM.isLoading && transactionVM.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFFF8F9FA)
                            : const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).translate('search_transactions_hint'),
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildFilterPill('all', AppLocalizations.of(context).translate('all')),
                          const SizedBox(width: 10),
                          _buildFilterPill('income', AppLocalizations.of(context).translate('income')),
                          const SizedBox(width: 10),
                          _buildFilterPill('expense', AppLocalizations.of(context).translate('expense')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: transactionVM.transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: AppColors.onSurface.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Belum ada transaksi',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildTransactionList(context, transactionVM),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        tooltip: 'Tambah Transaksi',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    TransactionViewModel transactionVM,
  ) {
    // Filter transactions
    final filteredTransactions = transactionVM.transactions.where((t) {
      final matchesSearch =
          _searchController.text.isEmpty ||
          (t.description ?? '')
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
      final matchesType =
          _selectedType == 'all' ||
          (_selectedType == 'income' && t.type == TransactionType.income) ||
          (_selectedType == 'expense' && t.type == TransactionType.expense);
      return matchesSearch && matchesType;
    }).toList();

    // Group by date
    final Map<String, List<TransactionModel>> grouped = {};
    for (var t in filteredTransactions) {
      final dateKey = Formatters.formatDate(t.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(t);
    }

    final dateKeys = grouped.keys.toList();

    if (filteredTransactions.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).translate('no_transactions_found'),
          style: TextStyle(color: Colors.grey.shade400),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      itemCount: dateKeys.length,
      itemBuilder: (context, index) {
        final date = dateKeys[index];
        final transactions = grouped[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 16, bottom: 8),
              child: Text(
                date,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ...transactions
                .map((t) => _buildTransactionCard(context, t, transactionVM))
                .toList(),
          ],
        );
      },
    );
  }

  Widget _buildFilterPill(String type, String label) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    TransactionModel transaction,
    TransactionViewModel transactionVM,
  ) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? const Color(0xFF4DB6AC) : const Color(0xFFE93188);
    final iconBgColor = isIncome ? const Color(0xFFE0F2F1) : const Color(0xFFFCE4EC);
    final iconColor = isIncome ? const Color(0xFF4DB6AC) : const Color(0xFFE93188);
    final statusColor = isIncome ? const Color(0xFFE0F2F1) : const Color(0xFFFCE4EC);
    final statusText = isIncome 
        ? AppLocalizations.of(context).translate('income') 
        : AppLocalizations.of(context).translate('expense');

    // Format currency
    final formattedAmount = '${isIncome ? '+' : '-'}Rp${transaction.amount.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30), // Match the original design's very rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) =>
                  _buildTransactionDetail(transaction, transactionVM),
            );
          },
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isIncome ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description ?? 'Transaction',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.light
                                  ? const Color(0xFFF8F9FA)
                                  : const Color(0xFF2C2C2C),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              AppLocalizations.getCategoryName(context, transaction.category),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedAmount,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: amountColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionDetail(
    TransactionModel transaction,
    TransactionViewModel transactionVM,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context).translate('transaction_detail'), style: AppTextStyles.headline),
          const SizedBox(height: AppSpacing.lg),
          _buildDetailRow(AppLocalizations.of(context).translate('description'), transaction.description ?? 'N/A'),
          _buildDetailRow(AppLocalizations.of(context).translate('category'), AppLocalizations.getCategoryName(context, transaction.category)),
          _buildDetailRow(
            AppLocalizations.of(context).translate('amount'),
            'Rp${transaction.amount.toStringAsFixed(0)}',
          ),
          _buildDetailRow(AppLocalizations.of(context).translate('date'), transaction.date.toString()),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context).translate('close')),
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
                        title: Text(AppLocalizations.of(context).translate('delete_transaction_confirm_title')),
                        content: Text(AppLocalizations.of(context).translate('delete_transaction_confirm_message')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(AppLocalizations.of(context).translate('cancel')),
                          ),
                          TextButton(
                            onPressed: () async {
                              final success = await transactionVM.deleteTransaction(transaction.id);
                              if (success && context.mounted) {
                                context.read<BudgetViewModel>().loadBudgets();
                                context.read<DashboardViewModel>().loadDashboardData();
                              }
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
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
                  icon: const Icon(Icons.delete_outline),
                  label: Text(AppLocalizations.of(context).translate('delete')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddTransactionScreen(transaction: transaction),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined),
              label: Text(AppLocalizations.of(context).translate('edit_transaction')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
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
              color: AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(value, style: AppTextStyles.label),
        ],
      ),
    );
  }
}
