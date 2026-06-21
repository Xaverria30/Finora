import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/budget_viewmodel.dart';
import '../../viewmodels/saving_viewmodel.dart';
import 'settings_screen.dart';
import '../categories/category_list_screen.dart';
import '../../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<AuthViewModel>().loadCurrentUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Consumer4<AuthViewModel, TransactionViewModel, BudgetViewModel, SavingViewModel>(
          builder: (context, authVM, transactionVM, budgetVM, savingVM, _) {
            final user = authVM.currentUser;
            final initial = user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?';

            return Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
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
                      child: SafeArea(
                        child: Text(
                          AppLocalizations.of(context).translate('profile'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
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
                    Positioned(
                      top: 150,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
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
                                      border: Border.all(color: Theme.of(context).cardColor, width: 3),
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
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          user?.name ?? 'User',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).textTheme.headlineSmall?.color,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _showEditProfileDialog(
                                              context,
                                              authVM,
                                            ),
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 20,
                                          color: Color(0xFFE93188),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    user?.email ?? '',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.light
                                          ? const Color(0xFFFCE4EC)
                                          : const Color(0xFFE93188).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.verified_user_outlined,
                                          color: Color(0xFFE93188),
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          AppLocalizations.of(context).translate('premium_member'),
                                          style: const TextStyle(
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
                const SizedBox(height: 100),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildStatCard(
                        context: context,
                        icon: Icons.swap_horiz_rounded,
                        count: transactionVM.transactions.length.toString(),
                        label: AppLocalizations.of(context).translate('transactions_count'),
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFFFCE4EC)
                            : const Color(0xFFE93188).withOpacity(0.2),
                        iconColor: const Color(0xFFE93188),
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        context: context,
                        icon: Icons.auto_stories_rounded,
                        count: budgetVM.budgets.length.toString(),
                        label: AppLocalizations.of(context).translate('budgets_count'),
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFFF3E5F5)
                            : const Color(0xFF9575CD).withOpacity(0.2),
                        iconColor: const Color(0xFF9575CD),
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        context: context,
                        icon: Icons.savings_rounded,
                        count: savingVM.savingGoals.length.toString(),
                        label: AppLocalizations.of(context).translate('savings_count'),
                        color: Theme.of(context).brightness == Brightness.light
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFF4DB6AC).withOpacity(0.2),
                        iconColor: const Color(0xFF4DB6AC),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
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
                          context: context,
                          icon: Icons.email_outlined,
                          title: AppLocalizations.of(context).translate('email_label'),
                          subtitle: user?.email ?? '',
                          iconBgColor: Theme.of(context).brightness == Brightness.light
                              ? const Color(0xFFFCE4EC)
                              : const Color(0xFFE93188).withOpacity(0.2),
                          iconColor: const Color(0xFFE93188),
                        ),
                        const Divider(height: 1, indent: 60),
                        _buildMenuListItem(
                          context: context,
                          icon: Icons.currency_exchange_rounded,
                          title: AppLocalizations.of(context).translate('currency_label'),
                          subtitle: '${user?.currency ?? 'IDR'}',
                          iconBgColor: Theme.of(context).brightness == Brightness.light
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFF4DB6AC).withOpacity(0.2),
                          iconColor: const Color(0xFF4DB6AC),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
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
                          icon: Icons.category_outlined,
                          title: AppLocalizations.of(context).translate('manage_categories'),
                          subtitle: AppLocalizations.of(context).translate('manage_categories_subtitle'),
                          iconColor: const Color(0xFF4DB6AC),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CategoryListScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 60),
                        _buildActionListItem(
                          icon: Icons.lock_reset_rounded,
                          title: 'Ganti Password',
                          subtitle: 'Perbarui password akun kamu',
                          iconColor: const Color(0xFFE93188),
                          onTap: () => _showChangePasswordDialog(context, authVM),
                        ),
                        const Divider(height: 1, indent: 60),
                        _buildActionListItem(
                          icon: Icons.settings_outlined,
                          title: AppLocalizations.of(context).translate('app_preferences'),
                          subtitle: AppLocalizations.of(context).translate('app_preferences_subtitle'),
                          iconColor: const Color(0xFF9575CD),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 60),
                        _buildActionListItem(
                          icon: Icons.info_outline_rounded,
                          title: AppLocalizations.of(context).translate('about_app'),
                          subtitle: AppLocalizations.of(context).translate('about_subtitle'),
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () => _showLogoutDialog(context, authVM),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.light
                              ? const Color(0xFFFCE4EC)
                              : const Color(0xFFE93188).withOpacity(0.3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context).translate('logout'),
                            style: const TextStyle(
                              color: AppColors.error,
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
                Text(
                  'Finora · ${AppLocalizations.of(context).translate('about_subtitle')}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
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
    required BuildContext context,
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
          color: Theme.of(context).cardColor,
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
    required BuildContext context,
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
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
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
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('logout_confirm_title')),
        content: Text(AppLocalizations.of(context).translate('logout_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context).translate('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await authVM.logout();
              navigator.pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: Text(
              AppLocalizations.of(context).translate('logout'),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthViewModel authVM) {
    final nameController = TextEditingController(text: authVM.currentUser?.name);
    final currencyController =
    TextEditingController(text: authVM.currentUser?.currency);

    showDialog(
      context: context,
      builder: (context) => Consumer<AuthViewModel>(
        builder: (context, vm, child) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context).translate('edit_profile')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context).translate('name')),
                  enabled: !vm.isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: currencyController,
                  decoration: InputDecoration(labelText: '${AppLocalizations.of(context).translate('currency_label')} (e.g. IDR)'),
                  enabled: !vm.isLoading,
                ),
                if (vm.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    vm.errorMessage!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: vm.isLoading ? null : () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).translate('cancel')),
              ),
              TextButton(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                  final success = await vm.updateProfile(
                    name: nameController.text,
                    currency: currencyController.text,
                  );
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context).translate('profile_updated_success'))),
                    );
                  }
                },
                child: vm.isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(AppLocalizations.of(context).translate('save')),
              ),
            ],
          );
        },
      ),
    );
  }
  void _showChangePasswordDialog(BuildContext context, AuthViewModel authVM) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isCurVisible = false;
    bool isNewVisible = false;
    bool isConfirmVisible = false;

    // Reset state sebelum buka dialog
    authVM.clearPasswordState();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Consumer<AuthViewModel>(
            builder: (ctx, vm, _) {
              // Tutup dialog otomatis saat sukses
              if (vm.passwordSuccess) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (Navigator.canPop(ctx)) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Password berhasil diubah!', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        backgroundColor: const Color(0xFF4DB6AC),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                    vm.clearPasswordState();
                  }
                });
              }

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE4EC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: Color(0xFFE93188),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Ganti Password',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                content: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Password lama
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: !isCurVisible,
                        decoration: InputDecoration(
                          labelText: 'Password Lama',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isCurVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 18,
                            ),
                            onPressed: () => setDialogState(() => isCurVisible = !isCurVisible),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Wajib diisi';
                          return null;
                        },
                        enabled: !vm.isPasswordLoading,
                      ),
                      const SizedBox(height: 16),
                      // Password baru
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: !isNewVisible,
                        decoration: InputDecoration(
                          labelText: 'Password Baru',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isNewVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 18,
                            ),
                            onPressed: () => setDialogState(() => isNewVisible = !isNewVisible),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Wajib diisi';
                          if (v.length < 6) return 'Minimal 6 karakter';
                          return null;
                        },
                        enabled: !vm.isPasswordLoading,
                      ),
                      const SizedBox(height: 16),
                      // Konfirmasi password baru
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: !isConfirmVisible,
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Password Baru',
                          prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isConfirmVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 18,
                            ),
                            onPressed: () => setDialogState(() => isConfirmVisible = !isConfirmVisible),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Wajib diisi';
                          if (v != newPasswordController.text) return 'Password tidak cocok';
                          return null;
                        },
                        enabled: !vm.isPasswordLoading,
                      ),
                      // Error message
                      if (vm.passwordError != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            vm.passwordError!,
                            style: const TextStyle(
                              color: Color(0xFFE53935),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: vm.isPasswordLoading
                        ? null
                        : () {
                      Navigator.pop(ctx);
                      vm.clearPasswordState();
                    },
                    child: const Text('Batal'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE93188),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: vm.isPasswordLoading
                        ? null
                        : () async {
                      if (!formKey.currentState!.validate()) return;
                      await vm.changePassword(
                        currentPassword: currentPasswordController.text,
                        newPassword: newPasswordController.text,
                      );
                    },
                    child: vm.isPasswordLoading
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Simpan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}