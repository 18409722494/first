import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import 'register_screen.dart';
import 'main_screen.dart';

/// 登录页面 - 基于 UI 设计 (Frame21)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _employeeIdController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _employeeIdController.dispose();
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
        employeeId: _employeeIdController.text.trim(),
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
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // 状态栏区域
            _buildStatusBar(),
            // 主内容区域
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Logo区域 - 带渐变背景
                    _buildHeaderArea(),
                    // 表单区域
                    Padding(
                      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.lg)),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 标题
                            Text(
                              l10n.userLogin,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                            Text(
                              l10n.loginHint,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),

                            // 工号输入框
                            _buildDarkTextField(
                              controller: _employeeIdController,
                              hint: '员工工号',
                              prefixIcon: Icons.badge_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入员工工号';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

                            // 用户名输入框
                            _buildDarkTextField(
                              controller: _usernameController,
                              hint: '用户名',
                              prefixIcon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.enterUsername;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

                            // 密码输入框
                            _buildDarkTextField(
                              controller: _passwordController,
                              hint: '登录密码',
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.enterPassword;
                                }
                                if (value.length < 6) {
                                  return l10n.passwordMinLength;
                                }
                                return null;
                              },
                              onSubmitted: (_) => _handleLogin(),
                            ),
                            SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),

                            // 登录按钮
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return _buildLoginButton(authProvider);
                              },
                            ),
                            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

                            // 底部链接
                            _buildBottomLinks(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 状态栏
  Widget _buildStatusBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '09:41',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            '5G ▋▋▋',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 头部Logo区域 - 带渐变
  Widget _buildHeaderArea() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF1E3A5F),
            Color(0xFF0F172A),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo 图标
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.flight,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'AirBaggage Pro',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '航司行李托运管理系统',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  /// 深色样式输入框
  Widget _buildDarkTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        onFieldSubmitted: onSubmitted,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textHintDark),
          prefixIcon: Icon(prefixIcon, color: AppColors.textSecondaryDark, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  /// 登录按钮
  Widget _buildLoginButton(AuthProvider authProvider) {
    return InkWell(
      onTap: authProvider.isLoading ? null : _handleLogin,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: authProvider.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  AppLocalizations.of(context)!.login,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  /// 底部链接
  Widget _buildBottomLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '忘记密码？',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondaryDark,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const RegisterScreen(),
              ),
            );
          },
          child: const Text(
            '注册/激活账号 →',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
