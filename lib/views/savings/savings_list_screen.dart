import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';
import '../../models/saving_goal_model.dart';
import '../../viewmodels/saving_viewmodel.dart';
import 'add_saving_screen.dart';
import 'saving_detail_screen.dart';

class SavingsListScreen extends StatefulWidget {
  const SavingsListScreen({super.key});

  @override
  State<SavingsListScreen> createState() => _SavingsListScreenState();
}

class _SavingsListScreenState extends State<SavingsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SavingViewModel>().loadSavingGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      body: Consumer<SavingViewModel>(
        builder: (context, savingVM, _) {
          if (savingVM.isLoading && savingVM.savingGoals.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            children: [
              const SizedBox(height: 20),
              const Text(
                'Target Tabungan',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1C1E),
                ),
              ),
              const Text(
                'Wujudkan impian finansialmu',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              if (savingVM.savingGoals.isNotEmpty) _buildSummaryCard(savingVM),
              const SizedBox(height: AppSpacing.lg),
              if (savingVM.savingGoals.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                      ),
                      Icon(
                        Icons.savings_outlined,
                        size: 64,
                        color: AppColors.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Belum ada target tabungan',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddSavingScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Buat Target Pertama'),
                      ),
                    ],
                  ),
                )
              else
                ...savingVM.savingGoals.map((goal) {
                  return _buildGoalCard(context, goal, savingVM);
                }).toList(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSavingScreen()),
          );
        },
        tooltip: 'Tambah Target',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(SavingViewModel savingVM) {
    double totalTarget = 0;
    double totalSaved = 0;

    for (var goal in savingVM.savingGoals) {
      totalTarget += goal.targetAmount;
      totalSaved += goal.currentAmount;
    }

    final progress = totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF43A047).withOpacity(0.3),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Stack(
        children: [
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
                    child: const Icon(Icons.savings_outlined, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Ringkasan Tabungan',
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
                          'Target Total',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp${totalTarget.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
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
                          'Terkumpul',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp${totalSaved.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
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
                    'Progres keseluruhan',
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

  Widget _buildGoalCard(
    BuildContext context,
    SavingGoal goal,
    SavingViewModel savingVM,
  ) {
    final progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final remaining = goal.targetAmount - goal.currentAmount;

    // Use name to decide color or just alternate
    final List<Color> colors = [const Color(0xFFF06292), const Color(0xFF7986CB), const Color(0xFF4DB6AC)];
    final color = colors[goal.id.hashCode % colors.length];

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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SavingDetailScreen(goal: goal),
            ),
          );
        },
        borderRadius: BorderRadius.circular(30),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.savings_rounded, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1C1E),
                        ),
                      ),
                      Text(
                        'Target: ${goal.deadline != null ? goal.deadline.toString().split(' ')[0] : 'No deadline'}',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
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
                    color: color,
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
                      'TERKUMPUL',
                      style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp${goal.currentAmount.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4DB6AC),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'SISA TARGET',
                      style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp${remaining.clamp(0, double.infinity).toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE93188),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
