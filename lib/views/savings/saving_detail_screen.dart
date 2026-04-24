import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';
import '../../models/saving_goal_model.dart';
import '../../viewmodels/saving_viewmodel.dart';

class SavingDetailScreen extends StatefulWidget {
  final SavingGoal goal;

  const SavingDetailScreen({super.key, required this.goal});

  @override
  State<SavingDetailScreen> createState() => _SavingDetailScreenState();
}

class _SavingDetailScreenState extends State<SavingDetailScreen> {
  late TextEditingController _contributionController;

  @override
  void initState() {
    super.initState();
    _contributionController = TextEditingController();
  }

  @override
  void dispose() {
    _contributionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.goal.targetAmount > 0
        ? widget.goal.currentAmount / widget.goal.targetAmount
        : 0.0;
    final remaining = widget.goal.targetAmount - widget.goal.currentAmount;
    final daysLeft = widget.goal.deadline != null
        ? widget.goal.deadline!.difference(DateTime.now()).inDays
        : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Target'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.goal.name, style: AppTextStyles.headline),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Target',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Rp${widget.goal.targetAmount.toStringAsFixed(0)}',
                              style: AppTextStyles.headline.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Terkumpul',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Rp${widget.goal.currentAmount.toStringAsFixed(0)}',
                              style: AppTextStyles.headline.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: Text(
                        '${(progress * 100).toStringAsFixed(1)}% tercapai',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildInfoCard(
              icon: Icons.money_off_outlined,
              title: 'Sisa Target',
              value: 'Rp${remaining.toStringAsFixed(0)}',
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInfoCard(
              icon: Icons.event_outlined,
              title: 'Target Tanggal',
              value:
                  widget.goal.deadline?.toString().split(' ')[0] ??
                  'Belum diset',
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInfoCard(
              icon: Icons.schedule_outlined,
              title: 'Sisa Hari',
              value: daysLeft > 0
                  ? '$daysLeft hari'
                  : 'Sudah tercapai/terlewat',
              color: daysLeft > 0 ? AppColors.primary : AppColors.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Tambah Kontribusi', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _contributionController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: 'Jumlah tambahan',
                prefixIcon: const Icon(Icons.attach_money_outlined),
                prefixText: 'Rp ',
                suffixIcon: Consumer<SavingViewModel>(
                  builder: (context, savingVM, _) {
                    return IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _contributionController.text.isEmpty
                          ? null
                          : () async {
                              final amount = double.parse(
                                _contributionController.text,
                              );
                              final success = await savingVM.addContribution(
                                goalId: widget.goal.id,
                                amount: amount,
                                description: 'Kontribusi manual',
                              );

                              if (!mounted) return;

                              if (success) {
                                _contributionController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Kontribusi berhasil ditambahkan',
                                    ),
                                  ),
                                );

                                Navigator.pop(context);
                              }
                            },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Consumer<SavingViewModel>(
              builder: (context, savingVM, _) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Hapus Target?'),
                          content: Text(
                            'Apakah Anda yakin ingin menghapus target "${widget.goal.name}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                savingVM.deleteSavingGoal(widget.goal.id);
                                Navigator.pop(context);
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
                    label: const Text('Hapus Target'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    value,
                    style: AppTextStyles.label.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
