import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

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
