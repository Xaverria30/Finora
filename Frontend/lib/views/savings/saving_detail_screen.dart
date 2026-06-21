import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';
import '../../models/saving_goal_model.dart';
import '../../viewmodels/saving_viewmodel.dart';
import '../../l10n/app_localizations.dart';
import 'add_saving_screen.dart';

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
    _contributionController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _submitContribution(BuildContext context, SavingViewModel savingVM) async {
    if (_contributionController.text.isEmpty) return;
    final amount = double.tryParse(_contributionController.text);
    if (amount == null || amount <= 0) return;

    final success = await savingVM.addContribution(
      goalId: widget.goal.id,
      amount: amount,
      description: AppLocalizations.of(context).translate('manual_contribution'),
    );

    if (!mounted) return;

    if (success) {
      _contributionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('contribution_success'),
          ),
        ),
      );
      Navigator.pop(context);
    }
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
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('savings_title')), elevation: 0),
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
                              AppLocalizations.of(context).translate('target_amount'),
                              style: AppTextStyles.body.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                              AppLocalizations.of(context).translate('collected'),
                              style: AppTextStyles.body.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                        backgroundColor: Theme.of(context).brightness == Brightness.light
                            ? AppColors.surfaceVariant
                            : Colors.white.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: Text(
                        '${(progress * 100).toStringAsFixed(1)}% ${AppLocalizations.of(context).translate('reached')}',
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
              title: AppLocalizations.of(context).translate('remaining_target'),
              value: 'Rp${remaining.toStringAsFixed(0)}',
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInfoCard(
              icon: Icons.event_outlined,
              title: AppLocalizations.of(context).translate('target_date'),
              value:
                  widget.goal.deadline?.toString().split(' ')[0] ??
                  AppLocalizations.of(context).translate('not_set'),
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInfoCard(
              icon: Icons.schedule_outlined,
              title: AppLocalizations.of(context).translate('remaining_days'),
              value: daysLeft > 0
                  ? '$daysLeft ${AppLocalizations.of(context).translate('days')}'
                  : AppLocalizations.of(context).translate('expired'),
              color: daysLeft > 0 ? AppColors.primary : AppColors.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(AppLocalizations.of(context).translate('add_contribution'), style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _contributionController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                final savingVM = context.read<SavingViewModel>();
                _submitContribution(context, savingVM);
              },
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate('additional_amount'),
                prefixIcon: const Icon(Icons.attach_money_outlined),
                prefixText: 'Rp ',
                suffixIcon: Consumer<SavingViewModel>(
                  builder: (context, savingVM, _) {
                    return IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _contributionController.text.isEmpty
                          ? null
                          : () => _submitContribution(context, savingVM),
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
                          title: Text(AppLocalizations.of(context).translate('delete_target_confirm_title')),
                          content: Text(
                            AppLocalizations.of(context).translate('delete_target_confirm_message').replaceAll('{name}', widget.goal.name),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(AppLocalizations.of(context).translate('cancel')),
                            ),
                            TextButton(
                              onPressed: () {
                                savingVM.deleteSavingGoal(widget.goal.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(context).translate('saving_deleted'),
                                    ),
                                  ),
                                );
                                Navigator.pop(context);
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
                    icon: const Icon(Icons.delete_outline),
                    label: Text(AppLocalizations.of(context).translate('delete_target_confirm_title')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddSavingScreen(goal: widget.goal),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: Text(AppLocalizations.of(context).translate('edit_target')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
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
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
