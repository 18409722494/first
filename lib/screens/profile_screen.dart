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

          final hPad = Responsive.padding(context, AppSpacing.md);
          final spacingSm = Responsive.spacing(context, AppSpacing.sm);
          final spacingLg = Responsive.spacing(context, AppSpacing.lg);
          final avatarR = 36.0;
          final iconSize = 30.0;
          final vPad = Responsive.spacing(context, AppSpacing.md);
          final usernameFont = Responsive.fontSize(context, 18);
          final emailFont = Responsive.fontSize(context, 12);
          final iconSizeSmall = 14.0;
          final logoutFont = Responsive.fontSize(context, 15);
          final logoutIcon = 20.0;
          final logoutPadV = Responsive.spacing(context, AppSpacing.buttonPadding + 2);

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                hPad,
                spacingSm,
                hPad,
                spacingLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 160),
                    child: _buildProfileHeader(
                      context,
                      username,
                      email,
                      avatarR: avatarR,
                      iconSize: iconSize,
                      vPad: vPad,
                      usernameFont: usernameFont,
                      emailFont: emailFont,
                      iconSizeSmall: iconSizeSmall,
                    ),
                  ),
                  SizedBox(height: spacingLg),
                  _buildSettingsSection(context),
                  SizedBox(height: spacingLg),
                  _buildLogoutButton(
                    context,
                    authProvider,
                    fontSize: logoutFont,
                    iconSize: logoutIcon,
                    paddingV: logoutPadV,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String username,
    String email, {
    required double avatarR,
    required double iconSize,
    required double vPad,
    required double usernameFont,
    required double emailFont,
    required double iconSizeSmall,
  }) {
    final hPadding = Responsive.padding(context, AppSpacing.md);

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
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPad),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(vPad * 0.3),
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
                  fontSize: iconSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: vPad * 0.5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              username,
              style: TextStyle(
                fontSize: usernameFont,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: vPad * 0.2),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: vPad * 0.6,
              vertical: vPad * 0.2,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.email_outlined, size: iconSizeSmall, color: Colors.white70),
                SizedBox(width: vPad * 0.3),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      email,
                      style: TextStyle(fontSize: emailFont, color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                    ),
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
    const iconContainerSize = 36.0;
    const iconSizeVal = 18.0;
    final dividerIndent =
        iconContainerSize + AppSpacing.sm * 2 + iconSizeVal;

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
            iconContainerSize: iconContainerSize,
            iconSizeVal: iconSizeVal,
            titleFont: 14,
            chevronSize: 20,
            paddingH: AppSpacing.sm,
            paddingV: AppSpacing.sm,
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.lock_outlined,
            iconColor: AppColors.warning,
            title: '账户安全',
            onTap: () => _navigateTo(context, const AccountSecurityScreen()),
            iconContainerSize: iconContainerSize,
            iconSizeVal: iconSizeVal,
            titleFont: 14,
            chevronSize: 20,
            paddingH: AppSpacing.sm,
            paddingV: AppSpacing.sm,
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.account_circle_outlined,
            iconColor: AppColors.info,
            title: '个性化设置',
            onTap: () => _navigateTo(context, const PersonalizationScreen()),
            iconContainerSize: iconContainerSize,
            iconSizeVal: iconSizeVal,
            titleFont: 14,
            chevronSize: 20,
            paddingH: AppSpacing.sm,
            paddingV: AppSpacing.sm,
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.settings_outlined,
            iconColor: AppColors.textSecondary,
            title: '系统设置',
            onTap: () => _navigateTo(context, const SystemSettingsScreen()),
            iconContainerSize: iconContainerSize,
            iconSizeVal: iconSizeVal,
            titleFont: 14,
            chevronSize: 20,
            paddingH: AppSpacing.sm,
            paddingV: AppSpacing.sm,
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.speed_outlined,
            iconColor: AppColors.success,
            title: '快捷功能',
            onTap: () => _navigateTo(context, const QuickFunctionsScreen()),
            iconContainerSize: iconContainerSize,
            iconSizeVal: iconSizeVal,
            titleFont: 14,
            chevronSize: 20,
            paddingH: AppSpacing.sm,
            paddingV: AppSpacing.sm,
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.help_outline,
            iconColor: AppColors.primaryLight,
            title: '帮助与支持',
            onTap: () => _navigateTo(context, const HelpSupportScreen()),
            showDivider: false,
            iconContainerSize: iconContainerSize,
            iconSizeVal: iconSizeVal,
            titleFont: 14,
            chevronSize: 20,
            paddingH: AppSpacing.sm,
            paddingV: AppSpacing.sm,
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
    double iconContainerSize = 36,
    double iconSizeVal = 18,
    double titleFont = 14,
    double chevronSize = 20,
    double paddingH = 8,
    double paddingV = 8,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
          child: Row(
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: iconColor, size: iconSizeVal),
              ),
              SizedBox(width: paddingH),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
                size: chevronSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    AuthProvider authProvider, {
    double fontSize = 15,
    double iconSize = 20,
    double paddingV = 16,
  }) {
    // 勿用固定高度包裹按钮：主题已有较大 vertical padding，height 过小会裁剪图标与文字
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
            final serverMsg = await authProvider.logout();
            if (context.mounted) {
              if (serverMsg != null && serverMsg.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(serverMsg)),
                );
              }
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          }
        },
        icon: Icon(Icons.logout, size: iconSize),
        label: Text('退出登录', style: TextStyle(fontSize: fontSize)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, kMinInteractiveDimension),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: paddingV.clamp(12.0, 18.0),
          ),
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
