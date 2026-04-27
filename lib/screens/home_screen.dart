import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import '../l10n/app_localizations.dart';
import 'qr_scan_screen.dart';
import 'search_luggage_screen.dart';
import 'damage_report_screen.dart';
import 'evidence_list_screen.dart';
import 'luggage_map_screen.dart';
import 'unprocessed_baggage_screen.dart';

/// 首页 - 基于 UI 设计文档 (Frame282)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // 状态栏区域
            _buildStatusBar(),
            // 欢迎卡片区域（带渐变）
            _buildWelcomeCard(context),
            // 主内容区域
            Expanded(
              child: Container(
                color: AppColors.backgroundLight,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 快捷功能
                      _buildQuickActionsSection(context),
                      SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),
                      // 最近处理
                      _buildRecentSection(context),
                      // 底部安全区域
                      SizedBox(height: Responsive.spacing(context, 80)),
                    ],
                  ),
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
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: AppColors.primaryDark,
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

  /// 欢迎卡片区域
  Widget _buildWelcomeCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final username = authProvider.user?.username ?? l10n.employee;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '早上好，$username',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '国航 · 地勤行李员 · T3航站楼',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // 通知按钮
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // 用户头像
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                username.isNotEmpty ? username[0] : 'U',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 快捷功能区
  Widget _buildQuickActionsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
        // 第一行
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.qr_code_scanner,
                label: '扫码登记',
                bgColor: const Color(0xFFEFF6FF),
                textColor: AppColors.primaryDark,
              ),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.add_circle_outline,
                label: '手动添加',
                bgColor: const Color(0xFFF0FDF4),
                textColor: const Color(0xFF15803D),
              ),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.warning_outlined,
                label: '未处理行李',
                bgColor: const Color(0xFFFFFBEB),
                textColor: const Color(0xFFC2410C),
              ),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.warning_amber_outlined,
                label: '破损报告',
                bgColor: const Color(0xFFFEF2F2),
                textColor: const Color(0xFFB91C1C),
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
        // 第二行
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.search,
                label: '行李搜索',
                bgColor: const Color(0xFFF5F3FF),
                textColor: const Color(0xFF6D28D9),
              ),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.map_outlined,
                label: '行李地图',
                bgColor: const Color(0xFFF0F9FF),
                textColor: const Color(0xFF0369A1),
              ),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.phone_outlined,
                label: '联系旅客',
                bgColor: const Color(0xFFFFFBEB),
                textColor: const Color(0xFFB45309),
              ),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.shield_outlined,
                label: '证据管理',
                bgColor: const Color(0xFFF0FDFA),
                textColor: const Color(0xFF0F766E),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 单个快捷操作按钮
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return InkWell(
      onTap: () => _handleActionTap(context, label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: textColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 处理快捷操作点击
  void _handleActionTap(BuildContext context, String label) {
    switch (label) {
      case '扫码登记':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const QrScanScreen()),
        );
        break;
      case '行李搜索':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SearchLuggageScreen()),
        );
        break;
      case '破损报告':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DamageReportScreen()),
        );
        break;
      case '证据管理':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EvidenceListScreen()),
        );
        break;
      case '行李地图':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LuggageMapScreen()),
        );
        break;
      case '未处理行李':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const UnprocessedBaggageScreen()),
        );
        break;
      default:
        break;
    }
  }

  /// 最近处理区
  Widget _buildRecentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最近处理',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
        _buildRecentItem(
          context,
          tagNumber: 'BVIP2024-001234',
          info: 'CA1234 · 北京→上海 · 23.5kg',
          status: '已托运',
          statusColor: const Color(0xFFDCFCE7),
          statusTextColor: const Color(0xFF16A34A),
          iconBgColor: const Color(0xFFDBEAFE),
        ),
        SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
        _buildRecentItem(
          context,
          tagNumber: 'BVIP2024-001235',
          info: 'MU5678 · 上海→广州 · 超重+5.2kg',
          status: '超重',
          statusColor: const Color(0xFFFEF2F2),
          statusTextColor: const Color(0xFFDC2626),
          iconBgColor: const Color(0xFFFEF2F2),
        ),
      ],
    );
  }

  /// 单个最近处理项
  Widget _buildRecentItem(
    BuildContext context, {
    required String tagNumber,
    required String info,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
    required Color iconBgColor,
  }) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        children: [
          // 图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.luggage_outlined,
              size: 22,
              color: statusTextColor,
            ),
          ),
          const SizedBox(width: 12),
          // 文字信息
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tagNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  info,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          // 状态标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: statusTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
