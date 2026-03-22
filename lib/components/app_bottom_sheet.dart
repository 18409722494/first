import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// 行李状态枚举
enum LuggageStatus {
  checkIn('已办理托运', AppColors.checkIn, AppColors.checkInBg),
  inTransit('运输中', AppColors.inTransit, AppColors.inTransitBg),
  arrived('已到达', AppColors.arrived, AppColors.arrivedBg),
  delivered('已交付', AppColors.delivered, AppColors.deliveredBg),
  damaged('已损坏', AppColors.damaged, AppColors.damagedBg),
  lost('已丢失', AppColors.lost, AppColors.lostBg);

  const LuggageStatus(this.label, this.color, this.bgColor);

  final String label;
  final Color color;
  final Color bgColor;
}

/// 行李数据模型
class LuggageInfo {
  const LuggageInfo({
    required this.tagNumber,
    required this.status,
    required this.passenger,
    required this.flight,
    required this.weight,
    required this.destination,
    this.receiveTime,
    this.deliveryPoint,
  });

  final String tagNumber;
  final LuggageStatus status;
  final String passenger;
  final String flight;
  final String weight;
  final String destination;
  final String? receiveTime;
  final String? deliveryPoint;
}

/// 统一的底部弹窗包装组件
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.maxHeightFactor = 0.9,
    this.backgroundColor,
    this.hasDragHandle = true,
    this.dragHandleColor,
    this.topPadding = AppSpacing.sm,
    this.horizontalPadding = AppSpacing.md,
    this.borderRadius,
  });

  final Widget child;
  final double maxHeightFactor;
  final Color? backgroundColor;
  final bool hasDragHandle;
  final Color? dragHandleColor;
  final double topPadding;
  final double horizontalPadding;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * maxHeightFactor;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius ?? AppRadius.bottomSheet),
          topRight: Radius.circular(borderRadius ?? AppRadius.bottomSheet),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasDragHandle) ...[
            SizedBox(height: topPadding),
            _buildDragHandle(),
          ],
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: hasDragHandle ? AppSpacing.md : topPadding + AppSpacing.md,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: dragHandleColor ?? AppColors.divider,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// 显示底部弹窗的静态方法
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double maxHeightFactor = 0.9,
    Color? backgroundColor,
    bool hasDragHandle = true,
    double horizontalPadding = AppSpacing.md,
    double? borderRadius,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      builder: (context) => AppBottomSheet(
        maxHeightFactor: maxHeightFactor,
        backgroundColor: backgroundColor,
        hasDragHandle: hasDragHandle,
        horizontalPadding: horizontalPadding,
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}

/// 行李详情底部弹窗
class LuggageDetailBottomSheet extends StatelessWidget {
  const LuggageDetailBottomSheet({
    super.key,
    required this.luggage,
    this.onStatusTap,
    this.onPassengerTap,
    this.showDivider = true,
  });

  final LuggageInfo luggage;
  final VoidCallback? onStatusTap;
  final VoidCallback? onPassengerTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        if (showDivider) ...[
          const SizedBox(height: AppSpacing.md),
          Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: AppSpacing.md),
        ],
        _buildInfoGrid(),
        if (luggage.deliveryPoint != null) ...[
          const SizedBox(height: AppSpacing.md),
          _buildDeliveryPoint(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                luggage.tagNumber,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              _StatusBadge(
                status: luggage.status,
                onTap: onStatusTap,
              ),
            ],
          ),
        ),
        _PassengerAvatar(
          name: luggage.passenger,
          onTap: onPassengerTap,
        ),
      ],
    );
  }

  Widget _buildInfoGrid() {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            icon: Icons.flight_takeoff,
            label: '航班',
            value: luggage.flight,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _InfoCard(
            icon: Icons.scale,
            label: '重量',
            value: luggage.weight,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryPoint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              luggage.deliveryPoint!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示行李详情弹窗的便捷方法
  static Future<void> show({
    required BuildContext context,
    required LuggageInfo luggage,
    VoidCallback? onStatusTap,
    VoidCallback? onPassengerTap,
    double maxHeightFactor = 0.6,
  }) {
    return AppBottomSheet.show(
      context: context,
      maxHeightFactor: maxHeightFactor,
      child: LuggageDetailBottomSheet(
        luggage: luggage,
        onStatusTap: onStatusTap,
        onPassengerTap: onPassengerTap,
      ),
    );
  }
}

/// 状态徽章组件
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    this.onTap,
  });

  final LuggageStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: status.bgColor,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Text(
          status.label,
          style: TextStyle(
            color: status.color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// 乘客头像组件
class _PassengerAvatar extends StatelessWidget {
  const _PassengerAvatar({
    required this.name,
    this.onTap,
  });

  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

/// 信息卡片组件
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 确认对话框辅助类
class AppConfirmDialog {
  AppConfirmDialog._();

  /// 显示确认对话框
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = '确认',
    String cancelText = '取消',
    Color? confirmColor,
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: confirmColor ?? (isDangerous ? AppColors.error : AppColors.primary),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 显示删除确认对话框
  static Future<bool> delete({
    required BuildContext context,
    required String itemName,
    String? customMessage,
  }) {
    return show(
      context: context,
      title: '确认删除',
      message: customMessage ?? '确定要删除 "$itemName" 吗？此操作无法撤销。',
      confirmText: '删除',
      isDangerous: true,
    );
  }

  /// 显示成功确认对话框
  static Future<bool> success({
    required BuildContext context,
    required String title,
    String message = '操作已成功完成',
    String confirmText = '知道了',
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      confirmColor: AppColors.success,
    );
  }

  /// 显示警告确认对话框
  static Future<bool> warning({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = '继续',
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      confirmColor: AppColors.warning,
    );
  }
}
