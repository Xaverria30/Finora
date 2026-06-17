import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';
import '../../services/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../widgets/auth_components.dart';
import 'login_screen.dart';
import '../../l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    // Logo & Branding
                    const FinoraLogo(),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(
                        context,
                      ).translate('register_tagline'),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Auth Switcher
                    AuthTabControl(
                      isLogin: false,
                      leftLabel: AppLocalizations.of(
                        context,
                      ).translate('login'),
                      rightLabel: AppLocalizations.of(
                        context,
                      ).translate('register'),
                      onToggle: (isLogin) {
                        if (isLogin) {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, anim1, anim2) =>
                                  const LoginScreen(),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Input Fields
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.light
                            ? AppColors.surface
                            : const Color(0xFF2C2C2C),
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        hintText: AppLocalizations.of(
                          context,
                        ).translate('name_hint'),
                      ),
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.light
                            ? AppColors.surface
                            : const Color(0xFF2C2C2C),
                        prefixIcon: const Icon(Icons.email_outlined),
                        hintText: AppLocalizations.of(
                          context,
                        ).translate('email_hint'),
                      ),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.light
                            ? AppColors.surface
                            : const Color(0xFF2C2C2C),
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        hintText: AppLocalizations.of(
                          context,
                        ).translate('password_hint'),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.light
                            ? AppColors.surface
                            : const Color(0xFF2C2C2C),
                        prefixIcon: const Icon(Icons.lock_reset_rounded),
                        hintText: AppLocalizations.of(
                          context,
                        ).translate('confirm_password'),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(
                            context,
                          ).translate('password_confirm_empty');
                        }
                        if (value != _passwordController.text) {
                          return AppLocalizations.of(
                            context,
                          ).translate('password_mismatch');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Register Button
                    GradientButton(
                      text: AppLocalizations.of(context).translate('register'),
                      icon: Icons.person_add_rounded,
                      isLoading: authViewModel.isLoading,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await authViewModel.register(
                            name: _nameController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                            currency: 'IDR',
                          );
                          if (success && mounted) {
                            Navigator.of(context).pushReplacementNamed('/home');
                          }
                        }
                      },
                    ),

                    if (authViewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        child: Text(
                          authViewModel.errorMessage!,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
