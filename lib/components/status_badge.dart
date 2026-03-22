import 'package:flutter/material.dart';
import '../models/luggage.dart';
import '../utils/luggage_utils.dart';

/// 行李状态徽章组件
/// 统一展示行李状态标签，带圆角背景和状态颜色
///
/// 使用示例：
/// ```dart
/// StatusBadge(status: LuggageStatus.inTransit)
/// StatusBadge(statusKey: 'damaged')
/// ```
class StatusBadge extends StatelessWidget {
  /// 行李状态枚举
  final LuggageStatus? status;

  /// 行李状态字符串键（与 status 二选一）
  final String? statusKey;

  /// 徽章文本（可选，默认使用状态显示名）
  final String? text;

  /// 是否为紧凑样式（无背景色）
  final bool compact;

  /// 徽章圆角
  final double? radius;

  const StatusBadge({
    super.key,
    this.status,
    this.statusKey,
    this.text,
    this.compact = false,
    this.radius,
  }) : assert(status != null || statusKey != null || text != null,
            'StatusBadge requires at least one of status, statusKey, or text');

  String get _displayText {
    if (text != null) return text!;
    if (status != null) return LuggageUtils.getStatusText(status!);
    return LuggageUtils.getStatusTextByKey(statusKey!);
  }

  Color get _textColor {
    if (status != null) return LuggageUtils.getStatusColor(status!);
    return LuggageUtils.getStatusColorByKey(statusKey!);
  }

  Color get _bgColor {
    if (compact) return Colors.transparent;
    if (status != null) return LuggageUtils.getStatusBgColor(status!);
    return LuggageUtils.getStatusBgColorByKey(statusKey!);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = radius ?? (compact ? 4.0 : 999.0);

    if (compact) {
      return Text(
        _displayText,
        style: TextStyle(
          color: _textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(effectiveRadius),
      ),
      child: Text(
        _displayText,
        style: TextStyle(
          color: _textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 可交互的状态选择器徽章
class StatusBadgeSelector extends StatelessWidget {
  final LuggageStatus currentStatus;
  final ValueChanged<LuggageStatus>? onStatusChanged;
  final bool showAll;

  const StatusBadgeSelector({
    super.key,
    required this.currentStatus,
    this.onStatusChanged,
    this.showAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = showAll
        ? LuggageStatus.values
        : LuggageStatus.values.where((s) => s != LuggageStatus.lost).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((status) {
        final isSelected = status == currentStatus;
        final textColor = LuggageUtils.getStatusColor(status);
        final bgColor = LuggageUtils.getStatusBgColor(status);

        return GestureDetector(
          onTap: onStatusChanged != null ? () => onStatusChanged!(status) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? bgColor : bgColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(999.0),
              border: isSelected
                  ? Border.all(color: textColor, width: 1.5)
                  : Border.all(color: Colors.transparent, width: 1.5),
            ),
            child: Text(
              status.displayName,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
