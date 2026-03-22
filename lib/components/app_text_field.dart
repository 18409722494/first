import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// 统一输入框组件
/// 支持文本、密码、数字键盘等多种类型
///
/// 使用示例：
/// ```dart
/// AppTextField(
///   controller: _tagController,
///   label: '行李标签号',
///   hint: '请输入标签号',
///   prefixIcon: Icons.qr_code,
/// )
/// ```
class AppTextField extends StatelessWidget {
  /// 控制器
  final TextEditingController? controller;

  /// 标签文本
  final String? label;

  /// 提示文本
  final String? hint;

  /// 前缀图标
  final IconData? prefixIcon;

  /// 后缀组件
  final Widget? suffixIcon;

  /// 输入类型
  final TextInputType keyboardType;

  /// 是否为密码输入
  final bool obscureText;

  /// 密码切换图标（自定义）
  final bool showPasswordToggle;

  /// 错误文本
  final String? errorText;

  /// 验证器
  final String? Function(String?)? validator;

  /// 值变化回调
  final ValueChanged<String>? onChanged;

  /// 提交回调
  final ValueChanged<String>? onSubmitted;

  /// 是否只读
  final bool readOnly;

  /// 最大行数
  final int? maxLines;

  /// 最大字数
  final int? maxLength;

  /// 是否自动聚焦
  final bool autofocus;

  /// 焦点节点
  final FocusNode? focusNode;

  /// 文本输入动作
  final TextInputAction? textInputAction;

  /// 前缀文本
  final String? prefixText;

  /// 后缀文本
  final String? suffixText;

  /// 是否启用
  final bool enabled;

  /// 文字对齐
  final TextAlign textAlign;

  /// 内容边距
  final EdgeInsetsGeometry? contentPadding;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction,
    this.prefixText,
    this.suffixText,
    this.enabled = true,
    this.textAlign = TextAlign.start,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          autofocus: autofocus,
          textInputAction: textInputAction,
          enabled: enabled,
          textAlign: textAlign,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20)
                : null,
            suffixIcon: _buildSuffixIcon(),
            prefixText: prefixText,
            suffixText: suffixText,
            contentPadding: contentPadding ??
                const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.buttonPadding,
                ),
          ),
          inputFormatters: _buildInputFormatters(),
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (suffixIcon != null) return suffixIcon;
    if (showPasswordToggle) return _PasswordToggle(obscureText: obscureText);
    return null;
  }

  List<TextInputFormatter>? _buildInputFormatters() {
    final formatters = <TextInputFormatter>[];
    if (keyboardType == TextInputType.numberWithOptions(decimal: true) ||
        keyboardType == TextInputType.number) {
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')));
    }
    return formatters.isEmpty ? null : formatters;
  }
}

class _PasswordToggle extends StatefulWidget {
  final bool obscureText;
  const _PasswordToggle({required this.obscureText});
  @override
  State<_PasswordToggle> createState() => _PasswordToggleState();
}

class _PasswordToggleState extends State<_PasswordToggle> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _visible ? Icons.visibility_off : Icons.visibility,
        size: 20,
        color: AppColors.textSecondary,
      ),
      onPressed: () => setState(() => _visible = !_visible),
    );
  }

  bool get obscureText => !_visible;
}

/// 搜索框组件
/// 封装搜索交互逻辑和样式
class AppSearchField extends StatelessWidget {
  /// 控制器
  final TextEditingController? controller;

  /// 提示文本
  final String hint;

  /// 提交回调
  final ValueChanged<String>? onSubmitted;

  /// 文字变化回调
  final ValueChanged<String>? onChanged;

  /// 是否显示清除按钮
  final bool showClearButton;

  /// 搜索图标
  final IconData searchIcon;

  const AppSearchField({
    super.key,
    this.controller,
    this.hint = '搜索...',
    this.onSubmitted,
    this.onChanged,
    this.showClearButton = true,
    this.searchIcon = Icons.search,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(searchIcon, size: 20),
        suffixIcon: (showClearButton && controller != null && controller!.text.isNotEmpty)
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  controller!.clear();
                  onChanged?.call('');
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 12,
        ),
      ),
    );
  }
}
