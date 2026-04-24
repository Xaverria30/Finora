import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';
import '../../services/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  final _formKey = GlobalKey<FormState>();
  bool _showPasswordForm = false;

  @override
  void initState() {
    super.initState();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text('Keamanan', style: AppTextStyles.headline),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outlined),
              title: const Text('Ubah Password'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                setState(() => _showPasswordForm = !_showPasswordForm);
              },
            ),
            if (_showPasswordForm)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ubah Password Anda', style: AppTextStyles.label),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _oldPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password Lama',
                          prefixIcon: Icon(Icons.lock_outline),
                          hintText: 'Masukkan password lama',
                        ),
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password Baru',
                          prefixIcon: Icon(Icons.lock_outline),
                          hintText: 'Masukkan password baru',
                          helperText: 'Minimal 8 karakter',
                        ),
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Konfirmasi Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          hintText: 'Ulangi password baru',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi password tidak boleh kosong';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Password tidak cocok';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Consumer<AuthViewModel>(
                        builder: (context, authVM, _) {
                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: authVM.isLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _submitPasswordChange(
                                              context,
                                              authVM,
                                            );
                                          }
                                        },
                                  child: authVM.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Text('Ubah Password'),
                                ),
                              ),
                              if (authVM.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppSpacing.md,
                                  ),
                                  child: Text(
                                    authVM.errorMessage!,
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.error,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text('Preferensi', style: AppTextStyles.headline),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifikasi'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pengaturan notifikasi akan segera tersedia'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language_outlined),
              title: const Text('Bahasa'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pengaturan bahasa akan segera tersedia'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined),
              title: const Text('Tema'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pengaturan tema akan segera tersedia'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitPasswordChange(BuildContext context, AuthViewModel authVM) async {
    final success = await authVM.changePassword(
      currentPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      setState(() => _showPasswordForm = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil diubah'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
