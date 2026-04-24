import 'package:flutter/material.dart';
import '../models/luggage.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// 行李状态筛选 BottomSheet
///
/// 展示行李状态筛选选项，支持单选。
///
/// 使用示例：
/// ```dart
/// final selectedStatus = await showModalBottomSheet<String?>(
///   context: context,
///   builder: (_) => LuggageFilterSheet(currentStatus: _statusFilter),
/// );
/// if (selectedStatus != null) { ... }
/// ```
class LuggageFilterSheet extends StatelessWidget {
  /// 当前选中的状态（null 表示全部）
  final String? currentStatus;

  /// 本地化字符串获取器
  final String Function(String key) l10n;

  const LuggageFilterSheet({
    super.key,
    this.currentStatus,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardDark
            : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.bottomSheet),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // 拖动指示条
        Container(
          margin: EdgeInsets.only(top: Responsive.spacing(context, AppSpacing.sm)),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // 标题栏
        Padding(
          padding: EdgeInsets.all(Responsive.padding(context, AppSpacing.md)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n('filterConditions'),
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: Text(
                  l10n('clearFilter'),
                  style: TextStyle(fontSize: Responsive.fontSize(context, 13)),
                ),
              ),
            ],
          ),
        ),

        // 状态筛选
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.padding(context, AppSpacing.md),
            vertical: Responsive.spacing(context, AppSpacing.sm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n('status'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.fontSize(context, 14),
                ),
              ),
              SizedBox(height: Responsive.spacing(context, AppSpacing.sm)),
              Wrap(
                spacing: Responsive.spacing(context, AppSpacing.sm),
                runSpacing: Responsive.spacing(context, AppSpacing.sm),
                children: [
                  _buildFilterChip(context, l10n('all'), null),
                  ...LuggageStatus.values.map((status) {
                    return _buildFilterChip(context, status.displayName, status.name);
                  }),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: Responsive.spacing(context, AppSpacing.lg)),
      ]),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String? status) {
    final isSelected = currentStatus == status;
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: Responsive.fontSize(context, 13))),
      selected: isSelected,
      onSelected: (_) => Navigator.pop(context, status),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }
}
