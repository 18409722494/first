import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/luggage.dart';
import '../providers/auth_provider.dart';
import '../services/baggage_api_service.dart';
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
import 'add_luggage_screen.dart';

/// ============================================================
/// 首页 - 应用主入口页面
/// ============================================================
/// 功能说明：
/// - 展示欢迎信息和用户头像
/// - 提供快捷操作入口（扫码、手动添加、破损报告等）
/// - 显示最近处理的行李记录
///
/// 数据来源：
/// - 用户信息：从 AuthProvider 获取
/// - 行李数据：从 BaggageApiService.getAllBaggageList() 获取
///
/// 页面跳转：
/// - 点击快捷操作 → 跳转到对应功能页面
/// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// ============================================================
/// 最近处理行李项数据模型
/// 用于展示在首页"最近处理"区域
/// ============================================================
class RecentLuggageItem {
  final String tagNumber;    // 行李标签号
  final String info;         // 显示信息（航班+当前位置+重量）
  final String status;       // 状态文字
  final Color statusColor;   // 状态背景色
  final Color statusTextColor; // 状态文字颜色
  final Color iconBgColor;  // 图标背景色
  final bool isOverweight;   // 是否超重（>23kg）

  const RecentLuggageItem({
    required this.tagNumber,
    required this.info,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
    required this.iconBgColor,
    this.isOverweight = false,
  });
}

/// ============================================================
/// 首页状态管理
/// ============================================================
class _HomeScreenState extends State<HomeScreen> {
  List<RecentLuggageItem> _recentItems = [];  // 最近处理行李列表
  bool _isLoadingRecent = true;  // 是否正在加载

  /// 页面初始化时加载行李数据
  @override
  void initState() {
    super.initState();
    // 延迟获取 l10n，因为在 initState 中无法获取
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _loadRecentLuggage(l10n);
      }
    });
  }

  /// 加载最近的行李数据
  /// 逻辑：从所有行李中按更新时间降序排序，取前2条
  Future<void> _loadRecentLuggage(AppLocalizations l10n) async {
    setState(() => _isLoadingRecent = true);

    try {
      // 获取所有行李列表
      final allLuggage = await BaggageApiService.getAllBaggageList();
      debugPrint('[HomeScreen] 获取到行李数量: ${allLuggage.length}');

      if (allLuggage.isEmpty) {
        if (mounted) {
          setState(() {
            _recentItems = [];
            _isLoadingRecent = false;
          });
        }
        return;
      }

      // 按 lastUpdated 降序排序，取前2条
      final sorted = List.from(allLuggage)
        ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

      final recent = sorted.take(2).map((luggage) {
        // 判断是否超重（标准为23kg）
        final isOverweight = luggage.weight > 23.0;
        // 拼接显示信息
        final info = isOverweight
            ? '${luggage.flightNumber} · ${luggage.destination.isNotEmpty ? luggage.destination : l10n.unknownLocation} · ${l10n.overweight((luggage.weight - 23.0).toStringAsFixed(1))}'
            : '${luggage.flightNumber} · ${luggage.destination.isNotEmpty ? luggage.destination : l10n.unknownLocation} · ${luggage.weight}kg';

        return RecentLuggageItem(
          tagNumber: luggage.tagNumber,
          info: info,
          status: _getStatusText(luggage, l10n),
          statusColor: _getStatusBgColor(luggage.status),
          statusTextColor: _getStatusTextColor(luggage.status),
          iconBgColor: _getStatusBgColor(luggage.status),
          isOverweight: isOverweight,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _recentItems = recent;
          _isLoadingRecent = false;
        });
      }
    } catch (e) {
      debugPrint('[HomeScreen] 加载最近处理行李失败: $e');
      if (mounted) {
        setState(() {
          _recentItems = [];
          _isLoadingRecent = false;
        });
      }
    }
  }

  /// 将行李状态枚举转换为显示文字
  /// 映射关系：checkIn→已托运, inTransit→运输中, arrived→已到达...
  String _getStatusText(Luggage luggage, AppLocalizations l10n) {
    switch (luggage.status) {
      case LuggageStatus.checkIn:
        return l10n.checkIn;
      case LuggageStatus.inTransit:
        return l10n.inTransit;
      case LuggageStatus.arrived:
        return l10n.arrived;
      case LuggageStatus.delivered:
        return l10n.delivered;
      case LuggageStatus.damaged:
        return l10n.damaged;
      case LuggageStatus.lost:
        return l10n.lost;
      default:
        return l10n.checkIn;
    }
  }

  /// 获取状态对应的浅色背景
  Color _getStatusBgColor(LuggageStatus status) {
    switch (status) {
      case LuggageStatus.checkIn:
        return const Color(0xFFDCFCE7);
      case LuggageStatus.inTransit:
        return const Color(0xFFFEF3C7);
      case LuggageStatus.arrived:
        return const Color(0xFFDCFCE7);
      case LuggageStatus.delivered:
        return const Color(0xFFDCFCE7);
      case LuggageStatus.damaged:
        return const Color(0xFFFEF2F2);
      case LuggageStatus.lost:
        return const Color(0xFFF1F5F9);
      default:
        return const Color(0xFFDCFCE7);
    }
  }

  /// 获取状态对应的文字颜色
  Color _getStatusTextColor(LuggageStatus status) {
    switch (status) {
      case LuggageStatus.checkIn:
        return const Color(0xFF16A34A);
      case LuggageStatus.inTransit:
        return const Color(0xFFD97706);
      case LuggageStatus.arrived:
        return const Color(0xFF16A34A);
      case LuggageStatus.delivered:
        return const Color(0xFF16A34A);
      case LuggageStatus.damaged:
        return const Color(0xFFDC2626);
      case LuggageStatus.lost:
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF16A34A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
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

  /// 欢迎卡片区域
  Widget _buildWelcomeCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final username = authProvider.user?.username ?? l10n.employee;
    final airportName = authProvider.user?.airportName;

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
                  l10n.goodMorning(username),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.groundStaff(airportName ?? l10n.t3Terminal),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
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
                label: l10n.scanRegister,
                bgColor: const Color(0xFFEFF6FF),
                textColor: AppColors.primaryDark,
              ),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.add_circle_outline,
                label: l10n.manualAdd,
                bgColor: const Color(0xFFF0FDF4),
                textColor: const Color(0xFF15803D),
              ),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.warning_outlined,
                label: l10n.unprocessedLuggage,
                bgColor: const Color(0xFFFFFBEB),
                textColor: const Color(0xFFC2410C),
              ),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.warning_amber_outlined,
                label: l10n.damageReport,
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
                label: l10n.luggageSearch,
                bgColor: const Color(0xFFF5F3FF),
                textColor: const Color(0xFF6D28D9),
              ),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.map_outlined,
                label: l10n.luggageMap,
                bgColor: const Color(0xFFF0F9FF),
                textColor: const Color(0xFF0369A1),
              ),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.phone_outlined,
                label: l10n.contactPassenger,
                bgColor: const Color(0xFFFFFBEB),
                textColor: const Color(0xFFB45309),
              ),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.shield_outlined,
                label: l10n.evidenceManagement,
                bgColor: const Color(0xFFF0FDFA),
                textColor: const Color(0xFF0F766E),
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
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

  /// 处理快捷操作点击，根据 label 跳转到对应页面
  void _handleActionTap(BuildContext context, String label) {
    // 根据国际化 label 查找对应路由
    final l10n = AppLocalizations.of(context)!;
    final routeMap = {
      l10n.scanRegister: const QrScanScreen(),
      l10n.luggageSearch: const SearchLuggageScreen(),
      l10n.damageReport: const DamageReportScreen(),
      l10n.evidenceManagement: const EvidenceListScreen(),
      l10n.luggageMap: const LuggageMapScreen(),
      l10n.unprocessedLuggage: const UnprocessedBaggageScreen(),
      l10n.manualAdd: const AddLuggageScreen(),
    };

    final route = routeMap[label];
    if (route != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => route));
    }
  }

  /// 最近处理区
  Widget _buildRecentSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.recentProcessing,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const Spacer(),
            if (_isLoadingRecent)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
        if (_isLoadingRecent)
          const SizedBox.shrink()
        else if (_recentItems.isEmpty)
          _buildEmptyRecentItem(context, l10n)
        else
          ...List.generate(_recentItems.length, (index) {
            final item = _recentItems[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _recentItems.length - 1
                    ? Responsive.spacing(context, AppSpacing.sm)
                    : 0,
              ),
              child: _buildRecentItem(
                context,
                tagNumber: item.tagNumber,
                info: item.info,
                status: item.status,
                statusColor: item.statusColor,
                statusTextColor: item.statusTextColor,
                iconBgColor: item.iconBgColor,
              ),
            );
          }),
      ],
    );
  }

  /// 空状态
  Widget _buildEmptyRecentItem(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 24,
            color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.noProcessingRecord,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
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
