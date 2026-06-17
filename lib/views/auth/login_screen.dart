import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';
import '../../services/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../widgets/auth_components.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    // Check for existing session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    final authViewModel = context.read<AuthViewModel>();
    await authViewModel.loadCurrentUser();
    if (authViewModel.isLoggedIn && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                      AppLocalizations.of(context).translate('app_tagline'),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Auth Switcher
                    AuthTabControl(
                      isLogin: true,
                      leftLabel: AppLocalizations.of(
                        context,
                      ).translate('login'),
                      rightLabel: AppLocalizations.of(
                        context,
                      ).translate('register'),
                      onToggle: (isLogin) {
                        if (!isLogin) {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, anim1, anim2) =>
                                  const RegisterScreen(),
                              transitionDuration: Duration.zero,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Input Fields
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

                    const SizedBox(height: 24),

                    // Login Button
                    GradientButton(
                      text: AppLocalizations.of(context).translate('login'),
                      icon: Icons.auto_awesome_rounded,
                      isLoading: authViewModel.isLoading,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await authViewModel.login(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          if (success && mounted) {
                            Navigator.of(context).pushReplacementNamed('/home');
                          }
                        }
                      },
                    ),

                    // Lupa Password
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: 'Lupa password? ',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: 'Reset di sini',
                                style: TextStyle(
                                  color: Color(0xFFE93188),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
