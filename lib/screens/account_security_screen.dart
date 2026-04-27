import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// 账户安全详情页面
/// 显示和管理账户安全相关的设置
class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  bool _isLoading = false;

  void _showChangePasswordDialog() {
    final l10n = AppLocalizations.of(context)!;
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.passwordChange),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.oldPassword,
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.newPassword,
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.confirmNewPassword,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: _isLoading
                ? null
                : () async {
                    if (oldPasswordController.text.isEmpty ||
                        newPasswordController.text.isEmpty ||
                        confirmPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text(l10n.fillAllFields)),
                      );
                      return;
                    }
                    if (newPasswordController.text != confirmPasswordController.text) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text(l10n.passwordMismatch)),
                      );
                      return;
                    }
                    if (newPasswordController.text.length < 6) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text(l10n.passwordMinLength)),
                      );
                      return;
                    }

                    final authProvider = context.read<AuthProvider>();
                    final user = authProvider.user;
                    if (user == null || user.employeeId == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('无法获取用户信息，请重新登录')),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext);
                    await _handlePasswordChange(
                      user.employeeId!,
                      user.username,
                      newPasswordController.text,
                    );
                  },
            child: Text(_isLoading ? '...' : l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePasswordChange(
    String employeeId,
    String username,
    String newPassword,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.updatePassword(
        employeeId: employeeId,
        username: username,
        newPassword: newPassword,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.success ? l10n.passwordChangedSuccess : response.message),
          backgroundColor: response.success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('密码修改失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountSecurityTitle),
      ),
      body: ListView(
        padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.lock_outlined, size: Responsive.iconSize(context, 24)),
                  title: Text(l10n.passwordChange, style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  trailing: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: _isLoading ? null : _showChangePasswordDialog,
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),
          Card(
            child: Padding(
              padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.securityTips,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: Responsive.fontSize(context, 16),
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                  Text(
                    l10n.securityTipsContent,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: Responsive.fontSize(context, 13),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
