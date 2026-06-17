import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../utils/formatters.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/notification_viewmodel.dart';
import '../notifications/notification_list_screen.dart';
import '../../l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int)? onTabChange;
  const DashboardScreen({Key? key, this.onTabChange}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DashboardViewModel>().loadDashboardData();
      context.read<NotificationViewModel>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(viewModel.errorMessage ?? 'Error'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => viewModel.loadDashboardData(),
                    child: Text(
                      AppLocalizations.of(context).translate('retry'),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(viewModel),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 16),
                _buildExpenseDistributionSection(viewModel),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(DashboardViewModel viewModel) {
    final summary = viewModel.summary;
    final balance = (summary['balance'] as num?)?.toDouble() ?? 0.0;
    final income = (summary['income'] as num?)?.toDouble() ?? 0.0;
    final expense = (summary['expense'] as num?)?.toDouble() ?? 0.0;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final user = authViewModel.currentUser;

    return Stack(
      children: [
        Container(
          height: 240,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF960A6), Color(0xFFE93188)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        Positioned(
          top: 50,
          right: 50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          ).translate('welcome_back'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.name ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Consumer<NotificationViewModel>(
                      builder: (context, notificationVM, _) {
                        return Stack(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const NotificationListScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            if (notificationVM.unreadCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFB74D),
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    notificationVM.unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 130,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _buildSummaryCard(
                      title: AppLocalizations.of(context).translate('balance'),
                      amount: balance,
                      amountColor: const Color(0xFFE93188),
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: const Color(0xFFE93188),
                      iconBgColor: const Color(0xFFFCE4EC),
                    ),
                    _buildSummaryCard(
                      title: AppLocalizations.of(context).translate('income'),
                      amount: income,
                      amountColor: const Color(0xFF4DB6AC),
                      icon: Icons.trending_up_rounded,
                      iconColor: const Color(0xFF4DB6AC),
                      iconBgColor: const Color(0xFFE0F2F1),
                    ),
                    _buildSummaryCard(
                      title: AppLocalizations.of(context).translate('expense'),
                      amount: expense,
                      amountColor: const Color(0xFFE57373),
                      icon: Icons.trending_down_rounded,
                      iconColor: const Color(0xFFE57373),
                      iconBgColor: const Color(0xFFFFEBEE),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color amountColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    final formattedAmount = Formatters.formatCurrency(amount);
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedAmount,
            style: TextStyle(
              color: amountColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('quick_actions'),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionIcon(
                icon: Icons.swap_horiz_rounded,
                label: AppLocalizations.of(
                  context,
                ).translate('transactions_count'),
                color: const Color(0xFFE93188),
                bgColor: const Color(0xFFFCE4EC),
                onTap: () =>
                    Navigator.pushNamed(context, '/home', arguments: 1),
              ),
              _buildActionIcon(
                icon: Icons.bar_chart_rounded,
                label: AppLocalizations.of(context).translate('budgets_count'),
                color: const Color(0xFF9575CD),
                bgColor: const Color(0xFFEDE7F6),
                onTap: () =>
                    Navigator.pushNamed(context, '/home', arguments: 2),
              ),
              _buildActionIcon(
                icon: Icons.savings_outlined,
                label: AppLocalizations.of(context).translate('savings_count'),
                color: const Color(0xFF81C784),
                bgColor: const Color(0xFFE8F5E9),
                onTap: () =>
                    Navigator.pushNamed(context, '/home', arguments: 3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color:
                  Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseDistributionSection(DashboardViewModel viewModel) {
    final categoryExpenses = viewModel.analytics['categoryExpenses'] as List?;
    final List<PieChartSectionData> chartData = [];
    final List<Widget> legendItems = [];

    Color parseColor(String? colorStr) {
      if (colorStr == null || colorStr.isEmpty) return const Color(0xFFE93188);
      try {
        final hexColor = colorStr.replaceAll('#', '');
        if (hexColor.length == 6) {
          return Color(int.parse('FF$hexColor', radix: 16));
        } else if (hexColor.length == 8) {
          return Color(int.parse(hexColor, radix: 16));
        }
      } catch (e) {
        debugPrint('Error parsing color: $colorStr');
      }
      return const Color(0xFFE93188);
    }

    if (categoryExpenses == null || categoryExpenses.isEmpty) {
      chartData.add(
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 100,
          title: '',
          radius: 35,
        ),
      );
    } else {
      double total = 0;
      for (var item in categoryExpenses) {
        total += (item['amount'] as num).toDouble();
      }

      for (int i = 0; i < categoryExpenses.length; i++) {
        final item = categoryExpenses[i];
        final amount = (item['amount'] as num).toDouble();
        final categoryName =
            item['categoryName'] ?? item['category'] ?? 'Unknown';
        final color = parseColor(item['categoryColor']);

        chartData.add(
          PieChartSectionData(
            color: color,
            value: total > 0 ? (amount / total) * 100 : 0,
            title: '',
            radius: 35,
          ),
        );

        legendItems.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildLegendItem(
              color: color,
              label: AppLocalizations.getCategoryName(context, categoryName),
              amount: Formatters.formatCurrency(amount),
            ),
          ),
        );
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(
                      context,
                    ).translate('expense_distribution'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (widget.onTabChange != null) {
                        widget.onTabChange!(1);
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context).translate('see_all'),
                      style: const TextStyle(
                        color: Color(0xFFF13E93),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context).translate('this_month'),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFCE4EC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Color(0xFFE93188),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: chartData,
                    centerSpaceRadius: 65,
                    sectionsSpace: 0,
                    startDegreeOffset: -90,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ...legendItems,
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String amount,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          amount,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
