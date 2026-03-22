import 'package:flutter/material.dart';
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
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('修改密码'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '旧密码',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '新密码',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '确认新密码',
                  border: OutlineInputBorder(),
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
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('两次输入的密码不一致')),
                );
                return;
              }
              Navigator.pop(dialogContext);
              Future.delayed(const Duration(milliseconds: 100), () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('密码修改成功')),
                );
              });
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示绑定手机对话框
  void _showBindPhoneDialog() {
    final phoneController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('绑定手机'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: '手机号码',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '验证码',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
                  FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('验证码已发送')),
                      );
                    },
                    child: Text('获取验证码', style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
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
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (phoneController.text.isEmpty || codeController.text.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('请填写完整信息')),
                );
                return;
              }
              Navigator.pop(dialogContext);
              Future.delayed(const Duration(milliseconds: 100), () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('手机绑定成功')),
                );
              });
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账户安全'),
      ),
      body: ListView(
        padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.lock_outlined, size: Responsive.iconSize(context, 24)),
                  title: Text('修改密码', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: _showChangePasswordDialog,
                ),
                Divider(height: 1, indent: Responsive.spacing(context, 40)),
                ListTile(
                  leading: Icon(Icons.phone_outlined, size: Responsive.iconSize(context, 24)),
                  title: Text('绑定手机', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  subtitle: Text('未绑定', style: TextStyle(fontSize: Responsive.fontSize(context, 12))),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  onTap: _showBindPhoneDialog,
                ),
                Divider(height: 1, indent: Responsive.spacing(context, 40)),
                ListTile(
                  leading: Icon(Icons.two_wheeler_outlined, size: Responsive.iconSize(context, 24)),
                  title: Text('两步验证', style: TextStyle(fontSize: Responsive.fontSize(context, 14))),
                  trailing: Switch(
                    value: _twoFactorEnabled,
                    onChanged: (value) {
                      setState(() {
                        _twoFactorEnabled = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_twoFactorEnabled ? '两步验证已开启' : '两步验证已关闭')),
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
                    '安全提示',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: Responsive.fontSize(context, 16),
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
                  Text(
                    '• 请定期修改密码，使用强密码\n• 绑定手机可以提高账户安全性\n• 开启两步验证可以防止账户被非法登录',
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
