import 'package:flutter/material.dart';
import '../models/luggage.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import 'status_badge.dart';

/// 行李卡片组件 - 基于 UI 设计风格
class LuggageCard extends StatelessWidget {
  final Luggage luggage;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showDeleteAction;
  final VoidCallback? onDelete;
  final bool compact;

  const LuggageCard({
    super.key,
    required this.luggage,
    this.onTap,
    this.onLongPress,
    this.showDeleteAction = false,
    this.onDelete,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              if (!compact) ...[
                const SizedBox(height: AppSpacing.sm),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: AppSpacing.sm),
                _buildInfoGrid(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildIcon(context),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                luggage.tagNumber,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                luggage.flightNumber,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 12),
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        StatusBadge(status: luggage.status, compact: true),
        if (showDeleteAction)
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: Responsive.iconSize(context, 20),
            ),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  Widget _buildIcon(BuildContext context) {
    final iconSizeVal = Responsive.iconSize(context, 20);
    return Container(
      width: Responsive.spacing(context, 40),
      height: Responsive.spacing(context, 40),
      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.luggage_outlined,
        color: AppColors.primary,
        size: iconSizeVal,
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoItem(
            icon: Icons.person_outline,
            label: '乘客',
            value: luggage.passengerName,
          ),
        ),
        Expanded(
          child: _InfoItem(
            icon: Icons.scale_outlined,
            label: '重量',
            value: '${luggage.weight.toStringAsFixed(1)} kg',
          ),
        ),
        Expanded(
          child: _InfoItem(
            icon: Icons.flight_land,
            label: '目的地',
            value: luggage.destination,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// 行李卡片信息行组件
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final int maxLines;
  final TextOverflow overflow;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: Responsive.iconSize(context, 11),
              color: AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 10),
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 12),
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimaryLight,
          ),
          maxLines: maxLines,
          overflow: overflow,
        ),
      ],
    );
  }
}

/// 行李列表项组件（轻量版，用于地图弹出等场景）
class LuggageListTile extends StatelessWidget {
  final Luggage luggage;
  final VoidCallback? onTap;
  final Widget? trailing;

  const LuggageListTile({
    super.key,
    required this.luggage,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        side: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFDBEAFE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.luggage_outlined,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        luggage.tagNumber,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Text(
        luggage.passengerName,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondaryLight,
        ),
      ),
      trailing: trailing ?? StatusBadge(status: luggage.status, compact: true),
    );
  }
}
