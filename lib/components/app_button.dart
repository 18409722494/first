import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// 按钮组件
enum AppButtonType {
  primary,
  secondary,
  outline,
  ghost,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final AppButtonType type;
  final AppButtonSize size;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final double? width;
  final bool disabled;
  final Widget? child;

  const AppButton({
    super.key,
    required this.text,
    this.icon,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
    this.width,
    this.disabled = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (disabled || isLoading) ? null : onPressed;
    final effectiveChild = child ?? _buildChild(context);

    final buttonStyle = _resolveStyle(context);
    final effectiveSize = _resolveSize();

    Widget button;
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
        button = FilledButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle.copyWith(
            minimumSize: WidgetStatePropertyAll(effectiveSize),
          ),
          child: effectiveChild,
        );
        break;
      case AppButtonType.outline:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle.copyWith(
            minimumSize: WidgetStatePropertyAll(effectiveSize),
          ),
          child: effectiveChild,
        );
        break;
      case AppButtonType.ghost:
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle.copyWith(
            minimumSize: WidgetStatePropertyAll(effectiveSize),
          ),
          child: effectiveChild,
        );
        break;
    }

    Widget result = button;
    if (fullWidth) {
      result = SizedBox(width: width ?? double.infinity, child: button);
    } else if (width != null) {
      result = SizedBox(width: width, child: button);
    }

    return result;
  }

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: _iconSize + 4,
        width: _iconSize + 4,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _textColor(context),
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _iconSize),
          const SizedBox(width: AppSpacing.xs),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  Size _resolveSize() {
    switch (size) {
      case AppButtonSize.small:
        return Size(0, 36);
      case AppButtonSize.medium:
        return Size(0, 48);
      case AppButtonSize.large:
        return Size(0, 56);
    }
  }

  double get _iconSize {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 18;
      case AppButtonSize.large:
        return 20;
    }
  }

  ButtonStyle _resolveStyle(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    switch (type) {
      case AppButtonType.primary:
        return ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(
            disabled ? primaryColor.withValues(alpha: 0.5) : Colors.white,
          ),
        );
      case AppButtonType.secondary:
        return ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(primaryColor),
          backgroundColor: WidgetStatePropertyAll(
            primaryColor.withValues(alpha: disabled ? 0.1 : 0.12),
          ),
        );
      case AppButtonType.outline:
        return ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(
            disabled ? primaryColor.withValues(alpha: 0.5) : primaryColor,
          ),
        );
      case AppButtonType.ghost:
        return ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(
            disabled ? primaryColor.withValues(alpha: 0.5) : primaryColor,
          ),
        );
    }
  }

  Color _textColor(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    switch (type) {
      case AppButtonType.primary:
        return disabled ? primaryColor.withValues(alpha: 0.5) : Colors.white;
      case AppButtonType.secondary:
      case AppButtonType.outline:
      case AppButtonType.ghost:
        return disabled ? primaryColor.withValues(alpha: 0.5) : primaryColor;
    }
  }
}

/// 底部操作按钮组
class AppBottomBar extends StatelessWidget {
  final List<Widget> children;
  final double topPadding;

  const AppBottomBar({
    super.key,
    required this.children,
    this.topPadding = 6,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: topPadding,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: children.map((child) {
          final index = children.indexOf(child);
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index > 0 ? AppSpacing.sm : 0,
                right: index < children.length - 1 ? AppSpacing.sm : 0,
              ),
              child: child,
            ),
          );
        }).toList(),
      ),
    );
  }
}
