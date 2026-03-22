import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../providers/auth_provider.dart';
import '../utils/responsive.dart';
import 'login_screen.dart';
import 'account_info_screen.dart';
import 'account_security_screen.dart';
import 'personalization_screen.dart';
import 'system_settings_screen.dart';
import 'quick_functions_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('员工中心'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          final username = user?.username ?? 'User';
          final email = user?.email ?? 'user@example.com';

          return Column(
            children: [
              _buildProfileHeader(context, username, email),
              SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
              _buildSettingsSection(context),
              const Spacer(),
              _buildLogoutButton(context, authProvider),
              SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String username, String email) {
    final avatarR = Responsive.avatarRadius(context, 36);
    final avatarIconSize = Responsive.iconSize(context, 30);
    final hPadding = Responsive.padding(context, AppSpacing.md);
    final vPadding = Responsive.spacing(context, AppSpacing.md);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.spacing(context, 4)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: CircleAvatar(
              radius: avatarR,
              backgroundColor: Colors.white,
              child: Text(
                username.isNotEmpty ? username.substring(0, 1).toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: avatarIconSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
          Text(
            username,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.spacing(context, AppSpacing.sm),
              vertical: Responsive.spacing(context, AppSpacing.xs),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: Responsive.iconSize(context, 14),
                  color: Colors.white70,
                ),
                SizedBox(width: Responsive.spacing(context, AppSpacing.xs)),
                Flexible(
                  child: Text(
                    email,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 12),
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final iconContainerSize = Responsive.spacing(context, 36);
    final iconSizeVal = Responsive.iconSize(context, 18);
    final dividerIndent = iconContainerSize + Responsive.spacing(context, AppSpacing.sm) * 2 + iconSizeVal;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            context: context,
            icon: Icons.badge_outlined,
            iconColor: AppColors.primary,
            title: '账户信息',
            onTap: () => _navigateTo(context, const AccountInfoScreen()),
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.lock_outlined,
            iconColor: AppColors.warning,
            title: '账户安全',
            onTap: () => _navigateTo(context, const AccountSecurityScreen()),
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.account_circle_outlined,
            iconColor: AppColors.info,
            title: '个性化设置',
            onTap: () => _navigateTo(context, const PersonalizationScreen()),
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.settings_outlined,
            iconColor: AppColors.textSecondary,
            title: '系统设置',
            onTap: () => _navigateTo(context, const SystemSettingsScreen()),
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.speed_outlined,
            iconColor: AppColors.success,
            title: '快捷功能',
            onTap: () => _navigateTo(context, const QuickFunctionsScreen()),
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.help_outline,
            iconColor: AppColors.primaryLight,
            title: '帮助与支持',
            onTap: () => _navigateTo(context, const HelpSupportScreen()),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.spacing(context, AppSpacing.sm),
            vertical: Responsive.spacing(context, AppSpacing.sm),
          ),
          child: Row(
            children: [
              Container(
                width: Responsive.spacing(context, 36),
                height: Responsive.spacing(context, 36),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: Responsive.iconSize(context, 18),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                size: Responsive.iconSize(context, 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('确认退出'),
              content: const Text('确定要退出登录吗？'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('退出'),
                ),
              ],
            ),
          );

          if (confirm == true && context.mounted) {
            await authProvider.logout();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          }
        },
        icon: Icon(Icons.logout, size: Responsive.iconSize(context, 20)),
        label: Text('退出登录', style: TextStyle(fontSize: Responsive.fontSize(context, 15))),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: Responsive.buttonHeight(context, AppSpacing.buttonPadding + 2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
