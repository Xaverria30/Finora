import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../utils/formatters.dart';
import '../../viewmodels/dashboard_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DashboardViewModel>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
                    child: const Text('Retry'),
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
    final balance = summary['balance'] as double? ?? 9875000.0;
    final income = summary['income'] as double? ?? 10000000.0;
    final expense = summary['expense'] as double? ?? 125000.0; // Mocked for preview

    return Stack(
      children: [
        // Pink Background Curve
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
        // Overlapping circles for decoration
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Selamat datang kembali',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ), // TextStyle
                        ), // Text
                        SizedBox(height: 4),
                        Text(
                          'Mock User',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ), // TextStyle
                        ), // Text
                      ],
                    ), // Column
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 24,
                      ), // Icon
                    ), // Container
                  ],
                ), // Row
              ), // Padding
              const SizedBox(height: 16),
              // Horizontal scrollable cards
              SizedBox(
                height: 130, // Adjust card height
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _buildSummaryCard(
                      title: 'Saldo',
                      amount: balance,
                      amountColor: const Color(0xFFE93188),
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: const Color(0xFFE93188),
                      iconBgColor: const Color(0xFFFCE4EC),
                    ),
                        _buildSummaryCard(
                      title: 'Pemasukan',
                      amount: income,
                      amountColor: const Color(0xFF4DB6AC),
                      icon: Icons.trending_up_rounded,
                      iconColor: const Color(0xFF4DB6AC),
                      iconBgColor: const Color(0xFFE0F2F1),
                    ),
                    _buildSummaryCard(
                      title: 'Pengeluaran',
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
    // Format currency to Rp string.
    final formattedAmount = 'Rp${amount.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}';
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
            ), // BoxDecoration
            child: Icon(icon, color: iconColor, size: 20),
          ), // Container
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ), // BoxShadow
        ],
      ), // BoxDecoration
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AKSI CEPAT',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ), // TextStyle
          ), // Text
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionIcon(
                icon: Icons.add,
                label: 'Transaksi',
                color: const Color(0xFFE93188),
                bgColor: const Color(0xFFFCE4EC),
              ),
              _buildActionIcon(
                icon: Icons.bar_chart_rounded,
                label: 'Anggaran',
                color: const Color(0xFF9575CD),
                bgColor: const Color(0xFFEDE7F6),
              ),
              _buildActionIcon(
                icon: Icons.savings_outlined,
                label: 'Tabungan',
                color: const Color(0xFF81C784),
                bgColor: const Color(0xFFE8F5E9),
              ),
              _buildActionIcon(
                icon: Icons.track_changes_outlined,
                label: 'Target',
                color: const Color(0xFFFFB74D),
                bgColor: const Color(0xFFFFF3E0),
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
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseDistributionSection(DashboardViewModel viewModel) {
    // Mock data based on the design
    final chartData = [
      PieChartSectionData(
        color: const Color(0xFFE93188),
        value: 60,
        title: '',
        radius: 35,
      ),
      PieChartSectionData(
        color: const Color(0xFFF48FB1),
        value: 40,
        title: '',
        radius: 35,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ), // BoxShadow
        ],
      ), // BoxDecoration
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Distribusi Pengeluaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ), // TextStyle
                  ), // Text
                  SizedBox(height: 4),
                  Text(
                    'Bulan ini',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ), // TextStyle
                  ), // Text
                ],
              ), // Column
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Color(0xFFE93188),
                  size: 20,
                ), // Icon
              ), // Container
            ],
          ), // Row
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
                  ), // PieChartData
                ), // PieChart
              ],
            ), // Stack
          ), // SizedBox