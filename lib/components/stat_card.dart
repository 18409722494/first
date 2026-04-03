import 'package:flutter/material.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// 统计卡片组件
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final IconData icon;
  final Color color;
  final String? trend;
  final VoidCallback? onTap;
  final bool isLoading;
  /// 紧凑模式：减小内边距和字号（窄屏三列并排时启用）
  final bool compact;
  final double compactPadding;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    required this.icon,
    required this.color,
    this.trend,
    this.onTap,
    this.isLoading = false,
    this.compact = false,
    this.compactPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 紧凑模式下使用更小的内边距
    final pad = compact
        ? compactPadding
        : Responsive.padding(context, AppSpacing.cardPadding);
    final iconPad = compact ? pad * 0.5 : pad * 0.6;
    final iconSZ = compact ? 14.0 : 16.0;
    final spacingSm = compact ? pad * 0.5 : pad * 0.75;

    return Card(
      elevation: isDark ? 2 : 1,
      shadowColor: isDark ? Colors.black45 : Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, iconPad, iconSZ),
              SizedBox(height: spacingSm),
              _buildValue(context),
              if (trend != null) ...[
                SizedBox(height: spacingSm * 0.6),
                _buildTrend(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double iconPad, double iconSZ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.all(iconPad),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: color, size: Responsive.iconSize(context, iconSZ)),
        ),
        if (onTap != null)
          Icon(
            Icons.arrow_forward_ios,
            size: Responsive.iconSize(context, 12),
            color: color.withValues(alpha: 0.6),
          ),
      ],
    );
  }

  Widget _buildValue(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return Container(
        height: Responsive.height(context, 24),
        width: Responsive.spacing(context, 60),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    // 数值行整体缩放，防止三列并排时横向溢出
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: compact
                  ? Responsive.fontSize(context, 20)
                  : Responsive.fontSize(context, 24),
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              height: 1.1,
            ),
          ),
          if (unit != null) ...[
            SizedBox(width: Responsive.spacing(context, 4)),
            Text(
              unit!,
              style: TextStyle(
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrend(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      trend!,
      style: TextStyle(
        fontSize: compact ? 11 : 12,
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// 统计卡片骨架屏
class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.cardPadding)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Responsive.spacing(context, 36),
              height: Responsive.spacing(context, 36),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
            Container(
              height: Responsive.height(context, 24),
              width: Responsive.spacing(context, 60),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
            Container(
              height: Responsive.height(context, 12),
              width: Responsive.spacing(context, 80),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
