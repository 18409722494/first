import 'package:flutter/material.dart';
import '../models/luggage.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import 'status_badge.dart';

/// 扫码结果操作选项对话框
///
/// 在扫码后自动获取GPS并上传位置后弹出，提供快捷操作选项：
/// - 确认到达（更新状态 → arrived）
/// - 标记破损（跳转破损报告页）
/// - 超重处理（跳转超重费用页）
/// - 联系旅客（跳转联系方式页）
/// - 查看详情（跳转行李详情页）
class ScanResultDialog extends StatelessWidget {
  final Luggage luggage;
  final String rawQr;

  const ScanResultDialog({
    super.key,
    required this.luggage,
    required this.rawQr,
  });

  /// 返回值语义：
  /// - 'confirm_arrived'   → 留在扫码页，不额外导航
  /// - 'report_damage'     → 跳转破损报告页
  /// - 'overweight'        → 跳转超重费用页
  /// - 'contact_passenger' → 跳转联系方式页
  /// - 'view_detail'       → 跳转行李详情页
  /// - null                → 用户按返回/取消，留在扫码页
  static Future<String?> show({
    required BuildContext context,
    required Luggage luggage,
    required String rawQr,
  }) {
    return Navigator.of(context).push<String>(
      _ScanResultDialogRoute(
        builder: (_) => ScanResultDialog(luggage: luggage, rawQr: rawQr),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop<String>(null);
      },
      child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(context),
            _buildHeader(context),
            const Divider(height: 1),
            _buildLuggageInfo(context),
            const Divider(height: 1),
            _buildActionGrid(context),
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            _buildDismissButton(context),
            SizedBox(height: Responsive.spacing(context, AppSpacing.md)),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildHandle(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: Responsive.spacing(context, AppSpacing.sm)),
        width: 40,
        height: Responsive.height(context, 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.spacing(context, 8)),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.qr_code_scanner,
              color: AppColors.success,
              size: Responsive.iconSize(context, 24),
            ),
          ),
          SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '扫码成功',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.fontSize(context, 17),
                      ),
                ),
                Text(
                  '请选择操作',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: Responsive.fontSize(context, 12),
                      ),
                ),
              ],
            ),
          ),
          StatusBadge(status: luggage.status),
        ],
      ),
    );
  }

  Widget _buildLuggageInfo(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.padding(context, AppSpacing.md),
        vertical: Responsive.spacing(context, AppSpacing.sm),
      ),
      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.sm)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        children: [
          _buildInfoRow(context, '行李号', luggage.tagNumber.isNotEmpty ? luggage.tagNumber : '-'),
          SizedBox(height: Responsive.spacing(context, 4)),
          _buildInfoRow(context, '航班号', luggage.flightNumber.isNotEmpty ? luggage.flightNumber : '-'),
          SizedBox(height: Responsive.spacing(context, 4)),
          _buildInfoRow(context, '乘客', luggage.passengerName.isNotEmpty ? luggage.passengerName : '-'),
          SizedBox(height: Responsive.spacing(context, 4)),
          _buildInfoRow(context, '重量', luggage.weight > 0 ? '${luggage.weight} kg' : '-'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: Responsive.spacing(context, 55),
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: Responsive.fontSize(context, 12),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: Responsive.fontSize(context, 12),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.check_circle_outline,
                  label: '确认到达',
                  color: AppColors.success,
                  onTap: () => Navigator.of(context).pop<String>('confirm_arrived'),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
              Expanded(
                child: _ActionButton(
                  icon: Icons.broken_image_outlined,
                  label: '标记破损',
                  color: AppColors.error,
                  onTap: () => Navigator.of(context).pop<String>('report_damage'),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.scale_outlined,
                  label: '超重处理',
                  color: AppColors.warning,
                  onTap: () => Navigator.of(context).pop<String>('overweight'),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, AppSpacing.sm)),
              Expanded(
                child: _ActionButton(
                  icon: Icons.phone_outlined,
                  label: '联系旅客',
                  color: AppColors.primary,
                  onTap: () => Navigator.of(context).pop<String>('contact_passenger'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDismissButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context, AppSpacing.md)),
      child: TextButton(
        onPressed: () => Navigator.of(context).pop<String>(null),
        style: TextButton.styleFrom(
          minimumSize: Size(double.infinity, Responsive.height(context, 44)),
        ),
        child: Text(
          '取消',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: Responsive.fontSize(context, 14),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: Responsive.spacing(context, AppSpacing.md),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: Responsive.iconSize(context, 26)),
              SizedBox(height: Responsive.spacing(context, 6)),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: Responsive.fontSize(context, 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 自定义路由：将 [ScanResultDialog] 以底部弹页形式推入导航栈
class _ScanResultDialogRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;

  _ScanResultDialogRoute({required this.builder});

  @override
  Color? get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => 'ScanResultDialog';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  }
}
