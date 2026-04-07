import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
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
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          final username = user?.username ?? 'User';
          final email = user?.email ?? 'user@example.com';

          final hPad = Responsive.padding(context, AppSpacing.md);
          final spacingSm = Responsive.spacing(context, AppSpacing.sm);
          final spacingLg = Responsive.spacing(context, AppSpacing.lg);
          final spacingXl = Responsive.spacing(context, AppSpacing.xl);
          final viewPadBottom = MediaQuery.viewPaddingOf(context).bottom;
          final avatarR = Responsive.avatarRadius(context, 36);
          final iconSize = Responsive.iconSize(context, 30);
          final vPad = Responsive.spacing(context, AppSpacing.md);
          final usernameFont = Responsive.fontSize(context, 18);
          final emailFont = Responsive.fontSize(context, 12);
          final iconSizeSmall = Responsive.iconSize(context, 14);
          final logoutFont = Responsive.fontSize(context, 15);
          final logoutIcon = Responsive.iconSize(context, 20);
          // 底部导航 + 安全区 + 额外呼吸空间，避免列表与按钮贴边
          final scrollBottomPad =
              spacingXl + viewPadBottom + Responsive.spacing(context, AppSpacing.sm);

          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                hPad,
                spacingSm,
                hPad,
                scrollBottomPad,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: Responsive.height(context, 140).clamp(120.0, 200.0),
                    ),
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
                  SizedBox(height: spacingXl),
                  _buildLogoutButton(
                    context,
                    authProvider,
                    fontSize: logoutFont,
                    iconSize: logoutIcon,
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
    final l10n = AppLocalizations.of(context)!;
    final iconContainerSize = Responsive.spacing(context, 40).clamp(36.0, 44.0);
    final iconSizeVal = Responsive.iconSize(context, 20);
    final tilePadH = Responsive.padding(context, AppSpacing.md);
    final tilePadV = Responsive.spacing(context, AppSpacing.md);
    final titleFont = Responsive.fontSize(context, 14);
    final chevronSize = Responsive.iconSize(context, 22);
    final dividerIndent = iconContainerSize + tilePadH * 2 + iconSizeVal * 0.5;

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
            title: l10n.accountInfo,
            onTap: () => _navigateTo(context, const AccountInfoScreen()),
            iconContainerSize: iconContainerSize,
            iconSizeVal: iconSizeVal,
            titleFont: titleFont,
            chevronSize: chevronSize,
            paddingH: tilePadH,
            paddingV: tilePadV,
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.lock_outlined,
            iconColor: AppColors.warning,
            title: l10n.accountSecurity,
            onTap: () => _navigateTo(context, const AccountSecurityScreen()),
            iconContainerSize: iconContainerSize,
            iconSizeVal: iconSizeVal,
            titleFont: titleFont,
            chevronSize: chevronSize,
            paddingH: tilePadH,
            paddingV: tilePadV,
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.account_circle_outlined,
            iconColor: AppColors.info,
            title: l10n.personalization,
            onTap: () => _navigateTo(context, const PersonalizationScreen()),
            iconContainerSize: iconContainerSize,
            iconSizeVal: iconSizeVal,
            titleFont: titleFont,
            chevronSize: chevronSize,
            paddingH: tilePadH,
            paddingV: tilePadV,
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.settings_outlined,
            iconColor: AppColors.textSecondary,
            title: l10n.systemSettings,
            onTap: () => _navigateTo(context, const SystemSettingsScreen()),
            iconContainerSize: iconContainerSize,
            iconSizeVal: iconSizeVal,
            titleFont: titleFont,
            chevronSize: chevronSize,
            paddingH: tilePadH,
            paddingV: tilePadV,
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.speed_outlined,
            iconColor: AppColors.success,
            title: l10n.quickFunctions,
            onTap: () => _navigateTo(context, const QuickFunctionsScreen()),
            iconContainerSize: iconContainerSize,
            iconSizeVal: iconSizeVal,
            titleFont: titleFont,
            chevronSize: chevronSize,
            paddingH: tilePadH,
            paddingV: tilePadV,
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.help_outline,
            iconColor: AppColors.primaryLight,
            title: l10n.helpSupport,
            onTap: () => _navigateTo(context, const HelpSupportScreen()),
            showDivider: false,
            iconContainerSize: iconContainerSize,
            iconSizeVal: iconSizeVal,
            titleFont: titleFont,
            chevronSize: chevronSize,
            paddingH: tilePadH,
            paddingV: tilePadV,
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
    double paddingH = 12,
    double paddingV = 14,
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
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: titleFont,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
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
  }) {
    final l10n = AppLocalizations.of(context)!;
    // 使用固定最小高度，避免窄屏上 spacing 缩小导致按钮高度仅 20px+ 挤压文字
    final btnHeight = Responsive.buttonHeight(context, 52).clamp(48.0, 56.0);

    return SizedBox(
      width: double.infinity,
      height: btnHeight,
      child: ElevatedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.confirmLogout),
              content: Text(l10n.logoutConfirmMsg),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.logout),
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
        label: Text(l10n.logoutBtn, style: TextStyle(fontSize: fontSize)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, btnHeight),
          tapTargetSize: MaterialTapTargetSize.padded,
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.padding(context, AppSpacing.md),
            vertical: Responsive.spacing(context, AppSpacing.sm),
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
