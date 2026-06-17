import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_theme.dart';
import '../../services/validators.dart';
import '../../viewmodels/saving_viewmodel.dart';
import '../../models/saving_goal_model.dart';
import '../../l10n/app_localizations.dart';

class AddSavingScreen extends StatefulWidget {
  final SavingGoal? goal;
  const AddSavingScreen({super.key, this.goal});

  @override
  State<AddSavingScreen> createState() => _AddSavingScreenState();
}

class _AddSavingScreenState extends State<AddSavingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _goalNameController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;

  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));

  @override
  void initState() {
    super.initState();
    _goalNameController = TextEditingController(text: widget.goal?.name ?? '');
    _targetAmountController =
        TextEditingController(text: widget.goal?.targetAmount.toString() ?? '');
    _currentAmountController =
        TextEditingController(text: widget.goal?.currentAmount.toString() ?? '0');
    if (widget.goal?.deadline != null) {
      _targetDate = widget.goal!.deadline!;
    }
  }

  @override
  void dispose() {
    _goalNameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.goal != null
              ? AppLocalizations.of(context).translate('edit_saving_goal')
              : AppLocalizations.of(context).translate('add_saving'),
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
              Text(AppLocalizations.of(context).translate('target_name'), style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _goalNameController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).translate('target_name_hint'),
                  prefixIcon: const Icon(Icons.flag_outlined),
                ),
                readOnly: widget.goal != null,
                validator: Validators.validateNotEmpty,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(AppLocalizations.of(context).translate('target_amount'), style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _targetAmountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).translate('amount_hint'),
                  prefixIcon: const Icon(Icons.attach_money_outlined),
                  prefixText: 'Rp ',
                ),
                validator: Validators.validateAmount,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(AppLocalizations.of(context).translate('already_collected'), style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _currentAmountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: '0',
                  prefixIcon: Icon(Icons.attach_money_outlined),
                  prefixText: 'Rp ',
                ),
                validator: Validators.validateAmount,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(AppLocalizations.of(context).translate('target_date'), style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _targetDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2050),
                  );
                  if (pickedDate != null) {
                    setState(() => _targetDate = pickedDate);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _targetDate.toString().split(' ')[0],
                    style: AppTextStyles.body,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Consumer<SavingViewModel>(
                builder: (context, savingVM, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: savingVM.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _submitForm(context, savingVM);
                              }
                            },
                      child: savingVM.isLoading
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
                              widget.goal != null
                                  ? AppLocalizations.of(context).translate('update')
                                  : AppLocalizations.of(context).translate('save'),
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

  void _submitForm(BuildContext context, SavingViewModel savingVM) async {
    final success = widget.goal != null
        ? await savingVM.updateSavingGoal(
            goalId: widget.goal!.id,
            targetAmount: double.parse(_targetAmountController.text),
            deadline: _targetDate.toString().split(' ')[0],
            currentAmount: double.tryParse(_currentAmountController.text) ?? 0.0,
          )
        : await savingVM.createSavingGoal(
            name: _goalNameController.text,
            description: _goalNameController.text,
            targetAmount: double.parse(_targetAmountController.text),
            deadline: _targetDate.toString().split(' ')[0],
            currentAmount: double.tryParse(_currentAmountController.text) ?? 0.0,
          );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    }
  }
}
