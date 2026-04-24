import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  late TextEditingController _searchController;
  String _selectedType = 'Semua';
  String _selectedCategory = 'Semua';

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
        title: const Text(
          'Transaksi',
          style: TextStyle(
            color: Color(0xFF1A1C1E),
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
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari transaksi...',
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
                          _buildFilterPill('Semua'),
                          const SizedBox(width: 10),
                          _buildFilterPill('Pemasukan'),
                          const SizedBox(width: 10),
                          _buildFilterPill('Pengeluaran'),
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
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        itemCount: transactionVM.transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactionVM.transactions[index];

                          if (_searchController.text.isNotEmpty &&
                              !(transaction.description ?? '')
                                  .toLowerCase()
                                  .contains(
                                    _searchController.text.toLowerCase(),
                                  )) {
                            return const SizedBox.shrink();
                          }

                          return _buildTransactionCard(
                            context,
                            transaction,
                            transactionVM,
                          );
                        },
                      ),
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

  Widget _buildFilterPill(String label) {
    final isSelected = _selectedType == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE93188) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 14,
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
    final statusText = isIncome ? 'Masuk' : 'Keluar';

    // Format currency
    final formattedAmount = '${isIncome ? '+' : '-'}Rp${transaction.amount.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1C1E),
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
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              transaction.category,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            transaction.date.toString().split(' ')[0],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
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
          Text('Detail Transaksi', style: AppTextStyles.headline),
          const SizedBox(height: AppSpacing.lg),
          _buildDetailRow('Deskripsi', transaction.description ?? 'N/A'),
          _buildDetailRow('Kategori', transaction.category),
          _buildDetailRow(
            'Jumlah',
            'Rp${transaction.amount.toStringAsFixed(0)}',
          ),
          _buildDetailRow('Tanggal', transaction.date.toString()),
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
                        title: const Text('Hapus Transaksi?'),
                        content: const Text(
                          'Apakah Anda yakin ingin menghapus transaksi ini?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              transactionVM.deleteTransaction(transaction.id);
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
              color: AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(value, style: AppTextStyles.label),
        ],
      ),
    );
  }
}
