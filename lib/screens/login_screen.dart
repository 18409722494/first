import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/app_text_field.dart';
import '../components/app_button.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import 'register_screen.dart';
import 'main_screen.dart';

/// 登录界面
/// 提供用户登录功能，包含用户名和密码输入
/// 支持密码显示/隐藏切换，表单验证
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// 表单验证键
  final _formKey = GlobalKey<FormState>();
  
  /// 用户名输入控制器
  final _usernameController = TextEditingController();
  
  /// 密码输入控制器
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 处理登录逻辑
  /// 验证表单后调用AuthProvider进行登录
  /// 登录成功后跳转到首页
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? '登录失败'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    '用户登录',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.fontSize(context, 24),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                  Text(
                    '请使用用户名和密码登录账户',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                          fontSize: Responsive.fontSize(context, 14),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),

                  AppTextField(
                    controller: _usernameController,
                    label: '用户名',
                    hint: '请输入用户名',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入用户名';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: Responsive.spacing(context, AppSpacing.md)),

                  AppTextField(
                    controller: _passwordController,
                    label: '密码',
                    hint: '请输入密码',
                    prefixIcon: Icons.lock_outline,
                    showPasswordToggle: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入密码';
                      }
                      if (value.length < 6) {
                        return '密码长度至少6位';
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
                        text: '登录',
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
                        '还没有员工账号？',
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
                        child: Text('前往员工注册/激活', style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
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
