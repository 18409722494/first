import 'package:flutter/material.dart';
import '../models/luggage.dart';
import '../utils/luggage_utils.dart';

/// 行李状态徽章组件 - 基于 UI 设计风格
/// 统一展示行李状态标签，带圆角背景和状态颜色
///
/// 使用示例：
/// ```dart
/// StatusBadge(status: LuggageStatus.inTransit)
/// StatusBadge(statusKey: 'damaged')
/// ```
class StatusBadge extends StatelessWidget {
  final LuggageStatus? status;
  final String? statusKey;
  final String? text;
  final bool compact;

  const StatusBadge({
    super.key,
    this.status,
    this.statusKey,
    this.text,
    this.compact = false,
  });

  bool get _hasRenderableContent {
    if (text != null && text!.trim().isNotEmpty) return true;
    if (status != null) return true;
    if (statusKey != null && statusKey!.trim().isNotEmpty) return true;
    return false;
  }

  String get _displayText {
    if (text != null && text!.trim().isNotEmpty) return text!;
    if (status != null) return LuggageUtils.getStatusText(status!);
    if (statusKey != null && statusKey!.trim().isNotEmpty) {
      return LuggageUtils.getStatusTextByKey(statusKey!);
    }
    return '';
  }

  Color get _textColor {
    if (status != null) return LuggageUtils.getStatusColor(status!);
    if (statusKey != null && statusKey!.trim().isNotEmpty) {
      return LuggageUtils.getStatusColorByKey(statusKey!);
    }
    return Colors.grey;
  }

  Color get _bgColor {
    if (compact) return Colors.transparent;
    if (status != null) return _getStatusBgColor(status!);
    if (statusKey != null && statusKey!.trim().isNotEmpty) {
      final s = LuggageStatus.values.firstWhere(
        (st) => st.name == statusKey,
        orElse: () => LuggageStatus.checkIn,
      );
      return _getStatusBgColor(s);
    }
    return Colors.grey;
  }

  /// 浅色主题背景色映射
  Color _getStatusBgColor(LuggageStatus s) {
    switch (s) {
      case LuggageStatus.checkIn:
        return const Color(0xFFDBEAFE); // 浅蓝
      case LuggageStatus.inTransit:
        return const Color(0xFFFEF3C7); // 浅黄
      case LuggageStatus.arrived:
        return const Color(0xFFDCFCE7); // 浅绿
      case LuggageStatus.delivered:
        return const Color(0xFFECFEFF); // 浅青
      case LuggageStatus.damaged:
        return const Color(0xFFFEF2F2); // 浅红
      case LuggageStatus.lost:
        return const Color(0xFFF1F5F9); // 浅灰
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasRenderableContent) {
      return const SizedBox.shrink();
    }

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          _displayText,
          style: TextStyle(
            color: _textColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(6),
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

/// 可交互的状态选择器徽章 - 基于 UI 设计风格
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
        final bgColor = _getStatusBgColor(status);

        return GestureDetector(
          onTap: onStatusChanged != null ? () => onStatusChanged!(status) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? bgColor : bgColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(18),
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

  Color _getStatusBgColor(LuggageStatus s) {
    switch (s) {
      case LuggageStatus.checkIn:
        return const Color(0xFFDBEAFE);
      case LuggageStatus.inTransit:
        return const Color(0xFFFEF3C7);
      case LuggageStatus.arrived:
        return const Color(0xFFDCFCE7);
      case LuggageStatus.delivered:
        return const Color(0xFFECFEFF);
      case LuggageStatus.damaged:
        return const Color(0xFFFEF2F2);
      case LuggageStatus.lost:
        return const Color(0xFFF1F5F9);
    }
  }
}
