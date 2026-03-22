import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// 统计卡片组件
/// 用于首页仪表盘展示关键数据指标
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final IconData icon;
  final Color color;
  final String? trend;
  final VoidCallback? onTap;
  final bool isLoading;

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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.cardPadding)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
              _buildValue(context),
              if (trend != null) ...[
                SizedBox(height: Responsive.spacing(context, AppSpacing.xs)),
                _buildTrend(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.all(Responsive.spacing(context, 6)),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: color, size: Responsive.iconSize(context, 16)),
        ),
        if (onTap != null)
          Icon(
            Icons.arrow_forward_ios,
            size: Responsive.iconSize(context, 14),
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 24),
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
              fontSize: Responsive.fontSize(context, 14),
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTrend(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      trend!,
      style: TextStyle(
        fontSize: Responsive.fontSize(context, 12),
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
