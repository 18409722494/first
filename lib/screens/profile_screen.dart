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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDrawerOpen = false;
  double _dragOffset = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('员工中心'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _isDrawerOpen = !_isDrawerOpen;
            });
          },
        ),
      ),
      body: GestureDetector(
        onHorizontalDragStart: (details) {
          _dragOffset = 0;
        },
        onHorizontalDragUpdate: (details) {
          _dragOffset += details.delta.dx;

          if (_dragOffset > 0 && !_isDrawerOpen) {
            setState(() {
              _dragOffset = _dragOffset.clamp(0.0, Responsive.fractionWidth(context, 0.7));
            });
          }
        },
        onHorizontalDragEnd: (details) {
          if (_dragOffset > Responsive.fractionWidth(context, 0.25)) {
            setState(() {
              _isDrawerOpen = true;
              _dragOffset = 0;
            });
          } else {
            setState(() {
              _dragOffset = 0;
            });
          }
        },
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              transform: Matrix4.translationValues(
                _isDrawerOpen
                    ? Responsive.fractionWidth(context, 0.7)
                    : _dragOffset,
                0,
                0,
              ),
              child: Scaffold(
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
              ),
            ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: _isDrawerOpen ? 0 : -Responsive.fractionWidth(context, 0.7),
              top: 0,
              bottom: 0,
              width: Responsive.fractionWidth(context, 0.7),
              child: _buildDrawer(context),
            ),

            if (_isDrawerOpen)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isDrawerOpen = false;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: Colors.black.withValues(alpha: 0.5),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
          ],
        ),
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
            onTap: () => _navigateTo(const AccountInfoScreen()),
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.lock_outlined,
            iconColor: AppColors.warning,
            title: '账户安全',
            onTap: () => _navigateTo(const AccountSecurityScreen()),
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.account_circle_outlined,
            iconColor: AppColors.info,
            title: '个性化设置',
            onTap: () => _navigateTo(const PersonalizationScreen()),
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.settings_outlined,
            iconColor: AppColors.textSecondary,
            title: '系统设置',
            onTap: () => _navigateTo(const SystemSettingsScreen()),
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.speed_outlined,
            iconColor: AppColors.success,
            title: '快捷功能',
            onTap: () => _navigateTo(const QuickFunctionsScreen()),
          ),
          Divider(height: 1, indent: dividerIndent),
          _buildSettingsTile(
            context: context,
            icon: Icons.help_outline,
            iconColor: AppColors.primaryLight,
            title: '帮助与支持',
            onTap: () => _navigateTo(const HelpSupportScreen()),
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
    final iconContainerSize = Responsive.spacing(context, 36);
    final iconSizeVal = Responsive.iconSize(context, 18);
    final dividerIndent = iconContainerSize + Responsive.spacing(context, AppSpacing.sm) * 2 + iconSizeVal;

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
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: iconSizeVal,
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

  Widget _buildDrawer(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              '快速导航',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.home,
            title: '首页',
            onTap: () => _closeDrawer(),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.luggage,
            title: '行李管理',
            onTap: () => _closeDrawer(),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.task,
            title: '待办事项',
            onTap: () => _closeDrawer(),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.person,
            title: '个人中心',
            onTap: () => _closeDrawer(),
          ),
          const Divider(height: AppSpacing.lg),
          _buildDrawerItem(
            context: context,
            icon: Icons.qr_code_scanner,
            title: '扫描二维码',
            onTap: () => _closeDrawer(),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.map,
            title: '行李地图',
            onTap: () => _closeDrawer(),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          onTap: onTap,
        ),
        if (showDivider) const SizedBox(height: AppSpacing.xs),
      ],
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _closeDrawer() {
    Navigator.of(context).pop();
    setState(() {
      _isDrawerOpen = false;
    });
  }
}
