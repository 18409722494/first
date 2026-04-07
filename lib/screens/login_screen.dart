import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/app_text_field.dart';
import '../components/app_button.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import 'register_screen.dart';
import 'main_screen.dart';

/// 登录页面
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? l10n.loginFail),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.padding(context, AppSpacing.md),
              vertical: Responsive.spacing(context, AppSpacing.md),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.badge_outlined,
                      size: Responsive.iconSize(context, 80),
                      color: Theme.of(context).colorScheme.primary),
                  SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
                  Text(
                    l10n.userLogin,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.fontSize(context, 24),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                  Text(
                    l10n.loginHint,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                          fontSize: Responsive.fontSize(context, 14),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),

                  AppTextField(
                    controller: _usernameController,
                    label: l10n.username,
                    hint: l10n.enterUsername,
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.enterUsername;
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

                  AppTextField(
                    controller: _passwordController,
                    label: l10n.password,
                    hint: l10n.enterPassword,
                    prefixIcon: Icons.lock_outline,
                    showPasswordToggle: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.enterPassword;
                      }
                      if (value.length < 6) {
                        return l10n.passwordMinLength;
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(),
                  ),
                  SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),

                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return AppButton(
                        text: l10n.login,
                        size: AppButtonSize.large,
                        fullWidth: true,
                        isLoading: authProvider.isLoading,
                        onPressed: authProvider.isLoading ? null : _handleLogin,
                      );
                    },
                  ),
                  SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.noAccount,
                        style: TextStyle(color: Colors.grey[600], fontSize: Responsive.fontSize(context, 13)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(l10n.goToRegister, style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
