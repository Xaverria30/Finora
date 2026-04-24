import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../viewmodels/saving_viewmodel.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Consumer4<AuthViewModel, TransactionViewModel, BudgetViewModel, SavingViewModel>(
          builder: (context, authVM, transactionVM, budgetVM, savingVM, _) {
            final user = authVM.currentUser;
            final initial = user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?';

            return Column(
              children: [
                // Curved Header & Profile Card
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Pink Background Curve
                    Container(
                      height: 240,
                      width: double.infinity,
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
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: const SafeArea(
                        child: Text(
                          'Profil',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
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
                    Positioned(
                      top: 150, // Card overlaps the curve
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              offset: const Offset(0, 8),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF06292),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Center(
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -2,
                                  right: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD54F),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                    ),
                                    child: const Icon(Icons.star_rounded, color: Colors.white, size: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.name ?? 'Mock User',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1C1E),
                                    ),
                                  ),
                                  Text(
                                    user?.email ?? 'user@mock.com',
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFCE4EC),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.verified_user_outlined, color: Color(0xFFE93188), size: 14),
                                        SizedBox(width: 4),
                                        Text(
                                          'Premium Member',
                                          style: TextStyle(
                                            color: Color(0xFFE93188),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100), // Adjusted space for overlapping card

                // Statistics Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildStatCard(
                        icon: Icons.swap_horiz_rounded,
                        count: transactionVM.transactions.length.toString(),
                        label: 'Transaksi',
                        color: const Color(0xFFFCE4EC),
                        iconColor: const Color(0xFFE93188),
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: Icons.auto_stories_rounded,
                        count: budgetVM.budgets.length.toString(),
                        label: 'Anggaran',
                        color: const Color(0xFFF3E5F5),
                        iconColor: const Color(0xFF9575CD),
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: Icons.savings_rounded,
                        count: savingVM.savingGoals.length.toString(),
                        label: 'Tabungan',
                        color: const Color(0xFFE8F5E9),
                        iconColor: const Color(0xFF4DB6AC),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Info Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuListItem(
                          icon: Icons.email_outlined,
                          title: 'EMAIL',
                          subtitle: user?.email ?? 'user@mock.com',
                          iconBgColor: const Color(0xFFFCE4EC),
                          iconColor: const Color(0xFFE93188),
                        ),
                        const Divider(height: 1, indent: 60),
                        _buildMenuListItem(
                          icon: Icons.currency_exchange_rounded,
                          title: 'MATA UANG',
                          subtitle: '${user?.currency ?? 'IDR'} — Rupiah Indonesia',
                          iconBgColor: const Color(0xFFE8F5E9),
                          iconColor: const Color(0xFF4DB6AC),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Actions Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildActionListItem(
                          icon: Icons.settings_outlined,
                          title: 'Pengaturan',
                          subtitle: 'Ubah preferensi aplikasi',
                          iconColor: const Color(0xFF9575CD),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 60),
                        _buildActionListItem(
                          icon: Icons.info_outline_rounded,
                          title: 'Tentang Aplikasi',
                          subtitle: 'Versi 1.0.0',
                          iconColor: const Color(0xFF64B5F6),
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'Finora',
                              applicationVersion: '1.0.0',
                              applicationLegalese: '© 2026 Finora Project. All rights reserved.',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () => _showLogoutDialog(context, authVM),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFFCE4EC), width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.logout_rounded, color: Color(0xFFE93188), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Keluar dari Akun',
                            style: TextStyle(
                              color: Color(0xFFE93188),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Finora · Versi 1.0.0',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1C1E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel authVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Akun?'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              authVM.logout();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
