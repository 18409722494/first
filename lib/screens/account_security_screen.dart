import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
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
  bool _twoFactorEnabled = false;

  /// 显示修改密码对话框
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
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(l10n.passwordMismatch)),
                );
                return;
              }
              Navigator.pop(dialogContext);
              Future.delayed(const Duration(milliseconds: 100), () {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.passwordChangedSuccess)),
                );
              });
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  /// 显示绑定手机对话框
  void _showBindPhoneDialog() {
    final l10n = AppLocalizations.of(context)!;
    final phoneController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.phoneBind),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.verifyCode,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
                  FilledButton(
                    onPressed: () {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(l10n.verifyCodeSent)),
                );
                    },
                    child: Text(l10n.getVerifyCode, style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (phoneController.text.isEmpty || codeController.text.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(l10n.fillAllFields)),
                );
                return;
              }
              Navigator.pop(dialogContext);
              Future.delayed(const Duration(milliseconds: 100), () {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.phoneBindSuccess)),
                );
              });
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
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
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: _showChangePasswordDialog,
                ),
                Divider(height: 1, indent: Responsive.spacing(context, 40)),
                ListTile(
                  leading: Icon(Icons.phone_outlined, size: Responsive.iconSize(context, 24)),
                  title: Text(l10n.phoneBind, style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  subtitle: Text(l10n.notBound, style: TextStyle(fontSize: Responsive.fontSize(context, 12))),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: _showBindPhoneDialog,
                ),
                Divider(height: 1, indent: Responsive.spacing(context, 40)),
                ListTile(
                  leading: Icon(Icons.two_wheeler_outlined, size: Responsive.iconSize(context, 24)),
                  title: Text(l10n.twoFactorAuth, style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  trailing: Switch(
                    value: _twoFactorEnabled,
                    onChanged: (value) {
                      setState(() {
                        _twoFactorEnabled = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.twoFactorEnabled)),
                      );
                    },
                  ),
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
