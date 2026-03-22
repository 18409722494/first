import 'dart:async';

import 'package:flutter/material.dart';

import '../models/luggage.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'status_badge.dart';

/// 统一搜索栏组件
/// 支持文本搜索、状态过滤和防抖功能
class AppSearchBar extends StatefulWidget {
  /// 搜索框控制器
  final TextEditingController? controller;

  /// 搜索框提示文本
  final String hintText;

  /// 提交搜索时的回调
  final ValueChanged<String>? onSubmitted;

  /// 文本变化时的回调（防抖后触发）
  final ValueChanged<String>? onChanged;

  /// 防抖延迟（毫秒），默认 300ms
  final int debounceDelay;

  /// 是否显示清除按钮
  final bool showClearButton;

  /// 清除按钮回调
  final VoidCallback? onClear;

  /// 搜索框前缀图标
  final IconData prefixIcon;

  /// 额外的前置小部件
  final Widget? prefix;

  /// 额外的后置小部件
  final Widget? suffix;

  /// 是否自动获取焦点
  final bool autofocus;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText = '搜索...',
    this.onSubmitted,
    this.onChanged,
    this.debounceDelay = 300,
    this.showClearButton = true,
    this.onClear,
    this.prefixIcon = Icons.search,
    this.prefix,
    this.suffix,
    this.autofocus = false,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;
  Timer? _debounceTimer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      Duration(milliseconds: widget.debounceDelay),
      () {
        widget.onChanged?.call(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(AppRadius.searchBar),
      ),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        onSubmitted: widget.onSubmitted,
        onChanged: widget.onChanged != null ? _onSearchChanged : null,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 15,
          ),
          prefixIcon: widget.prefix ?? Icon(widget.prefixIcon, color: Colors.grey[500]),
          suffixIcon: widget.showClearButton && _hasText
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  color: Colors.grey[500],
                  onPressed: _handleClear,
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.buttonPadding,
          ),
        ),
      ),
    );
  }
}

/// 状态过滤 Chip 组组件
/// 用于行李状态的快速筛选
class FilterChipGroup extends StatelessWidget {
  /// 当前选中的状态（可为 null 表示全部）
  final LuggageStatus? selectedStatus;

  /// 状态变化回调
  final ValueChanged<LuggageStatus?>? onStatusChanged;

  /// 是否显示"全部"选项
  final bool showAll;

  /// 是否允许多选
  final bool multiSelect;

  /// 选中的状态列表（多选模式）
  final Set<LuggageStatus>? selectedStatuses;

  /// 多选模式下的状态变化回调
  final ValueChanged<Set<LuggageStatus>>? onMultiStatusChanged;

  /// Chip 水平滚动
  final bool scrollable;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  const FilterChipGroup({
    super.key,
    this.selectedStatus,
    this.onStatusChanged,
    this.showAll = true,
    this.multiSelect = false,
    this.selectedStatuses,
    this.onMultiStatusChanged,
    this.scrollable = true,
    this.padding,
  }) : assert(!multiSelect || (multiSelect && selectedStatuses != null && onMultiStatusChanged != null),
            'MultiSelect mode requires selectedStatuses and onMultiStatusChanged');

  static const List<LuggageStatus> _filterableStatuses = [
    LuggageStatus.checkIn,
    LuggageStatus.inTransit,
    LuggageStatus.arrived,
    LuggageStatus.delivered,
    LuggageStatus.damaged,
    LuggageStatus.lost,
  ];

  @override
  Widget build(BuildContext context) {
    final Widget chipGroup;

    if (multiSelect) {
      chipGroup = _buildMultiSelectChips(context);
    } else {
      chipGroup = _buildSingleSelectChips(context);
    }

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            if (showAll) ...[
              _buildAllChip(context),
              const SizedBox(width: AppSpacing.sm),
            ],
            ..._buildStatusChips(context),
          ],
        ),
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          if (showAll) _buildAllChip(context),
          ..._buildStatusChips(context),
        ],
      ),
    );
  }

  Widget _buildAllChip(BuildContext context) {
    final isSelected = selectedStatus == null;

    return FilterChip(
      label: const Text('全部'),
      selected: isSelected,
      onSelected: (_) => onStatusChanged?.call(null),
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : Colors.grey[300]!,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
    );
  }

  List<Widget> _buildStatusChips(BuildContext context) {
    return _filterableStatuses.map((status) {
      final isSelected = multiSelect
          ? selectedStatuses?.contains(status) ?? false
          : selectedStatus == status;

      final textColor = _getStatusColor(status);
      final bgColor = _getStatusBgColor(status);

      return Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: FilterChip(
          label: Text(status.displayName),
          selected: isSelected,
          onSelected: (_) => _handleChipTap(status),
          selectedColor: bgColor,
          checkmarkColor: textColor,
          labelStyle: TextStyle(
            color: isSelected ? textColor : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
          side: BorderSide(
            color: isSelected ? textColor : Colors.grey[300]!,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        ),
      );
    }).toList();
  }

  Widget _buildSingleSelectChips(BuildContext context) {
    return Row(
      children: [
        if (showAll) ...[
          _buildAllChip(context),
          const SizedBox(width: AppSpacing.sm),
        ],
        ..._buildStatusChips(context),
      ],
    );
  }

  Widget _buildMultiSelectChips(BuildContext context) {
    return Row(
      children: _buildStatusChips(context),
    );
  }

  void _handleChipTap(LuggageStatus status) {
    if (multiSelect) {
      final currentSelection = Set<LuggageStatus>.from(selectedStatuses ?? {});
      if (currentSelection.contains(status)) {
        currentSelection.remove(status);
      } else {
        currentSelection.add(status);
      }
      onMultiStatusChanged?.call(currentSelection);
    } else {
      if (selectedStatus == status) {
        onStatusChanged?.call(null);
      } else {
        onStatusChanged?.call(status);
      }
    }
  }

  Color _getStatusColor(LuggageStatus status) {
    switch (status) {
      case LuggageStatus.checkIn:
        return AppColors.checkIn;
      case LuggageStatus.inTransit:
        return AppColors.inTransit;
      case LuggageStatus.arrived:
        return AppColors.arrived;
      case LuggageStatus.delivered:
        return AppColors.delivered;
      case LuggageStatus.damaged:
        return AppColors.damaged;
      case LuggageStatus.lost:
        return AppColors.lost;
    }
  }

  Color _getStatusBgColor(LuggageStatus status) {
    switch (status) {
      case LuggageStatus.checkIn:
        return AppColors.checkInBg;
      case LuggageStatus.inTransit:
        return AppColors.inTransitBg;
      case LuggageStatus.arrived:
        return AppColors.arrivedBg;
      case LuggageStatus.delivered:
        return AppColors.deliveredBg;
      case LuggageStatus.damaged:
        return AppColors.damagedBg;
      case LuggageStatus.lost:
        return AppColors.lostBg;
    }
  }
}

/// 搜索栏与状态过滤的组合组件
/// 提供完整的搜索和过滤体验
class SearchWithFilter extends StatelessWidget {
  /// 搜索框控制器
  final TextEditingController? controller;

  /// 搜索框提示文本
  final String hintText;

  /// 提交搜索时的回调
  final ValueChanged<String>? onSubmitted;

  /// 文本变化时的回调
  final ValueChanged<String>? onChanged;

  /// 防抖延迟（毫秒）
  final int debounceDelay;

  /// 当前选中的状态
  final LuggageStatus? selectedStatus;

  /// 状态变化回调
  final ValueChanged<LuggageStatus?>? onStatusChanged;

  /// 是否显示状态过滤
  final bool showFilter;

  /// 是否显示清除按钮
  final bool showClearButton;

  /// 清除按钮回调
  final VoidCallback? onClear;

  /// 搜索栏高度
  final double searchBarHeight;

  /// 搜索框内边距
  final EdgeInsetsGeometry? searchBarPadding;

  /// 过滤 Chips 内边距
  final EdgeInsetsGeometry? filterPadding;

  const SearchWithFilter({
    super.key,
    this.controller,
    this.hintText = '搜索行李标签号、航班号...',
    this.onSubmitted,
    this.onChanged,
    this.debounceDelay = 300,
    this.selectedStatus,
    this.onStatusChanged,
    this.showFilter = true,
    this.showClearButton = true,
    this.onClear,
    this.searchBarHeight = 48,
    this.searchBarPadding,
    this.filterPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: searchBarPadding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: SizedBox(
            height: searchBarHeight,
            child: AppSearchBar(
              controller: controller,
              hintText: hintText,
              onSubmitted: onSubmitted,
              onChanged: onChanged,
              debounceDelay: debounceDelay,
              showClearButton: showClearButton,
              onClear: onClear,
            ),
          ),
        ),
        if (showFilter) ...[
          const SizedBox(height: AppSpacing.sm),
          FilterChipGroup(
            selectedStatus: selectedStatus,
            onStatusChanged: onStatusChanged,
            padding: filterPadding,
          ),
        ],
      ],
    );
  }
}
