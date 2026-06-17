import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';
import '../../services/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../l10n/app_localizations.dart';

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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('settings')),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                AppLocalizations.of(context).translate('preferences'),
                style: AppTextStyles.headline,
              ),
            ),
            Consumer<SettingsViewModel>(
              builder: (context, settingsVM, _) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.brightness_6_outlined),
                      title: Text(
                        AppLocalizations.of(context).translate('theme'),
                      ),
                      subtitle: Text(
                        settingsVM.themeMode == ThemeMode.dark
                            ? AppLocalizations.of(
                                context,
                              ).translate('dark_mode')
                            : (settingsVM.themeMode == ThemeMode.light
                                  ? AppLocalizations.of(
                                      context,
                                    ).translate('light_mode')
                                  : AppLocalizations.of(
                                      context,
                                    ).translate('system_theme')),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showThemeDialog(context, settingsVM),
                    ),
                    ListTile(
                      leading: const Icon(Icons.language_outlined),
                      title: Text(
                        AppLocalizations.of(context).translate('language'),
                      ),
                      subtitle: Text(
                        settingsVM.locale.languageCode == 'id'
                            ? 'Bahasa Indonesia'
                            : 'English',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showLanguageDialog(context, settingsVM),
                    ),
                    Consumer<AuthViewModel>(
                      builder: (context, authVM, _) {
                        return ListTile(
                          leading: const Icon(Icons.monetization_on_outlined),
                          title: Text(
                            AppLocalizations.of(context).translate('currency'),
                          ),
                          subtitle: Text(authVM.currentUser?.currency ?? 'IDR'),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () => _showCurrencyDialog(context, authVM),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, AuthViewModel authVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('choose_currency')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('IDR - Indonesian Rupiah'),
              value: 'IDR',
              groupValue: authVM.currentUser?.currency,
              onChanged: (value) async {
                if (value != null) {
                  await authVM.updateProfile(
                    name: authVM.currentUser?.name ?? '',
                    currency: value,
                  );
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('USD - US Dollar'),
              value: 'USD',
              groupValue: authVM.currentUser?.currency,
              onChanged: (value) async {
                if (value != null) {
                  await authVM.updateProfile(
                    name: authVM.currentUser?.name ?? '',
                    currency: value,
                  );
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsViewModel settingsVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('choose_theme')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(AppLocalizations.of(context).translate('light_mode')),
              value: ThemeMode.light,
              groupValue: settingsVM.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settingsVM.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(AppLocalizations.of(context).translate('dark_mode')),
              value: ThemeMode.dark,
              groupValue: settingsVM.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settingsVM.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(
                AppLocalizations.of(context).translate('system_theme'),
              ),
              value: ThemeMode.system,
              groupValue: settingsVM.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settingsVM.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsViewModel settingsVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('choose_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Bahasa Indonesia'),
              value: 'id',
              groupValue: settingsVM.locale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  settingsVM.setLocale(const Locale('id'));
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: settingsVM.locale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  settingsVM.setLocale(const Locale('en'));
                  Navigator.pop(context);
                }
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
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('password_change_success'),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
